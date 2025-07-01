import CoreLocation
import Combine

class LocationManager: NSObject, CLLocationManagerDelegate {
    private var locationManager: CLLocationManager?
    private var previousLocation: CLLocation?
    public var isRecived: Bool = false
    @Published var distanceDelta: Double = 0.0
    @Published var locationAuthStatus: String = "권한 상태 확인 전"
    @Published var locationAccuracy: Double = 0.0
    
    // 백그라운드 데이터 저장을 위한 프로퍼티
    private var allLocations: [CLLocation] = []
    private var totalDistance: Double = 0.0
    private var lastSaveTime: Date = Date()
    private let saveInterval: TimeInterval = 30.0 // 30초마다 저장
    
    // 데이터 저장 콜백
    var onDataSave: ((Double, [CLLocation]) -> Void)?
    
    // 위치 추적 상태
    private var isTracking: Bool = false
    
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
        
        // 백그라운드 위치 업데이트 설정
        locationManager?.allowsBackgroundLocationUpdates = true
        locationManager?.pausesLocationUpdatesAutomatically = false
        locationManager?.showsBackgroundLocationIndicator = true
        
        // 권한 요청 (Always 권한이 필요함)
        if locationManager?.authorizationStatus == .notDetermined {
            locationManager?.requestAlwaysAuthorization()
        } else if locationManager?.authorizationStatus == .authorizedWhenInUse {
            locationManager?.requestAlwaysAuthorization()
        }
    }
    
    func startTracking() {
        allLocations.removeAll()
        totalDistance = 0.0
        lastSaveTime = Date()
        isTracking = true
        locationManager?.startUpdatingLocation()
    }
    
    func pauseTracking() {
        isTracking = false
        // 위치 업데이트는 계속 받지만 처리하지 않음
    }
    
    func resumeTracking() {
        isTracking = true
        lastSaveTime = Date()  // 저장 타이머 리셋
    }
    
    func stopTracking() {
        locationManager?.stopUpdatingLocation()
        previousLocation = nil
        
        // 마지막 데이터 저장
        if !allLocations.isEmpty {
            onDataSave?(totalDistance, allLocations)
        }
    }
    
    // 현재까지의 모든 위치 데이터 반환
    func getAllLocations() -> [CLLocation] {
        return allLocations
    }
    
    // 총 거리 반환
    func getTotalDistance() -> Double {
        return totalDistance
    }
    
    // 현재 위치 반환
    func getCurrentLocation() -> CLLocation? {
        return allLocations.last
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        locationAccuracy = location.horizontalAccuracy
        
        // pause 상태에서는 위치 업데이트 무시
        guard isTracking else { return }
        
        // 유효한 위치만 처리 (정확도 20m 이내)
        guard location.horizontalAccuracy > 0 && location.horizontalAccuracy <= 20 else { return }
        
        // 위치 저장
        allLocations.append(location)
        
        if let previousLocation = previousLocation {
            let distance = location.distance(from: previousLocation)
            distanceDelta = distance
            totalDistance += distance
            isRecived = true
        }
        
        previousLocation = location
        
        // 주기적으로 데이터 저장 (백그라운드에서도 동작)
        let timeSinceLastSave = Date().timeIntervalSince(lastSaveTime)
        if timeSinceLastSave >= saveInterval {
            onDataSave?(totalDistance, allLocations)
            lastSaveTime = Date()
            print("💾 백그라운드 데이터 저장: 거리 \(totalDistance)m, 위치 갯수 \(allLocations.count)")
        }
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