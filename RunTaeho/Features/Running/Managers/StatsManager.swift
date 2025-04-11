import Foundation

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