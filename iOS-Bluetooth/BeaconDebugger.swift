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


class BeaconDebugger: BeaconBase {
    @Published var currentBeacon: CLBeacon? = nil
    @Published var beaconInfo: [String: [BeaconHistoryItem]] = [:]
    
    override func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        if beacons.count > 0 {
            updateDistance(beacons)
        }
    }
    
    func updateDistance(_ beacons: [CLBeacon]) {
        
        guard let closestBeacon = beacons.first else { return }
        currentBeacon = closestBeacon
        
        // 근접성에 따른 뷰를 보여주기위한 로직을 만듬
        for beacon in beacons {
            let beaconKey = "\(beacon.proximityUUID.uuidString)-\(beacon.major)-\(beacon.minor)"
            
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

