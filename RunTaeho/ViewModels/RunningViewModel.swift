import Foundation
import Combine
import CoreLocation

class RunningViewModel: NSObject, ObservableObject {
    @Published private(set) var runningStatus: eRunningStatus = .Stopped
    @Published private(set) var bpm: Int = 0
    @Published private(set) var distanceMeter: Double = 0.0
    @Published private(set) var distanceInTenMeters: Double = 0.0
    @Published private(set) var distance: Double = 0.0
    @Published private(set) var paceStartSeconds: Int = 0
    @Published private(set) var paceEndSeconds: Int = 0
    @Published private(set) var pace: (minutes: Int, seconds: Int) = (0, 0)
    @Published private(set) var speed: Double = 0.0 // Km/h
    
    // 디버깅을 위한 추가 프로퍼티
    @Published private(set) var lastLocationUpdate: String = "위치 업데이트 없음"
    @Published private(set) var locationAuthStatus: String = "권한 상태 확인 전"
    @Published private(set) var locationAccuracy: Double = 0.0
    
    private let timeManager = TimeManager()
    private var cancellables = Set<AnyCancellable>()
    private var locationManager: CLLocationManager?
    private var previousLocation: CLLocation?
    
    override init() {
        super.init()
        setupLocationManager()
        // TimeManager의 시간 변경을 구독
        timeManager.$elapsedSeconds
            .sink { [weak self] _ in
                self?.updateStats()
            }
            .store(in: &cancellables)
    }
    
    var elapsedTime: (hours: Int, minutes: Int, seconds: Int) {
        timeManager.elapsedTime
    }
    
    // MARK: - Running Control
    func startRunning() {
        runningStatus = .Running
        timeManager.start()
        startTracking()
    }
    
    func pauseRunning() {
        runningStatus = .Paused
        Unity.shared.sendMessage("Charactor", methodName: "SetSpeed", parameter: "0")
        timeManager.pause()
    }
    
    func resumeRunning() {
        runningStatus = .Running
        timeManager.resume()
    }
    
    func stopRunning() {
        runningStatus = .Stopped
        timeManager.stop()
        resetStats()
        stopTracking()
    }
    
    // MARK: - Stats Update
    private func updateStats() {
        // 여기서 실제 데이터 업데이트 로직 구현
        // 예: BPM 계산, 거리 측정, 페이스 계산 등
        if runningStatus == .Running {
            // 임시로 더미 데이터로 구현
            bpm = Int.random(in: 120...150)
            if distanceInTenMeters >= 10 {
                paceEndSeconds = timeManager.elapsedSeconds
                updatePace()
                paceStartSeconds = timeManager.elapsedSeconds
                distanceInTenMeters = 0
            }
        }
    }
    
    private func updatePace() {
        if distanceMeter > 0 {
            let elapsedSeconds = Double(paceEndSeconds - paceStartSeconds)
            let paceSeconds = Int((elapsedSeconds / distanceInTenMeters) * 1000) // 1km 기준으로 계산
            pace.minutes = paceSeconds / 60
            pace.seconds = paceSeconds % 60
            speed = (distanceInTenMeters / elapsedSeconds) * 3.6 // km/h로 변환

            let adjustedSpeed: Double
            if speed >= 17 {
                adjustedSpeed = 7
            } else if speed <= 7 {
                adjustedSpeed = 3
            } else {
                adjustedSpeed = 3 + (speed - 7) * (4 / 10)
            }
            print("speed: \(speed)")
            print("adjustedSpeed: \(adjustedSpeed)")
            
            Unity.shared.sendMessage("Charactor", methodName: "SetSpeed", parameter: String(adjustedSpeed))
        }
    }
    
    private func resetStats() {
        bpm = 0
        distanceMeter = 0.00
        pace = (0, 0)
    }
    
    private func setupLocationManager() {
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        locationManager?.activityType = .fitness
        locationManager?.distanceFilter = 10 // 10미터마다 업데이트
        
        // 위치 권한 요청
        locationManager?.requestWhenInUseAuthorization()
        
        // 현재 권한 상태 확인
        updateLocationAuthStatus()
    }
    
    private func updateLocationAuthStatus() {
        guard let manager = locationManager else { return }
        
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
        
        print("📍 위치 권한 상태: \(locationAuthStatus)")
    }
    
    func startTracking() {
        locationManager?.startUpdatingLocation()
    }
    
    func stopTracking() {
        locationManager?.stopUpdatingLocation()
        previousLocation = nil
    }
}

// CLLocationManagerDelegate 구현
extension RunningViewModel: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        // 위치 정확도 업데이트
        locationAccuracy = location.horizontalAccuracy
        
        if let previousLocation = previousLocation {
            let distance = location.distance(from: previousLocation)
            distanceMeter += distance
            distanceInTenMeters += distance
            
            // 디버깅 정보 출력
            let timestamp = DateFormatter.localizedString(from: location.timestamp, dateStyle: .none, timeStyle: .medium)
            lastLocationUpdate = """
            시간: \(timestamp)
            위도: \(location.coordinate.latitude)
            경도: \(location.coordinate.longitude)
            정확도: \(location.horizontalAccuracy)m
            거리: +\(String(format: "%.2f", distance))m
            총거리: \(String(format: "%.2f", distanceMeter))m
            """
            
            // print("📍 위치 업데이트:")
            // print(lastLocationUpdate)
        }
        
        previousLocation = location
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        let errorMessage = "위치 오류: \(error.localizedDescription)"
        print("❌ \(errorMessage)")
        lastLocationUpdate = errorMessage
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        updateLocationAuthStatus()
    }
}

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
        - 마지막 업데이트: \(lastLocationUpdate)
        """)
    }
} 