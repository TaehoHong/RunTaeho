import Foundation
import CoreLocation

class RunningRecordItem: Identifiable, Codable {
    let id: Int
    let distance: Double
    let cadence: Int
    let hartRate: Int
    let calories: Int
    let orderIndex: Int
    let durationSec: TimeInterval
    let startTimestamp: TimeInterval
    let endTimestamp: TimeInterval?
    let locations: [LocationData]?
    var isUploaded: Bool = false
    
    init(id: Int, distance: Double, cadence: Int, hartRate: Int, calories: Int, orderIndex: Int, durationSec: TimeInterval, startTimestamp: TimeInterval, locations: [LocationData]?) {
        self.id = id
        self.distance = distance
        self.cadence = cadence
        self.hartRate = hartRate
        self.calories = calories
        self.orderIndex = orderIndex
        self.durationSec = durationSec
        self.startTimestamp = startTimestamp
        self.locations = locations
        self.endTimestamp = nil
    }
    
    // 업로드 완료 표시
    func markAsUploaded() {
        isUploaded = true
    }
    
    // 편의 생성자들
    convenience init(id: Int) {
        self.init(
            id: id,
            distance: 0,
            cadence: 0,
            hartRate: 0,
            calories: 0,
            orderIndex: 0,
            durationSec: 0,
            startTimestamp: Date().timeIntervalSince1970,
            locations: nil
        )
    }
}

// 위치 데이터 모델
struct LocationData: Codable {
    let latitude: Double
    let longitude: Double
    let timestamp: Date
    let speed: Double
    let altitude: Double
    
    init(latitude: Double, longitude: Double, timestamp: Date, speed: Double, altitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
        self.timestamp = timestamp
        self.speed = speed
        self.altitude = altitude
    }
    
    init(from location: CLLocation) {
        self.latitude = location.coordinate.latitude
        self.longitude = location.coordinate.longitude
        self.timestamp = location.timestamp
        self.speed = location.speed
        self.altitude = location.altitude
    }
}
