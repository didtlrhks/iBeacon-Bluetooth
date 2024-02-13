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
            
            Button("Send Data to Server") {
                if let beacon = beaconDetector.currentBeacon {
                    // 현재 감지된 비콘 정보를 서버로 전송
                    ServerCommunicator.sendBeaconDataToServer(beacon: beacon)
                } else {
                    // 현재 감지된 비콘 없음: 대체 동작 또는 오류 처리
                    print("No beacon detected to send.")
                }
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(5)
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
