import Foundation

struct RunningChartData: Identifiable {
    let id: UUID = UUID()
    let date: Date
    let distance: Double
}
