import Foundation
import Combine

class TimeManager: ObservableObject {
    @Published private(set) var elapsedSeconds: Int = 0
    private var timer: Timer?
    
    var elapsedTime: (hours: Int, minutes: Int, seconds: Int) {
        let hours = elapsedSeconds / 3600
        let minutes = (elapsedSeconds % 3600) / 60
        let seconds = elapsedSeconds % 60
        return (hours, minutes, seconds)
    }
    
    func start() {
        reset()
        startTimer()
    }
    
    func pause() {
        stopTimer()
    }
    
    func resume() {
        startTimer()
    }
    
    func stop() {
        stopTimer()
        reset()
    }
    
    private func reset() {
        elapsedSeconds = 0
    }
    
    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.elapsedSeconds += 1
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    deinit {
        stopTimer()
    }
} 