//
//  MapView.swift
//  driver-dash-2023
//
//  Created by Jason Klein on 3/27/23.
//

import SwiftUI
import MapKit

// Watch this vid for the bottom structs: https://www.youtube.com/watch?v=hWMkimzIQoU
// https://codakuma.com/the-line-is-a-dot-to-you/
struct MapView: UIViewRepresentable {
    let coordinates: [CLLocation] = []
    
    // Create the MKMapView using UIKit.
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.interactions = []
        mapView.region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 39.795, longitude: -86.2353),
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.0175))
        
        return mapView
    }

    // We don't need to worry about this as the view will never be updated.
    func updateUIView(_ view: MKMapView, context: Context) {}

    // Link it to the coordinator which is defined below.
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
}

class Coordinator: NSObject, MKMapViewDelegate {
  var parent: MapView

  init(_ parent: MapView) {
    self.parent = parent
  }
}
