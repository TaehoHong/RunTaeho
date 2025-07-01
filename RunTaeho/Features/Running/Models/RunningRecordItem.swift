import Foundation
import CoreLocation

struct RunningRecordItem: Identifiable, Codable {
    let id: Int
    let distance: Double
    let cadence: Int
    let hartRate: Int
    let calories: Int
    let orderIndex: Int
    let durationSec: TimeInterval
    let startTimestamp: TimeInterval
    let locations: [LocationData]?
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
