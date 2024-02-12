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
                           self.sendBeaconDataToServer()
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
    
    func sendBeaconDataToServer() {
            guard let url = URL(string: "https://workapi.neo-works.co.kr/api/Job/SmsTestRequest") else { return }
            
            // 요청 바디를 구성
            let requestBody = [
                "발송문구": "양시관TEST",
                "발송번호": "027621162",
                "수신번호": "01090031125",
                "업체코드": "075",
                "mmS여부": "1"
            ]
            
            // 요청을 구성
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: requestBody, options: [])
            } catch {
                print("Error: Cannot create JSON from requestBody")
                return
            }
            
            // URLSession을 사용하여 요청 전송
            URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("Request error: ", error)
                    return
                }
                
                guard let data = data else {
                    print("No data returned")
                    return
                }
                
                // 결과 처리
                do {
                    if let jsonResult = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        print("Response JSON: ", jsonResult)
                        // 여기서 결과에 따른 추가적인 로직을 구현할 수 있습니다.
                    }
                } catch {
                    print("JSON Parsing Error")
                }
            }.resume()
        }
}




 
struct IbeaconView_Previews: PreviewProvider {
    static var previews: some View {
        IbeaconView()
    }
}
