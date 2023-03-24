//
//  ContentView.swift
//  driver-dash-2023
//
//  Created by Jason Klein on 3/24/23.
//

import SwiftUI
import CoreBluetooth

// see https://youtu.be/n-f0BwxKSD0
// also see https://www.kodeco.com/231-core-bluetooth-tutorial-for-ios-heart-rate-monitor
class BluetoothViewModel: NSObject, ObservableObject {
    private var centralManager: CBCentralManager!
    private var peripherals: [CBPeripheral] = []
    
    @Published var device: CBPeripheral?
    
    override init() {
        super.init()
        // initialize the central manager. Black magic to me
        self.centralManager = CBCentralManager(delegate: self, queue: .main)
    }
}


extension BluetoothViewModel: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
          case .unknown:
            print("central.state is .unknown")
          case .resetting:
            print("central.state is .resetting")
          case .unsupported:
            print("central.state is .unsupported")
          case .unauthorized:
            print("central.state is .unauthorized")
          case .poweredOff:
            print("central.state is .poweredOff")
          case .poweredOn:
            print("central.state is .poweredOn")
            self.centralManager.scanForPeripherals(withServices: nil)
        @unknown default:
            print("central.state fell to unknown default switch case")
        }
    }
    
    // callback when we receive a bluetooth discovery signal I think
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        if let name = peripheral.name {
            // production and testing
            if name == "ESP32test" {
                self.device = peripheral
                // we found it, so we can stop
                centralManager.stopScan()
                centralManager.connect(peripheral)
            }
        }
    }
    
    // don't need if statements since we're only connecting to the desired peripheral
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Successfully connected!")
    }
    
    // stay up to date on whether or not there's a connection
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        self.device = nil
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
        if let device = bluetoothViewModel.device {
            Text(device.name ?? "uh oh bad name")
        } else {
            Text("nothing connected yet")
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
