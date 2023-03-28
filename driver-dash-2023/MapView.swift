//
//  MapView.swift
//  driver-dash-2023
//
//  Created by Jason Klein on 3/27/23.
//

import SwiftUI
import MapKit

// Watch this vid for the bottom structs: https://www.youtube.com/watch?v=hWMkimzIQoU
struct MapView: View {
    @StateObject private var model = MapModel()
    
    @State var region: MKCoordinateRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 39.795, longitude: -86.2353),
        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.0175)
    )

    var body: some View {
        Map(coordinateRegion: $region, interactionModes: [], showsUserLocation: true)
            .ignoresSafeArea()
    }
}

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView()
    }
}
