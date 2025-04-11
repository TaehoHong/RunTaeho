import CoreLocation

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