import Foundation
import CoreLocation

import Foundation
import CoreLocation

class BeaconBase: NSObject, ObservableObject, CLLocationManagerDelegate {
    var locationManager: CLLocationManager?
    // 비콘별 메시지 전송 여부를 추적하는 딕셔너리
    var messageSentForBeacons = [String: Bool]()

    override init() {
        super.init()
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.requestWhenInUseAuthorization()
        locationManager?.allowsBackgroundLocationUpdates = true
        locationManager?.startUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways || status == .authorizedWhenInUse {
            guard CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self) else {
                BeaconBase.beaconsWereNotGivenPermission()
                return
            }
            guard CLLocationManager.isRangingAvailable() else {
                BeaconBase.beaconsWereNotGivenPermission()
                return
            }
        } else {
            BeaconBase.beaconsWereNotGivenPermission()
        }
    }

    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
         for beacon in beacons {
             let beaconKey = "\(beacon.proximityUUID.uuidString)-\(beacon.major)-\(beacon.minor)"

            
             if messageSentForBeacons[beaconKey] != true {
                 ServerCommunicator.sendBeaconDataToServer(beacon: beacon)
                
                 messageSentForBeacons[beaconKey] = true
             }
         }
     }
    

    private static func beaconsWereNotGivenPermission() {
        print("Beacons not given permission!")
    }


    static func translateProximity(_ distance: CLProximity) -> String {
        switch distance {
        case .unknown: return "잘몰르겠어"
        case .far: return "멀다"
        case .near: return "가깝다"
        case .immediate: return "바로옆!"
        default: return "그냥"
        }
    }
}
