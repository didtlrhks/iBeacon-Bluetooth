import Foundation
import CoreLocation

import Foundation
import CoreLocation


// 비콘 관련 이벤트를 처리하기 위한 기본 클래스
class BeaconBase: NSObject, ObservableObject, CLLocationManagerDelegate {
    // 위치 관리자 인스턴스
    var locationManager: CLLocationManager?
    
    // 비콘별로 메시지가 전송되었는지 추적하는 딕셔너리
    var messageSentForBeacons = [String: Bool]()

    // 초기화 메서드
    override init() {
        super.init()
        locationManager = CLLocationManager()
        locationManager?.delegate = self // 델리게이트 설정
        locationManager?.requestWhenInUseAuthorization() // 위치 서비스 사용 권한 요청
        locationManager?.allowsBackgroundLocationUpdates = true // 백그라운드 위치 업데이트 허용
        locationManager?.startUpdatingLocation() // 위치 업데이트 시작
    }

    // 위치 서비스 사용 권한이 변경되었을 때 호출되는 메서드
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways || status == .authorizedWhenInUse {
            // 비콘 모니터링이 가능한지와 범위 측정이 가능한지 확인
            guard CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self),
                  CLLocationManager.isRangingAvailable() else {
                BeaconBase.beaconsWereNotGivenPermission() // 권한이 없으면 오류 메시지 출력
                return
            }
        } else {
            BeaconBase.beaconsWereNotGivenPermission() // 권한이 없으면 오류 메시지 출력
        }
    }

    // 비콘 범위 내에 있는 비콘을 감지했을 때 호출되는 메서드
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        for beacon in beacons {
            // 비콘을 식별하기 위한 고유 키 생성
            let beaconKey = "\(beacon.proximityUUID.uuidString)-\(beacon.major)-\(beacon.minor)"
            
            // 해당 비콘에 대해 메시지가 아직 전송되지 않았다면 서버로 데이터 전송
            if messageSentForBeacons[beaconKey] != true {
                ServerCommunicator.sendBeaconDataToServer(beacon: beacon)
                
                // 메시지 전송 여부를 true로 설정
                messageSentForBeacons[beaconKey] = true
            }
        }
    }
    
    // 비콘에 권한이 주어지지 않았을 때 호출되는 메서드
    private static func beaconsWereNotGivenPermission() {
        print("Beacons not given permission!")
    }

    // 비콘의 근접도를 문자열로 변환하는 메서드
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
