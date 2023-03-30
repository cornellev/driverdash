//
//  DriverDash.swift
//  driver-dash-2023
//
//  Created by Jason Klein on 3/24/23.
//

import SwiftUI

@main
struct DriverDash: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct ContentView: View {
    @ObservedObject private var model = DDModel()

    private var daqServerController: DDServer?
    private var lordServerController: DDServer?
    private var locationController: DDLocation?
    
    private let ip = "10.49.20.4"
    
    init() {
        self.daqServerController = DDServer(address: ip, port: 8080, for: .daq, with: model)
        self.lordServerController = DDServer(address: ip, port: 8081, for: .lord, with: model)
        
        self.locationController = DDLocation(with: model)
    }
    
    var body: some View {
        HStack {
            VStack {
                // spacers to center in remaining space
                Spacer()
                
                VStack(alignment: .leading, spacing: 50) {
                    DataView(title: "Speed", value: model.speed, units: "km/h")
                    DataView(title: "Power", value: model.power, units: "kW/h")
                }
                
                Spacer()
                
                // connection indicators
                HStack(spacing: 50) {
                    Text("DAQ")
                        .foregroundColor(model.daqSocketConnected ? Color.green : Color.red)
                        .bold()
                    Text("LORD")
                        .foregroundColor(model.lordSocketConnected ? Color.green : Color.red)
                        .bold()
                }.padding([.bottom], 20)
            }
                .frame(maxWidth: .infinity)
            
            MapView()
                .frame(maxWidth: .infinity)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
