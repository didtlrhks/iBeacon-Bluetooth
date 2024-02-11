//
//  IBeaconView.swift
//  iOS-Bluetooth
//
//  Created by 양시관 on 2/11/24.
//

import Foundation

import SwiftUI

struct IbeaconView: View {
    let beaconUUID = UUID(uuidString: "ABCDEF12-1234-5678-8765-432190031125")!
    @ObservedObject private var beaconDetector = BeaconDebugger()

    var body: some View {
        VStack(alignment: .center) {
            Text(beaconDetector.currentBeacon?.uuid.uuidString ?? "unknown")
            Text(BeaconDebugger.translateProximity(beaconDetector.currentBeacon?.proximity ?? .unknown))
                .font(.largeTitle)
                .padding()
            Text(String(beaconDetector.currentBeacon?.rssi ?? -1))
            Text("major : 4660")
            Text("minor : 64001")
//            ForEach(["2", "3", "4"], id: \.self) { key in
//                if let beacons = beaconDetector.beaconInfo[key], !beacons.isEmpty {
//                    Section(header: Text("Major Value: \(key)")) {
//                        ForEach(beacons) { item in
//                            beaconDetailRow(item: item)
//                        }
//                    }
//                }
//            }
        }
        .onAppear(perform: startScanning)
        .onDisappear(perform: stopScanning)
    }
    
    func beaconDetailRow(item: BeaconDebugger.BeaconHistoryItem) -> some View {
        VStack(alignment: .leading) {
            Text("UUID: \(item.beacon.uuid.uuidString)")
            Text("Proximity: \(BeaconDebugger.translateProximity(item.beacon.proximity))")
            Text("Major: \(item.beacon.major.intValue)")
            Text("Minor: \(item.beacon.minor.intValue)")
            Text("RSSI: \(item.beacon.rssi)")
        }
        .padding()
    }
    
    
    func startScanning(){
        beaconDetector.startScanning(beaconUUID: beaconUUID ,major: 4660,minor: 64001)
    }
    
    func stopScanning(){
        beaconDetector.stopScanning(beaconUUID: beaconUUID)
    }
}




 
struct IbeaconView_Previews: PreviewProvider {
    static var previews: some View {
        IbeaconView()
    }
}
