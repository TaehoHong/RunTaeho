import Foundation

struct EndRunningRecord: Identifiable, Codable {
    let id: Int
    var shoeId: Int?
    let distance: Double
    let cadence: Int
    let heartRate: Int
    let calorie: Int
    let durationSec: TimeInterval
    let point: Int
    
    // 완료된 러닝 기록 생성 (모든 필드 지정)
    init(id: Int, shoeId: Int? = nil, distance: Double, cadence: Int, heartRate: Int, calorie: Int, durationSec: TimeInterval, point: Int) {
        self.id = id
        self.shoeId = shoeId
        self.distance = distance
        self.cadence = cadence
        self.heartRate = heartRate
        self.calorie = calorie
        self.durationSec = durationSec
        self.point = point
    }
}
