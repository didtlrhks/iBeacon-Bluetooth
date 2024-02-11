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
// 
//class BeaconDebugger: BeaconBase {
//    @Published var currentBeacon : CLBeacon? = nil
//    @Published var beaconInfo : [
//        String : [BeaconHistoryItem]
//    ] = [:]
//    override init(){
//        super.init()
//    }
//    
//    override func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
//        if beacons.count > 0 {
//            updateDistance(beacons)
//        } else {
//            
//        }
//    }
//    
//    func updateDistance(_ beacons: [CLBeacon]) {
//        currentBeacon = beacons[0]
//        // ensure we only add a value to the history list if there has been a change in rssi
//        for beacon in beacons{
//            beaconInfo["\(beacon.major)"] = [BeaconHistoryItem(beacon: beacon)]
//        }
//    }
//    
//    func startScanning(beaconUUID: UUID) {
//        let beaconRegion = CLBeaconRegion()
//        locationManager?.startMonitoring(for: beaconRegion)
//        locationManager?.startRangingBeacons(satisfying: .init(uuid: beaconUUID))
//    }
//    
//    func stopScanning(beaconUUID: UUID){
//        let beaconRegion = CLBeaconRegion()
//        locationManager?.stopMonitoring(for: beaconRegion)
//        locationManager?.stopRangingBeacons(satisfying: .init(uuid: beaconUUID))
//    }
//    
//    struct BeaconHistoryItem : Identifiable {
//        var id = UUID()
//        var beacon: CLBeacon
//    }
//}
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
        currentBeacon = beacons[0]
        for beacon in beacons {
            let key = "\(beacon.major)-\(beacon.minor)"
            beaconInfo[key] = [BeaconHistoryItem(beacon: beacon)]
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
