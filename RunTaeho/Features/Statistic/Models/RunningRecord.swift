import Foundation

struct RunningRecord: Identifiable, Codable {
    let id: Int
    let distance: Double
    let durationSec: TimeInterval
    let startTimestamp: TimeInterval
}
