import Foundation
import Combine
import UIKit

class TimeManager: ObservableObject {
    @Published private(set) var elapsedSeconds: Int = 0
    private var timer: Timer?
    private var startTime: Date?
    private var pausedTime: TimeInterval = 0
    private var backgroundTaskId: UIBackgroundTaskIdentifier = .invalid
    
    init() {
        setupNotifications()
    }
    
    var elapsedTime: (hours: Int, minutes: Int, seconds: Int) {
        let hours = elapsedSeconds / 3600
        let minutes = (elapsedSeconds % 3600) / 60
        let seconds = elapsedSeconds % 60
        return (hours, minutes, seconds)
    }
    
    func start() {
        reset()
        startTime = Date()
        startTimer()
    }
    
    func pause() {
        if let startTime = startTime {
            pausedTime += Date().timeIntervalSince(startTime)
        }
        stopTimer()
        startTime = nil
    }
    
    func resume() {
        startTime = Date()
        startTimer()
    }
    
    func stop() {
        stopTimer()
        reset()
    }
    
    private func reset() {
        elapsedSeconds = 0
        pausedTime = 0
        startTime = nil
    }
    
    private func startTimer() {
        timer?.invalidate()
        
        // 초기 업데이트
        updateElapsedTime()
        
        // 1초마다 UI 업데이트
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateElapsedTime()
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func updateElapsedTime() {
        guard let startTime = startTime else { return }
        
        let currentElapsed = Date().timeIntervalSince(startTime) + pausedTime
        elapsedSeconds = Int(currentElapsed)
    }
    
    // MARK: - Background Handling
    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appDidEnterBackground),
            name: UIApplication.didEnterBackgroundNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appWillEnterForeground),
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )
    }
    
    @objc private func appDidEnterBackground() {
        guard startTime != nil else { return }
        
        // 백그라운드 작업 시작
        backgroundTaskId = UIApplication.shared.beginBackgroundTask { [weak self] in
            self?.endBackgroundTask()
        }
        
        // 타이머 중지 (백그라운드에서는 실행되지 않음)
        stopTimer()
    }
    
    @objc private func appWillEnterForeground() {
        guard startTime != nil else { return }
        
        // 경과 시간 업데이트
        updateElapsedTime()
        
        // 타이머 재시작
        startTimer()
        
        // 백그라운드 작업 종료
        endBackgroundTask()
    }
    
    private func endBackgroundTask() {
        if backgroundTaskId != .invalid {
            UIApplication.shared.endBackgroundTask(backgroundTaskId)
            backgroundTaskId = .invalid
        }
    }
    
    deinit {
        stopTimer()
        NotificationCenter.default.removeObserver(self)
    }
} 