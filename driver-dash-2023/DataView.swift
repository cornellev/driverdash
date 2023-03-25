//
//  DataView.swift
//  driver-dash-2023
//
//  Created by Jason Klein on 3/24/23.
//

import SwiftUI

// see https://engineering.deptagency.com/state-of-swift-websockets

struct DataView: View {
    var title: String
    var value: Double = 0
    var units: String
    
    var body: some View {
        VStack {
            // title styling
            Text(title)
                .font(.title).bold()
                .padding([.leading, .trailing], 70)
            Text(units)
            
            // handle data display
            Text(String(format: "%.2f", value))
                .font(.system(size: 48, design: .monospaced))
                .padding(10)
        }
    }
}
