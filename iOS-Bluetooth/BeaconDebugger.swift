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
        for beacon in beacons {
            let beaconKey = "\(beacon.proximityUUID.uuidString)-\(beacon.major)-\(beacon.minor)"
            
           
            if beacon.proximity == .near && messageSentForBeacons[beaconKey] != true {
                ServerCommunicator.sendBeaconDataToServer(beacon: beacon)
                messageSentForBeacons[beaconKey] = true
            }
            
           
            if beaconInfo[beaconKey] == nil {
                beaconInfo[beaconKey] = []
            }
            beaconInfo[beaconKey]?.append(BeaconHistoryItem(beacon: beacon))
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
