import Foundation
import Combine
import CoreLocation

// 위치 관리 클래스
class LocationManager: NSObject, CLLocationManagerDelegate {
    private var locationManager: CLLocationManager?
    private var previousLocation: CLLocation?
    @Published var distanceMeter: Double = 0.0
    @Published var locationAuthStatus: String = "권한 상태 확인 전"
    @Published var locationAccuracy: Double = 0.0
    
    override init() {
        super.init()
        setupLocationManager()
    }
    
    private func setupLocationManager() {
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        locationManager?.activityType = .fitness
        locationManager?.distanceFilter = 10
        locationManager?.requestWhenInUseAuthorization()
    }
    
    func startTracking() {
        locationManager?.startUpdatingLocation()
    }
    
    func stopTracking() {
        locationManager?.stopUpdatingLocation()
        previousLocation = nil
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        locationAccuracy = location.horizontalAccuracy
        
        if let previousLocation = previousLocation {
            let distance = location.distance(from: previousLocation)
            distanceMeter += distance
        }
        
        previousLocation = location
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse:
            locationAuthStatus = "위치 권한 허용됨"
        case .denied:
            locationAuthStatus = "위치 권한 거부됨"
        case .restricted:
            locationAuthStatus = "위치 권한 제한됨"
        case .notDetermined:
            locationAuthStatus = "위치 권한 결정되지 않음"
        case .authorizedAlways:
            locationAuthStatus = "항상 위치 권한 허용됨"
        @unknown default:
            locationAuthStatus = "알 수 없는 권한 상태"
        }
    }
}

// 통계 관리 클래스
class StatsManager {
    @Published var bpm: Int = 0
    @Published var pace: (minutes: Int, seconds: Int) = (0, 0)
    @Published var speed: Double = 0.0
    
    func updateStats(distance: Double, elapsedSeconds: Int) {
        print("distance: \(distance), elapsedSeconds: \(elapsedSeconds)")
        
        bpm = Int.random(in: 120...150)
        let paceSeconds = distance > 0 ? Int((Double(elapsedSeconds) / distance) * 1000) : 0
        pace.minutes = paceSeconds / 60
        pace.seconds = paceSeconds % 60
        speed = (distance / Double(elapsedSeconds)) * 3.6
    }
}

// RunningViewModel
class RunningViewModel: ObservableObject {
    @Published private(set) var runningStatus: eRunningStatus = .Stopped
    @Published private(set) var distanceMeter: Double = 0.0
    @Published private(set) var elapsedTime: (hours: Int, minutes: Int, seconds: Int) = (0, 0, 0)
    private let timeManager = TimeManager()
    private let locationManager = LocationManager()
    private let statsManager = StatsManager()
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        timeManager.$elapsedSeconds
            .sink { [weak self] _ in
                self?.updateStats()
            }
            .store(in: &cancellables)
    }
    
    var locationAuthStatus: String { locationManager.locationAuthStatus }
    var locationAccuracy: Double { locationManager.locationAccuracy }
    
    func startRunning() {
        runningStatus = .Running
        timeManager.start()
        locationManager.startTracking()
    }
    
    func pauseRunning() {
        runningStatus = .Paused
        timeManager.pause()
    }
    
    func resumeRunning() {
        runningStatus = .Running
        timeManager.resume()
    }
    
    func stopRunning() {
        runningStatus = .Stopped
        timeManager.stop()
        locationManager.stopTracking()
    }
    
    private func updateStats() {
        if runningStatus == .Running {
            distanceMeter = locationManager.distanceMeter
            elapsedTime = timeManager.elapsedTime
            statsManager.updateStats(distance: distanceMeter, elapsedSeconds: timeManager.elapsedSeconds)
        }
    }
}

// ===== 삭제된 RunningViewModel의 CLLocationManagerDelegate 구현 =====
// 기존 RunningViewModel의 CLLocationManagerDelegate 확장은 제거되었습니다.
// LocationManager가 모든 위치 업데이트와 Delegate 메서드를 처리합니다.
// ===================================================================

// 디버깅용 Extension
extension RunningViewModel {
    // 현재 상태 출력
    func printDebugStatus() {
        print("""
        🏃‍♂️ 러닝 상태:
        - 실행 상태: \(runningStatus)
        - 총 거리: \(String(format: "%.2f", distanceMeter))m
        - 위치 권한: \(locationAuthStatus)
        - GPS 정확도: \(String(format: "%.2f", locationAccuracy))m
        """)
    }
}
