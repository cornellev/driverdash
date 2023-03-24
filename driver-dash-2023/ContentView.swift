//
//  ContentView.swift
//  driver-dash-2023
//
//  Created by Jason Klein on 3/24/23.
//

import SwiftUI

struct DataView: View {
    var title: String
    var units: String
    var value: Double = 0
    
    var body: some View {
        VStack {
            // title styling
            Text(title)
                .font(.title).bold()
                .padding([.leading, .trailing], 100)
            Text(units)
            
            // handle data display
            Text(String(format: "%.2f", value))
                .font(.system(size: 32, design: .monospaced))
                .padding(10)
        }
    }
}

struct ContentView: View {
    var body: some View {
        HStack {
            DataView(title: "Power", units: "kmph")
            DataView(title: "Speed", units: "km/kWh")
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
