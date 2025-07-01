import Foundation
import SwiftUI
import Combine
import CoreLocation

// RunningViewModel
class RunningViewModel: ObservableObject {
    public let appState = AppState.shared  // @StateObject 제거
    @Published private(set) var distanceMeter: Double = 0.0
    @Published private(set) var elapsedTime: (hours: Int, minutes: Int, seconds: Int) = (0, 0, 0)
    private var previousElapedSeconds: Int = 0
    private let timeManager = TimeManager()
    private let locationManager = LocationManager()
    public let statsManager = StatsManager()
    private let charactorMoveMentService: CharactorMoveMentService
    private var cancellables = Set<AnyCancellable>()
    
    // 복구 관련 상태
    @Published var showRecoveryAlert = false
    @Published var recoveryData: (distance: Double, duration: TimeInterval, locations: [LocationData])? = nil
    
    init() {
        charactorMoveMentService = CharactorMoveMentService.shared
        timeManager.$elapsedSeconds
            .sink { [weak self] _ in
                self?.updateStats()
            }
            .store(in: &cancellables)
        
        // 백그라운드 데이터 저장 설정
        setupBackgroundDataSaving()
        
        // 앱 시작 시 임시 데이터 확인
        checkForTempData()
    }
    
    var locationAuthStatus: String { locationManager.locationAuthStatus }
    var locationAccuracy: Double { locationManager.locationAccuracy }
    
    func startRunning() {
        appState.setRunningState(.Running)
        timeManager.start()
        locationManager.startTracking()
        charactorMoveMentService.moveCharactor(speed: 5.0)
    }
    
    func pauseRunning() {
        appState.setRunningState(.Paused)
        timeManager.pause()
        locationManager.pauseTracking()  // 위치 추적 일시정지
        charactorMoveMentService.stopCharactor()
    }
    
    func resumeRunning() {
        appState.setRunningState(.Running)
        timeManager.resume()
        locationManager.resumeTracking()  // 위치 추적 재개
        charactorMoveMentService.moveCharactor(speed: 5.0)
    }
    
    func stopRunning() {
        // 최종 데이터 저장
        saveRunningData()
        
        appState.setRunningState(.Stopped)
        timeManager.stop()
        locationManager.stopTracking()
        charactorMoveMentService.stopCharactor()
    }
    
    private func updateStats() {
        if appState.runningState == .Running {
            distanceMeter += locationManager.distanceDelta
            elapsedTime  = timeManager.elapsedTime
            
            if locationManager.isRecived {
                let durationSeconds = timeManager.elapsedSeconds - previousElapedSeconds
                statsManager.updateStats(distance: locationManager.distanceDelta, elapsedSeconds: durationSeconds)
                previousElapedSeconds = timeManager.elapsedSeconds
                locationManager.isRecived = false

                
                if locationManager.distanceDelta > 0 {
                    charactorMoveMentService.moveCharactor(speed: statsManager.speed)
                }
            }
        }
    }

    func addDistance(distance: Double) {
        self.distanceMeter += distance
    }
    
    // MARK: - 백그라운드 데이터 저장
    private func setupBackgroundDataSaving() {
        // LocationManager의 데이터 저장 콜백 설정
        locationManager.onDataSave = { [weak self] distance, locations in
            guard let self = self else { return }
            
            // 임시 데이터 저장
            RunningDataManager.shared.saveTempRunningData(
                distance: distance,
                duration: TimeInterval(self.timeManager.elapsedSeconds),
                locations: locations
            )
        }
    }
    
    // 임시 데이터 확인 및 복구
    private func checkForTempData() {
        if let tempData = RunningDataManager.shared.loadTempRunningData() {
            // 사용자에게 임시 데이터 복구 여부 묻기
            DispatchQueue.main.async { [weak self] in
                self?.recoveryData = tempData
                self?.showRecoveryAlert = true
                print("🔄 임시 저장된 러닝 데이터 발견: 거리 \(tempData.distance)m, 시간 \(tempData.duration)초")
            }
        }
    }
    
    // 데이터 복구 수락
    func acceptRecovery() {
        guard let recoveryData = recoveryData else { return }
        
        distanceMeter = recoveryData.distance
        // TimeManager에 복구 메서드 추가 필요
        // timeManager.setElapsedSeconds(Int(recoveryData.duration))
        
        // 복구 완료 후 임시 데이터 삭제
        RunningDataManager.shared.deleteTempData()
        self.recoveryData = nil
        self.showRecoveryAlert = false
    }
    
    // 데이터 복구 거절
    func declineRecovery() {
        RunningDataManager.shared.deleteTempData()
        self.recoveryData = nil
        self.showRecoveryAlert = false
    }
    
    // 러닝 종료 시 최종 데이터 저장
    func saveRunningData() {
        let allLocations = locationManager.getAllLocations()
        let locationData = allLocations.map { LocationData(from: $0) }
        
        // ID 생성을 위한 현재 시간 기반 ID
        let id = Int(Date().timeIntervalSince1970)
        
        let runningData = RunningRecordItem(
            id: id,
            distance: distanceMeter,
            cadence: 0, // TODO: 케이던스 데이터 추가 필요
            hartRate: statsManager.bpm,
            calories: Int(statsManager.calories),
            orderIndex: 0, // TODO: orderIndex 로직 추가 필요
            durationSec: TimeInterval(timeManager.elapsedSeconds),
            startTimestamp: Date().timeIntervalSince1970 - TimeInterval(timeManager.elapsedSeconds),
            locations: locationData
        )
        
        RunningDataManager.shared.saveRunningData(runningData)
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
        - 실행 상태: \(appState.runningState)
        - 총 거리: \(String(format: "%.2f", distanceMeter))m
        - 위치 권한: \(locationAuthStatus)
        - GPS 정확도: \(String(format: "%.2f", locationAccuracy))m
        """)
    }
}
