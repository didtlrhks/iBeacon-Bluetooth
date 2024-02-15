//
//  BeaconDebugger.swift
//  iOS-Bluetooth
//
//  Created by 양시관 on 2/11/24.
//

import Foundation

import Foundation
import CoreLocation
import SwiftUI


import Foundation

import Foundation
import CoreLocation
import SwiftUI


class BeaconDebugger: BeaconBase {
    @Published var currentBeacon: CLBeacon? = nil
    @Published var beaconInfo: [String: [BeaconHistoryItem]] = [:]
    var lastSeenBeacons: [String: Date] = [:]
        var disconnectTimers: [String: Timer] = [:]

        // 비콘의 연결 상태를 추적하는 딕셔너리
        var beaconConnectedStatus: [String: Bool] = [:]
   

    
//    override func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
//        if beacons.count > 0 {
//            updateDistance(beacons)
//        }
//    }
    override func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        super.locationManager(manager, didRangeBeacons: beacons, in: region)
        
        if beacons.isEmpty {
            for beaconKey in lastSeenBeacons.keys {
                handleDisconnectedBeacon(beaconKey: beaconKey)
            }
        }else {
            if beacons.count > 0 {
                updateDistance(beacons)
            }
    
    for beacon in beacons {
        let beaconKey = "\(beacon.proximityUUID.uuidString)-\(beacon.major)-\(beacon.minor)"
        lastSeenBeacons[beaconKey] = Date()

       
        disconnectTimers[beaconKey]?.invalidate()
        disconnectTimers[beaconKey] = nil

        // 새 타이머 설정
        disconnectTimers[beaconKey] = Timer.scheduledTimer(withTimeInterval: 60, repeats: false) { [weak self] _ in
            self?.notifyServerAboutBeaconDisconnect(beaconKey: beaconKey)
            self?.disconnectTimers[beaconKey] = nil
        }
    }
        }
          
    }
    func notifyServerAboutBeaconDisconnect(beaconKey: String) {
        // 여기에 비콘 연결 끊김 상태를 서버에 알리는 코드를 추가
        print("\(beaconKey) 연결 끊김")
        ServerCommunicator.sendBeaconDataToServer() // 메시지 내용을 적절히 조정해야 함
    }
    
    func handleConnectedBeacon(beacon: CLBeacon, beaconKey: String) {
            // 연결 상태 업데이트 및 "연결됨" 메시지 전송 로직
            if lastSeenBeacons[beaconKey] == nil || beaconConnectedStatus[beaconKey] == false {
                // 비콘과의 연결이 처음 감지되었거나, 다시 연결된 경우
                ServerCommunicator.sendBeaconDataToServer(beacon: beacon)
                beaconConnectedStatus[beaconKey] = true
            }

            // 연결 끊김 타이머 리셋
            resetDisconnectTimer(beaconKey: beaconKey)

            // 마지막으로 비콘을 감지한 시간 업데이트
            lastSeenBeacons[beaconKey] = Date()
        }

        func handleDisconnectedBeacon(beaconKey: String) {
            // 연결 끊김 상태를 처리하는 로직, 1분 후에 "연결 끊김" 메시지 전송
            if let lastSeenTime = lastSeenBeacons[beaconKey], -lastSeenTime.timeIntervalSinceNow >= 60 {
                if beaconConnectedStatus[beaconKey] ?? false {
                    ServerCommunicator.sendBeaconDataToServer() // "연결 끊김" 메시지 전송
                    beaconConnectedStatus[beaconKey] = false // 상태 업데이트
                }
            }
        }

        func resetDisconnectTimer(beaconKey: String) {
            disconnectTimers[beaconKey]?.invalidate()
            disconnectTimers[beaconKey] = Timer.scheduledTimer(withTimeInterval: 60, repeats: false) { [weak self] _ in
                self?.handleDisconnectedBeacon(beaconKey: beaconKey)
                self?.disconnectTimers[beaconKey] = nil
            }
        }
    
    func updateDistance(_ beacons: [CLBeacon]) {
        
        guard let closestBeacon = beacons.first else { return }
        currentBeacon = closestBeacon
        
        // 근접성에 따른 뷰를 보여주기위한 로직을 만듬
        for beacon in beacons {
            let beaconKey = "\(beacon.proximityUUID.uuidString)-\(beacon.major)-\(beacon.minor)"
            
            
            if let timer = disconnectTimers[beaconKey] {
                       timer.invalidate()
                       disconnectTimers[beaconKey] = nil
                       // 비콘 연결됨 상태를 서버에 알림 (새로운 메서드 필요)
                       notifyServerAboutBeaconConnect(beaconKey: beaconKey)
                   }
            
            // 근접성에 따라 서버로 데이터를 전송하고 다시는 보내지 않는 로직
            if beacon.proximity == .near && messageSentForBeacons[beaconKey] != true {
                ServerCommunicator.sendBeaconDataToServer(beacon: beacon)
                messageSentForBeacons[beaconKey] = true // 메시지 전송 후 상태 업데이트
            }
            
            
            // 비콘을 저장하고 있어야만 어떤 비콘이 반복인지를 알수가 있음
            for beacon in beacons {
                let key = "\(beacon.major)-\(beacon.minor)"
                if beaconInfo[key] == nil {
                    beaconInfo[key] = []
                }
                beaconInfo[key]?.append(BeaconHistoryItem(beacon: beacon))
            }
        }
    }
   
    func notifyServerAboutBeaconConnect(beaconKey: String) {
        print("\(beaconKey) 연결됨")
        // 서버로 "연결됨" 상태를 전송하는 코드 구현
        // ServerCommunicator.sendBeaconDataToServer()// 형태로 조정할 수 있음
    }

        
        func startScanning(beaconUUID: UUID, major: CLBeaconMajorValue? = nil, minor: CLBeaconMinorValue? = nil) {
            let constraint = CLBeaconIdentityConstraint(uuid: beaconUUID, major: major!, minor: minor!)
            let beaconRegion = CLBeaconRegion(beaconIdentityConstraint: constraint, identifier: "MyBeaconRegion")
            
            locationManager?.startMonitoring(for: beaconRegion)
            locationManager?.startRangingBeacons(satisfying: constraint)
        }
        
        func stopScanning(beaconUUID: UUID) {
            let constraint = CLBeaconIdentityConstraint(uuid: beaconUUID)
            let beaconRegion = CLBeaconRegion(beaconIdentityConstraint: constraint, identifier: "MyBeaconRegion")
            
            locationManager?.stopMonitoring(for: beaconRegion)
            locationManager?.stopRangingBeacons(satisfying: constraint)
        }
        
        struct BeaconHistoryItem: Identifiable {
            var id = UUID()
            var beacon: CLBeacon
        }
    }
