//
//  DriverDash.swift
//  driver-dash-2023
//
//  Created by Jason Klein on 3/24/23.
//  Modified by Lauren Kam on 4/14/23.
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
    @ObservedObject private var model = DDModel()

    private var daqServerController: DDServer?
    private var lordServerController: DDServer?
    private var locationController: DDLocation?
    @State var lapnum : Int = 1
    @State private var progressTime = 0
    @State private var isRunning = false
    
    var minutes: Int {
            (progressTime % 3600) / 60
    }

    var seconds: Int {
            progressTime % 60
    }
    
    @State private var timer: Timer?
    
    private let ip = "172.20.10.1"
    
    init() {
        self.daqServerController = DDServer(address: ip, port: 8080, for: .daq, with: model)
        self.lordServerController = DDServer(address: ip, port: 8081, for: .lord, with: model)
        
        self.locationController = DDLocation(with: model)
    }
    
    var body: some View {
        
        HStack {
            VStack(spacing: 10) {
                // spacers to center in remaining space
                Spacer()
                
                ZStack(){
                    
                    VStack(alignment: .leading, spacing: 20) {
                        DataView(title: "Speed", value: model.speed, units: "m/s")
                        //DataView(title: "Power", value: model.power, units: "kW/h")
                    }
                    
                    Button(String(lapnum)) {
                                    lapnum += 1
                                }.buttonStyle(.borderedProminent)
                                .controlSize(.large)
                                .padding([.bottom], 40)
                                .padding([.leading], 200)
                    
                }
                
                HStack(spacing: 10) {
                                StopwatchUnit(timeUnit: minutes, timeUnitText: "MIN")
                                Text(":")
                                    .font(.system(size: 48))
                                    .offset(y: -18)
                                StopwatchUnit(timeUnit: seconds, timeUnitText: "SEC")
                            }
                
                HStack {
                    Button(action: {
                        if isRunning{
                            timer?.invalidate()
                        } else {
                            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { _ in
                                progressTime += 1
                            })
                        }
                        isRunning.toggle()
                    }) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 15.0)
                                .frame(width: 120, height: 50, alignment: .center)
                            
                            Text(isRunning ? "Stop" : "Start")
                                .font(.title)
                                .foregroundColor(.white)
                        }
                    }
                    
                    Button(action: {
                        progressTime = 0
                    }) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 15.0)
                                .frame(width: 120, height: 50, alignment: .center)
                                .foregroundColor(.gray)
                            
                            Text("Reset")
                                .font(.title)
                                .foregroundColor(.white)
                        }
                    }
                }
                
                Spacer()
                
                // connection indicators
                HStack(spacing: 50) {
                    Text("DAQ")
                        .foregroundColor(model.daqSocketConnected ? Color.green : Color.red)
                        .bold()
                    Text("LORD")
                        .foregroundColor(model.lordSocketConnected ? Color.green : Color.red)
                        .bold()
                    Text("Phone")
                        .foregroundColor(model.phoneConnected ? Color.green : Color.red)
                        .bold()
                }.padding([.bottom], 20)
            }
                .frame(maxWidth: .infinity)
            
            MapView()
                .frame(maxWidth: .infinity)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct StopwatchUnit: View {

    var timeUnit: Int
    var timeUnitText: String

    /// Time unit expressed as String.
    /// - Includes "0" as prefix if this is less than 10.
    var timeUnitStr: String {
        let timeUnitStr = String(timeUnit)
        return timeUnit < 10 ? "0" + timeUnitStr : timeUnitStr
    }

    var body: some View {
        VStack {
            ZStack {
                RoundedRectangle(cornerRadius: 15.0)
                    .stroke(style: StrokeStyle(lineWidth: 3, lineCap: .round))
                    .frame(width: 75, height: 75, alignment: .center)

                HStack(spacing: 2) {
                    Text(timeUnitStr.substring(index: 0))
                        .font(.system(size: 48))
                        .frame(width: 28)
                    Text(timeUnitStr.substring(index: 1))
                        .font(.system(size: 48))
                        .frame(width: 28)
                }
            }

            Text(timeUnitText)
                .font(.system(size: 16))
        }
    }
}

extension String {
    func substring(index: Int) -> String {
        let arrayString = Array(self)
        return String(arrayString[index])
    }
}
