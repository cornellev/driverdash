//
//  DriverDash.swift
//  driver-dash-2023
//
//  Created by Jason Klein on 3/24/23.
//

import SwiftUI

@main
struct DriverDash: App {
    @ObservedObject private var model = DriverDashModel()
    
    //organize the visual such that data is on lefthand side and map on the right
    var body: some Scene {
        WindowGroup {
            HStack {
                VStack(spacing: 0) {
                    DataView(title: "Speed", value: model.speed, units: "km/h")
                        .frame(maxWidth: .infinity)
                    Divider()
                    DataView(title: "Power", value: model.power, units: "kw/h")
                        .frame(maxWidth: .infinity)
                }
                .frame(maxWidth: .infinity)
                Polyline()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.white)
        }
    }
}