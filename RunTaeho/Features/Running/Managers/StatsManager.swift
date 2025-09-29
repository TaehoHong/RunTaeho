import Foundation

// 통계 관리 클래스
class StatsManager {
    @Published var bpm: Int = 0
    @Published var pace: (minutes: Int, seconds: Int, totalSeconds: Double) = (0, 0, 0.0)
    @Published var speed: Double = 0.0
    @Published var calories: Double = 0.0
    
    func updateStats(distance: Double, elapsedSeconds: Int) {
        print("distance: \(distance), elapsedSeconds: \(elapsedSeconds)")
        
        bpm = Int.random(in: 120...150)
        let paceSeconds = distance > 0 ? Int((Double(elapsedSeconds) / distance) * 1000) : 0
        pace.minutes = paceSeconds / 60
        pace.seconds = paceSeconds % 60
        pace.totalSeconds = Double(paceSeconds)
        speed = (distance / Double(elapsedSeconds)) * 3.6
        
        // 칼로리 계산 (간단한 공식: MET * 체중(kg) * 시간)
        // 러닝의 MET는 약 9.8 (평균 속도 8km/h 기준)
        let weight = 70.0 // 기본 체중 70kg (나중에 사용자 설정에서 가져오기)
        let hours = Double(elapsedSeconds) / 3600.0
        calories += 9.8 * weight * hours
    }
}