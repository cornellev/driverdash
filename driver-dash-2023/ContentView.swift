//
//  ContentView.swift
//  driver-dash-2023
//
//  Created by Jason Klein on 3/24/23.
//

import SwiftUI
import CoreBluetooth

// see https://youtu.be/n-f0BwxKSD0
class BluetoothViewModel: NSObject, ObservableObject {
    private var centralManager: CBCentralManager?
    private var peripherals: [CBPeripheral] = []
    
    @Published var peripheralNames: [String] = []
    
    override init() {
        super.init()
        // initialize the central manager. Black magic to me
        self.centralManager = CBCentralManager(delegate: self, queue: .main)
    }
}

extension BluetoothViewModel: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            self.centralManager?.scanForPeripherals(withServices: nil)
        }
    }
    
    // callback when we receive a bluetooth signal I think
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        if !peripherals.contains(peripheral) {
            self.peripherals.append(peripheral)
            self.peripheralNames.append(peripheral.name ?? "Unnamed Device")
        }
    }
}

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
    @ObservedObject private var bluetoothViewModel = BluetoothViewModel()
    
    var body: some View {
        List(bluetoothViewModel.peripheralNames, id: \.self) { peripheral in
            Text(peripheral)
        }
    }
//    var body: some View {
//        HStack {
//            DataView(title: "Power", units: "kmph")
//            DataView(title: "Speed", units: "km/kWh")
//        }
//        .padding()
//    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
