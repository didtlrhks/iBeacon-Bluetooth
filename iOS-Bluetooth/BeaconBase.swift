//
//  BeaconBase.swift
//  iOS-Bluetooth
//
//  Created by 양시관 on 2/11/24.
//

import Foundation

import Foundation
import CoreLocation
 
class BeaconBase: NSObject, ObservableObject, CLLocationManagerDelegate {
    var locationManager: CLLocationManager?
    override init(){
        super.init()
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.requestWhenInUseAuthorization()
        self.locationManager?.allowsBackgroundLocationUpdates = true
        self.locationManager?.startUpdatingLocation()
    }
    
    
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways || status == .authorizedWhenInUse {
            guard CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self) else {return BeaconBase.beaconsWereNotGivenPermission()}
            guard CLLocationManager.isRangingAvailable() else {return BeaconBase.beaconsWereNotGivenPermission()}
        }else {
            BeaconBase.beaconsWereNotGivenPermission()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
    }
    
    private static func beaconsWereNotGivenPermission(){
       
        print("beacons not given permisison!")
    }
 
 static func translateProximity(_ distance: CLProximity)->String {
        print("translate proximity")
         switch distance {
         case .unknown:
             return "Unknown"
         case .far:
             return "멀다"
         case .near:
             return "가깝다"
         case .immediate:
             return "Immediate"
         default:
             return "Default"
         }
     }
 
    
}

