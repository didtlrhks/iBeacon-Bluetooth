import Foundation
import CoreLocation

class BeaconBase: NSObject, ObservableObject, CLLocationManagerDelegate {
    var locationManager: CLLocationManager?
    // 각 비콘의 인식 상태를 저장하는 딕셔너리 (true: 인식됨, false: 연결 끊김)
    var beaconStates = [String: Bool]()

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
            
            // 비콘 신호가 인식되었고, 이전에 인식되지 않았거나 연결이 끊겼던 경우
            if beacon.proximity == .near || beacon.proximity == .immediate {
                if let wasSeen = beaconStates[beaconKey] {
                    if !wasSeen {
                        // 연결이 끊겼다가 다시 연결된 경우
                        ServerCommunicator.sendBeaconDataToServer(beacon: beacon)
                    }
                    // 이미 인식되어 있었고, 연결 상태가 유지되는 경우는 여기서 처리하지 않음
                } else {
                    // 처음 인식된 경우
                    ServerCommunicator.sendBeaconDataToServer(beacon: beacon)
                }
                beaconStates[beaconKey] = true
            }
        }

        // 탐지되지 않은 비콘들은 상태를 false로 설정하여 연결 끊김 처리
        beaconStates.keys.forEach { key in
            if !beacons.contains(where: { "\($0.proximityUUID.uuidString)-\($0.major)-\($0.minor)" == key }) {
                beaconStates[key] = false
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
