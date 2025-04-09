import Foundation
import Combine

class RunningViewModel: ObservableObject {
    @Published private(set) var runningStatus: eRunningStatus = .Stopped
    @Published private(set) var bpm: Int = 0
    @Published private(set) var distanceMeter: Double = 0.0
    @Published private(set) var distanceInTenMeters: Double = 0.0
    @Published private(set) var paceStartSeconds: Int = 0
    @Published private(set) var paceEndSeconds: Int = 0
    @Published private(set) var pace: (minutes: Int, seconds: Int) = (0, 0)
    
    private let timeManager = TimeManager()
    private var cancellables = Set<AnyCancellable>()
    
    init() {
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
        resetStats()
    }
    
    // MARK: - Stats Update
    private func updateStats() {
        // 여기서 실제 데이터 업데이트 로직 구현
        // 예: BPM 계산, 거리 측정, 페이스 계산 등
        if runningStatus == .Running {
            // 임시로 더미 데이터로 구현
            bpm = Int.random(in: 120...150)
            let distance = 2.777777777778
            distanceMeter += distance
            distanceInTenMeters += distance
            print("distanceInTenMeters: \(distanceInTenMeters)")
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
            let paceSeconds = Int((Double(paceEndSeconds - paceStartSeconds) / distanceInTenMeters) * 1000) // 1km 기준으로 계산
            pace.minutes = paceSeconds / 60
            pace.seconds = paceSeconds % 60
        }
    }
    
    private func resetStats() {
        bpm = 0
        distanceMeter = 0.00
        pace = (0, 0)
    }
} 