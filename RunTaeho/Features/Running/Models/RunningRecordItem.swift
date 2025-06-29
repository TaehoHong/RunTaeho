import Foundation

struct RunningRecord: Identifiable, Codable {
    let id: Int
    let distance: Double
    let cadence: Int
    let durationSec: TimeInterval
    let startTimestamp: TimeInterval
}
