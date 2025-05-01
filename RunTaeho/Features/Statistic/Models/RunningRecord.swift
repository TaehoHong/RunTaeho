import Foundation

struct RunningRecord: Identifiable {
    let id: Int64
    let date: Date
    let distance: Double
    let pace: TimeInterval
    let duration: TimeInterval
}