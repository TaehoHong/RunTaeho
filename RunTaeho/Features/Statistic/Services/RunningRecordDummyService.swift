import Foundation

class RunningRecordDummyService: RunningRecordAPIProtocol {
    
    static let shared = RunningRecordDummyService()
//    
//    func getRunningRecords() async throws -> [RunningRecord] {
//        return generateDummyData
//    }
    
    func getRunningRecords(page: Int, pageSize: Int) -> [RunningRecord] {
        return generateDummyData(page: page)
    }

    private func generateDummyData(page: Int) -> [RunningRecord] {
        let calendar = Calendar.current
        let now = Date()
        return (0..<10).map { index ->  RunningRecord in
            let daysToSubtract = page * 10 + index
            let date = calendar.date(byAdding: .day, value: daysToSubtract, to: now)!
            return RunningRecord(
                id: 0,
                date: date,
                distance: Double.random(in: 0...42),
                pace: TimeInterval.random(in: 300...600),
                duration: TimeInterval.random(in: 1800...3600)
            )
        }
    }
}
