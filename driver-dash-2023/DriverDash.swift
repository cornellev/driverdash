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
    @ObservedObject private var model = DriverDashModel()

    private var frontServerController: DDServer?
    private var backServerController: DDServer?
    private var lordServerController: DDServer?
    private var locationController: DDLocation?
    
    init() {
        self.frontServerController = DDServer(address: "10.48.155.202", port: 8081, for: .front, with: model)
        self.backServerController = DDServer(address: "10.48.155.202", port: 8080, for: .back, with: model)
        self.lordServerController = DDServer(address: "10.48.155.202", port: 8082, for: .lord, with: model)
        
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
                    Text("Front")
                        .foregroundColor(model.frontSocketConnected ? Color.green : Color.red)
                        .bold()
                    Text("Back")
                        .foregroundColor(model.backSocketConnected ? Color.green : Color.red)
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
