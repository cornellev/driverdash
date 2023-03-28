//
//  DataView.swift
//  driver-dash-2023
//
//  Created by Jason Klein on 3/24/23.
//

import SwiftUI

struct DataView: View {
    var title: String
    var value: Double = 0
    var units: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // title styling
            Text(title)
                .font(.title).bold()
            
            HStack(alignment: .bottom) {
                // handle data display
                Text(String(format: "%.2f", value))
                    .font(.system(size: 48, design: .monospaced))
                    .padding([.leading, .trailing], 5)
                
                Text(units)
                    .padding([.bottom], 10)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding([.leading], 65)
    }
}
