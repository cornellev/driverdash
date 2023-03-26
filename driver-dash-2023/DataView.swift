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

//create a map visual 
struct MapView: View {
    @State var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 39.7954, longitude: -86.2353),
        span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
    )

    var body: some View {
        Map(coordinateRegion: $region)
    }
}
