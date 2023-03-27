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

    private var serverController: DDServer?
    private var locationController: DDLocation?
    
    init() {
        self.serverController = DDServer(with: model)
        // self.locationController = DDLocation(with: model)
    }
    
    var body: some View {
        HStack {
            DataView(title: "Speed", value: model.speed, units: "km/h")
            DataView(title: "Power", value: model.power, units: "kW/h")
        }.padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
