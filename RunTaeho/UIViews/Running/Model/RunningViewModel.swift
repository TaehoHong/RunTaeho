import Foundation
import SwiftUI
import Combine
import CoreLocation

// RunningViewModel
class RunningViewModel: ObservableObject {
    public let appState = AppState.shared  // @StateObject 제거
    @Published private(set) var distanceMeter: Double = 0.0
    @Published private(set) var elapsedTime: (hours: Int, minutes: Int, seconds: Int) = (0, 0, 0)
    @Published private(set) var currentSegmentCount: Int = 0
    
    private var previousElapedSeconds: Int = 0
    private let timeManager = TimeManager()
    private let locationManager = LocationManager()
    public let statsManager = StatsManager()
    private let unityService = UnityService.shared
    private let runningRecordService = RunningRecordService.shared
    private let runningRecordItemService = RunningRecordItemService.shared
    private let runningDataManager = RunningDataManager.shared
    
    private var cancellables = Set<AnyCancellable>()
    
    // 세그먼트 생성을 위한 변수들
    private var segmentStartTime: Date?
    private var segmentDistance: Double = 0.0
    private var segmentLocations: [LocationData] = []
    private let segmentDistanceThreshold: Double = 10.0 // 10m
    
    // 복구 관련 상태
    @Published var showRecoveryAlert = false
    @Published var recoveryData: (record: RunningRecord, segments: [RunningRecordItem])? = nil
    
    // 결과 화면 관련 상태
    @Published var finishedRunningRecord: RunningRecord? = nil
    @Published var earnedPoints: Int = 0
    
    init() {
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
        // 1. 서버에 startRunning() API 호출 (TODO: 실제 API 구현)
        startRunningOnServer { [weak self] record in
            DispatchQueue.main.async {
                self?.handleStartRunningResponse(record: record)
            }
        }
    }
    
    private func startRunningOnServer(completion: @escaping (RunningRecord) -> Void) {
        Task {
            let record = await runningRecordService.startRunning()
            
            DispatchQueue.main.async {
                completion(record)
            }
        }
    }
    
    private func handleStartRunningResponse(record: RunningRecord) {
        // 2. RunningDataManager에 새 세션 시작
        runningDataManager.startNewRunningSession(record: record)
        
        // 3. 러닝 시작
        appState.setRunningState(.Running)
        timeManager.start()
        locationManager.startTracking()
        unityService.moveCharactor(speed: 5.0)
        
        // 세그먼트 추적 초기화
        initializeSegmentTracking()
    }
    
    func pauseRunning() {
        appState.setRunningState(.Paused)
        timeManager.pause()
        locationManager.pauseTracking()  // 위치 추적 일시정지
        unityService.stopCharactor()
        
        print("⏸️ 러닝 일시정지")
    }
    
    func resumeRunning() {
        appState.setRunningState(.Running)
        timeManager.resume()
        locationManager.resumeTracking()  // 위치 추적 재개
        unityService.moveCharactor(speed: 5.0)
        
        // 세그먼트 추적 재개
        resumeSegmentTracking()
        
        print("▶️ 러닝 재개")
    }
    
    func stopRunning() {
        // 마지막 세그먼트 저장 (10m 미만이라도)
        finalizeCurrentSegment()
        
        // 러닝 세션 완료
        guard let (finalRecord, segments) = runningDataManager.finishRunningSession() else {
            print("❌ 러닝 세션 완료 실패")
            return
        }
        
        // 결과 화면 데이터 설정
        self.finishedRunningRecord = finalRecord
        
        Task { @MainActor in
            // 서버에 최종 데이터 전송
            let success = await uploadRunningDataToServer(record: finalRecord, segments: segments)
        
            if success {
                self.runningDataManager.saveCompletedRunningRecord(finalRecord, segments: segments)
                print("✅ 러닝 데이터 서버 업로드 및 로컬 저장 완료")
            } else {
                self.runningDataManager.saveCompletedRunningRecord(finalRecord, segments: segments)
                print("⚠️ 서버 업로드 실패, 로컬에만 저장됨")
            }
            
            // 결과 화면 상태로 전환
            self.appState.setRunningState(.Finished)
            self.timeManager.stop()
            self.locationManager.stopTracking()
            self.unityService.stopCharactor()
            
            print("🏁 러닝 종료")
        }
    }
    
    @MainActor
    private func uploadRunningDataToServer(record: RunningRecord, segments: [RunningRecordItem]) async -> Bool {
        // 1. runningRecordService.end를 await로 기다림 (동기적으로 처리)
        do {
            let endRunning = try await runningRecordService.end(runningRecord: record)
                self.earnedPoints = endRunning.point - UserStateManager.shared.totalPoint
                UserStateManager.shared.totalPoint = endRunning.point
        } catch {
            print("❌ 러닝 종료(end) 실패: \(error)")
            return false
        }

        // 2. runningRecordItemService.saveAll은 비동기로 호출 (기다리지 않음)
        Task.detached(priority: .background) {
            do {
                try await self.runningRecordItemService.saveAll(runningRecordId: record.id, items: segments)
                print("📤 세그먼트 비동기 업로드 완료")
            } catch {
                print("⚠️ 세그먼트 비동기 업로드 실패: \(error)")
            }
        }

        return true
    }
    
    private func updateStats() {
        if appState.runningState == .Running {
            elapsedTime = timeManager.elapsedTime
            
            if locationManager.isRecived {
                let durationSeconds = timeManager.elapsedSeconds - previousElapedSeconds
                statsManager.updateStats(distance: locationManager.distanceDelta, elapsedSeconds: durationSeconds)
                previousElapedSeconds = timeManager.elapsedSeconds
                locationManager.isRecived = false
                
                // 세그먼트에 거리 추가
                addDistanceToCurrentSegment(locationManager.distanceDelta)
                
                // 총 거리 업데이트
                distanceMeter += locationManager.distanceDelta
                
                if locationManager.distanceDelta > 0 {
                    unityService.moveCharactor(speed: statsManager.speed)
                }
            }
        }
    }
    
    // MARK: - 세그먼트 관리
    private func initializeSegmentTracking() {
        segmentStartTime = Date()
        segmentDistance = 0.0
        segmentLocations.removeAll()
        currentSegmentCount = 0
    }
    
    private func resumeSegmentTracking() {
        // 일시정지 후 재개 시 새로운 세그먼트 시작 시간 설정
        if segmentStartTime == nil {
            segmentStartTime = Date()
        }
    }
    
    private func addDistanceToCurrentSegment(_ distance: Double) {
        segmentDistance += distance
        
        // 현재 위치를 세그먼트에 추가
        if let currentLocation = locationManager.getCurrentLocation() {
            let locationData = LocationData(from: currentLocation)
            segmentLocations.append(locationData)
        }
        
        // 10m 달성 시 세그먼트 생성
        if segmentDistance >= segmentDistanceThreshold {
            createSegment()
        }
    }
    
    private func createSegment() {
        guard let startTime = segmentStartTime else { return }
        
        let segmentDuration = Date().timeIntervalSince(startTime)
        let segmentCalories = Int(statsManager.calories / max(1, Double(currentSegmentCount + 1))) // 현재까지 평균 칼로리
        
        runningDataManager.addRunningSegment(
            distance: segmentDistance,
            cadence: 0, // TODO: 실제 케이던스 데이터
            heartRate: statsManager.bpm,
            calories: segmentCalories,
            duration: segmentDuration,
            startTimestamp: startTime.timeIntervalSince1970,
            locations: segmentLocations
        )
        
        currentSegmentCount += 1
        
        // 다음 세그먼트를 위한 초기화
        segmentStartTime = Date()
        segmentDistance = 0.0
        segmentLocations.removeAll()
        
        print("📍 세그먼트 생성 완료: \(currentSegmentCount)번째")
    }
    
    private func finalizeCurrentSegment() {
        // 마지막에 10m 미만이라도 세그먼트로 저장
        if segmentDistance > 0, let startTime = segmentStartTime {
            let segmentDuration = Date().timeIntervalSince(startTime)
            let segmentCalories = Int(statsManager.calories / max(1, Double(currentSegmentCount + 1)))
            
            runningDataManager.addRunningSegment(
                distance: segmentDistance,
                cadence: 0,
                heartRate: statsManager.bpm,
                calories: segmentCalories,
                duration: segmentDuration,
                startTimestamp: startTime.timeIntervalSince1970,
                locations: segmentLocations
            )
            
            currentSegmentCount += 1
            print("📍 최종 세그먼트 생성: \(segmentDistance)m")
        }
    }

    func addDistance(distance: Double) {
        self.distanceMeter += distance
    }
    
    // MARK: - 백그라운드 데이터 저장
    private func setupBackgroundDataSaving() {
        // LocationManager의 데이터 저장 콜백 설정 (기존 호환성 유지)
        locationManager.onDataSave = { [weak self] distance, locations in
            // 새로운 시스템에서는 RunningDataManager가 자동으로 처리
            print("💾 백그라운드 데이터 저장 알림 수신")
        }
    }
    
    // 임시 데이터 확인 및 복구
    private func checkForTempData() {
        // 새로운 세션 복구 시스템
        if let tempSessionData = runningDataManager.loadTempSessionData() {
            DispatchQueue.main.async { [weak self] in
                self?.recoveryData = tempSessionData
                self?.showRecoveryAlert = true
                
                let totalDistance = tempSessionData.segments.reduce(0) { $0 + $1.distance }
                let totalDuration = tempSessionData.segments.reduce(0) { $0 + $1.durationSec }
                
                print("🔄 기존 러닝 세션이 있습니다")
                print("Record ID: \(tempSessionData.record.id)")
                print("거리: \(totalDistance/1000.0)km")
                print("시간: \(totalDuration)초")
                print("세그먼트 수: \(tempSessionData.segments.count)")
            }
        }
    }
    
    // 데이터 복구 수락
    func acceptRecovery() {
        guard let recoveryData = recoveryData else { return }
        
        // 세션 복원
        runningDataManager.restoreSession(record: recoveryData.record, segments: recoveryData.segments)
        
        // UI 상태 복원
        let totalDistance = recoveryData.segments.reduce(0) { $0 + $1.distance }
        let totalDuration = recoveryData.segments.reduce(0) { $0 + $1.durationSec }
        
        distanceMeter = totalDistance
        currentSegmentCount = recoveryData.segments.count
        
        // 세그먼트 추적 재개 준비
        segmentDistance = 0.0
        segmentLocations.removeAll()
        segmentStartTime = nil // resumeRunning에서 설정됨
        
        // 복구 완료
        self.recoveryData = nil
        self.showRecoveryAlert = false
        
        print("✅ 세션 복구 완료: 거리 \(totalDistance)m, 세그먼트 \(recoveryData.segments.count)개")
    }
    
    // 데이터 복구 거절
    func declineRecovery() {
        runningDataManager.deleteTempData()
        self.recoveryData = nil
        self.showRecoveryAlert = false
        
        print("❌ 세션 복구 거절")
    }
    
    // MARK: - 현재 세션 정보
    
    func getCurrentSessionSummary() -> (distance: Double, segments: Int, duration: TimeInterval)? {
        return runningDataManager.getCurrentSessionSummary()
    }
    
    func getCurrentSegments() -> [RunningRecordItem] {
        return runningDataManager.getCurrentSegments()
    }
    
    func hasActiveSession() -> Bool {
        return runningDataManager.hasActiveSession()
    }
    
    func resetToStopped() {
        appState.setRunningState(.Stopped)
        
        // UI 상태 초기화
        distanceMeter = 0.0
        currentSegmentCount = 0
        finishedRunningRecord = nil
        earnedPoints = 0
        
        print("🔄 러닝 상태 초기화")
    }
}



// 디버깅용 Extension
extension RunningViewModel {
    // 현재 상태 출력
    func printDebugStatus() {
        let sessionSummary = getCurrentSessionSummary()
        
        print("""
        🏃‍♂️ 러닝 상태:
        - 실행 상태: \(appState.runningState)
        - 총 거리: \(String(format: "%.2f", distanceMeter))m
        - 현재 세그먼트 수: \(currentSegmentCount)
        - 위치 권한: \(locationAuthStatus)
        - GPS 정확도: \(String(format: "%.2f", locationAccuracy))m
        - 활성 세션: \(hasActiveSession())
        - 세션 요약: \(sessionSummary?.distance ?? 0)m, \(sessionSummary?.segments ?? 0)개 세그먼트
        """)
    }
}
