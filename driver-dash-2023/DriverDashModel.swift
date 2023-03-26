//
//  DriverDashModel.swift
//  driver-dash-2023
//
//  Created by Jason Klein on 3/25/23.
//

import SwiftUI
import Swifter
import CoreLocation

// have two UserDefaults keys, one for front-daq and one for back-daq
// each one has the timestamp: { data } format I outlined for Drew
// note that the location comes with a timestamp!

class DriverDashModel: NSObject, ObservableObject {
    @Published var speed = 0.0
    @Published var power = 0.0
    
    private var server: HttpServer!
    private var locationManager: CLLocationManager!
    
    private var location: CLLocation?
    
    override init() {
        super.init()
        
        // set up phone GPS tracking
        locationManager = CLLocationManager()
        // not sure what I want the accuracy level to be
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.delegate = self
        
        locationManager.startUpdatingLocation()
        
        // see https://github.com/httpswift/swifter
        self.server = HttpServer()
        
        // make it easy to check whether the server is alive
        server["/ping"] = { request in
            self.locationManager.requestLocation()
            print(self.location ?? "no location yet")
            return .ok(.text("pong"))
            
        }
        
        //handles back daq
        server["/back-daq"] = websocket(text: { session, text in
            // see https://stackoverflow.com/a/53569348 and also
            // https://www.avanderlee.com/swift/json-parsing-decoding/ for JSON decoding
            var json = try! JSONDecoder().decode(BackPacket.self, from: text.data(using: .utf8)!)
            
            // see https://stackoverflow.com/a/74318451
            DispatchQueue.main.async {
                self.power = json.bms ?? self.power
            }
            
            // save to file with timestamp. requires location
            if let location = self.location {
                // if no RTK, fill with phone location
                if json.rtk == nil {
                    json.rtk = BackPacket.RTK(
                        latitude: location.coordinate.latitude,
                        longitude: location.coordinate.longitude)
                }
                
                let encoded = try! JSONEncoder().encode(json)
                let timestamp = getTimestampString(from: location.timestamp)
                UserDefaults.standard.set(encoded, forKey: timestamp)
                
                print(try! JSONDecoder().decode(BackPacket.self,
                                                from: (UserDefaults.standard.value(forKey: timestamp) as? Data)!))
            }
        })
        
        //handle front daq
        server["/front-daq"] = websocket(text: { session, text in
            // see https://stackoverflow.com/a/53569348 and also
            // https://www.avanderlee.com/swift/json-parsing-decoding/ for JSON decoding
            let json = try! JSONDecoder().decode(FrontPacket.self, from: text.data(using: .utf8)!)
            
            // todo: save to file with timestamp
        })
        
        func getTimestampString(from date: Date = Date()) -> String {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd:HH:mm:ss.SSSSS"
            return dateFormatter.string(from: date)
        }
        
        do {
            try server.start(8080)
            try print("Running on port \(server.port())")
            
        // https://stackoverflow.com/a/30720807
        } catch let error {
            print(error.localizedDescription)
        }
    }
}

extension DriverDashModel: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //. keep the current location up to date as much as possible
        if let location = locations.last {
            self.location = location
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // todo: is there a better way to handle errors than this?
        print("Whoopsies. Had trouble getting the location.")
    }
}
