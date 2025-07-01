import Foundation

struct RunningRecord: Identifiable, Codable {
    let id: Int
    let distance: Double
    let cadence: Int
    let hartRate: Int
    let calories: Int
    let durationSec: TimeInterval
    let startTimestamp: TimeInterval
}
