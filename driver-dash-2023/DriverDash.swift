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
    
    var body: some View {
        HStack {
            DataView(title: "Speed", value: model.speed, units: "km/h")
            DataView(title: "Power", value: model.power, units: "????")
        }.padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
