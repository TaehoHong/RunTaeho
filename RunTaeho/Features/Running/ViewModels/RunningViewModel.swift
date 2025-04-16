import Foundation
import Combine
import CoreLocation

// RunningViewModel
class RunningViewModel: ObservableObject {
    @Published private(set) var runningStatus: eRunningStatus = .Stopped
    @Published private(set) var distanceMeter: Double = 0.0
    @Published private(set) var elapsedTime: (hours: Int, minutes: Int, seconds: Int) = (0, 0, 0)
    private var previousElapedSeconds: Int = 0
    private let timeManager = TimeManager()
    private let locationManager = LocationManager()
    public let statsManager = StatsManager()
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
            elapsedTime  = timeManager.elapsedTime
            
            if locationManager.isRecived {
                let durationSeconds = timeManager.elapsedSeconds - previousElapedSeconds
                statsManager.updateStats(distance: locationManager.distanceDelta, elapsedSeconds: durationSeconds)
                previousElapedSeconds = timeManager.elapsedSeconds
                locationManager.isRecived = false

                
                if locationManager.distanceDelta > 0 {
                    let adjustedSpeed: Double
                    if statsManager.speed >= 17 {
                        adjustedSpeed = 7
                    } else if statsManager.speed <= 7 {
                        adjustedSpeed = 3
                    } else {
                        let speedDifference = statsManager.speed - 7
                        let speedAdjustment = Double(speedDifference) * 0.4
                        adjustedSpeed = 3 + speedAdjustment
                    }
                    print("speed: \(statsManager.speed)")
                    print("adjustedSpeed: \(adjustedSpeed)")
                    Unity.shared.sendMessage("Charactor", methodName: "SetSpeed", parameter: String(adjustedSpeed))
                }
            }
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
