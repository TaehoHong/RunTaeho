import Foundation

struct RunningRecord: Identifiable, Codable {
    let id: Int
    var shoeId: Int?
    let distance: Double
    let cadence: Int
    let heartRate: Int
    let calorie: Int
    let durationSec: TimeInterval
    let startTimestamp: TimeInterval
    
    // 서버에서 받은 ID로 초기 생성
    init(id: Int) {
        self.id = id
        self.shoeId = nil
        self.distance = 0
        self.cadence = 0
        self.heartRate = 0
        self.calorie = 0
        self.durationSec = 0
        self.startTimestamp = Date().timeIntervalSince1970
    }
    
    // 완료된 러닝 기록 생성 (모든 필드 지정)
    init(id: Int, shoeId: Int? = nil, distance: Double, cadence: Int, heartRate: Int, calorie: Int, durationSec: TimeInterval, startTimestamp: TimeInterval) {
        self.id = id
        self.shoeId = shoeId
        self.distance = distance
        self.cadence = cadence
        self.heartRate = heartRate
        self.calorie = calorie
        self.durationSec = durationSec
        self.startTimestamp = startTimestamp
    }
}
