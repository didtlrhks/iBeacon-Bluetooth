//
//  ServerCommunicator.swift
//  iOS-Bluetooth
//
//  Created by 양시관 on 2/12/24.
//

import Foundation
import SwiftUI
import CoreLocation

class ServerCommunicator {
   
   static func sendBeaconDataToServer(beacon: CLBeacon? = nil) {
            guard let url = URL(string: "https://workapi.neo-works.co.kr/api/Job/SmsTestRequest") else { return }
            
            // 요청 바디를 구성
       let requestBody : [String : Any]
       if let beacon = beacon {
           requestBody = [
        "발송문구": "비콘 근접함 - Major: \(beacon.major), Minor: \(beacon.minor)",
        "발송번호": "027621162",
        "수신번호": "01087674752",
        "업체코드": "075",
        "mmS여부": "1"
       ]
       } else {
           requestBody = [
           "발송문구": "비콘의 연결이 끊어졌습니다. ",
           "발송번호": "027621162",
           "수신번호": "01087674752",
           "업체코드": "075",
           "mmS여부": "1"
           ] // 연결이 끊겼을때 메세지를 보내는 로직추가함
       }
            
            // joson 요청 코드
       var request = URLRequest(url: url)
              request.httpMethod = "POST"
              request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            
       do {
                  request.httpBody = try JSONSerialization.data(withJSONObject: requestBody, options: [])
              } catch {
                  print("Error: Cannot create JSON from requestBody")
                  return
              }
            
            // URLSession을 사용하여 요청 전송하기
            URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("Request error: ", error)
                    return
                }
                
                guard let data = data else {
                    print("No data returned")
                    return
                }
                
                // 결과 로직 확인하기위한소스
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
