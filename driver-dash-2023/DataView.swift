//
//  DataView.swift
//  driver-dash-2023
//
//  Created by Jason Klein on 3/24/23.
//

import SwiftUI
import MapKit

// see https://engineering.deptagency.com/state-of-swift-websockets

struct DataView: View {
    var title: String
    var value: Double = 0
    var units: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.title).bold()
                .padding([.leading, .trailing], 40)
            Text(units)
            
            // handle data display
            Text(String(format: "%.2f", value))
                .font(.system(size: 25, design: .monospaced))
                .padding(10)
        }
        HStack{}
    }
}
// Watch this vid for the bottom structs: https://www.youtube.com/watch?v=hWMkimzIQoU

//creates the map 
struct MapView: View {
    @StateObject private var viewModel: MapViewModel = MapViewModel()
    @State var region: MKCoordinateRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 39.7954, longitude: -86.2353),
        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    )

    var body: some View {
        Map(coordinateRegion: $region, showsUserLocation: true).ignoresSafeArea().onAppear(){
            viewModel.checkLocationServicesAreEnabled()
        }

    }
}
struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView()
    }
}

//handles the authorization to allow use of locations
final class MapViewModel: NSObject, ObservableObject, CLLocationManagerDelegate{

    var locationManager: CLLocationManager?

    func checkLocationServicesAreEnabled(){
        if CLLocationManager.locationServicesEnabled(){
            locationManager = CLLocationManager()
            locationManager!.delegate = self
            print("Show alert")
        }
    }

    private func checkLocationAuthorization(){
        guard let locationManager: CLLocationManager = locationManager else{return}

        switch locationManager.authorizationStatus {

            case .notDetermined:
                locationManager.requestWhenInUseAuthorization()
            case .restricted:
                print("restricted")
            case .denied:
                print("denied")
            case .authorizedAlways, .authorizedWhenInUse:
                break
            @unknown default:
                break
        }
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocationAuthorization()
    }
}
