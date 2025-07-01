import Foundation

struct RunningRecord: Identifiable, Codable {
    let id: Int
    let distance: Double
    let cadence: Int
    let hartRate: Int
    let calories: Int
    let durationSec: TimeInterval
    let startTimestamp: TimeInterval
    
    // 서버에서 받은 ID로 초기 생성
    init(id: Int) {
        self.id = id
        self.distance = 0
        self.cadence = 0
        self.hartRate = 0
        self.calories = 0
        self.durationSec = 0
        self.startTimestamp = Date().timeIntervalSince1970
    }
    
    // 완료된 러닝 기록 생성 (모든 필드 지정)
    init(id: Int, distance: Double, cadence: Int, hartRate: Int, calories: Int, durationSec: TimeInterval, startTimestamp: TimeInterval) {
        self.id = id
        self.distance = distance
        self.cadence = cadence
        self.hartRate = hartRate
        self.calories = calories
        self.durationSec = durationSec
        self.startTimestamp = startTimestamp
    }
}
