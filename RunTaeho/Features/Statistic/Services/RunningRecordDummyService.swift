import Foundation

class RunningRecordDummyService: RunningRecordAPIProtocol {

    static let shared = RunningRecordDummyService()
    private var startTimestamp: TimeInterval = Date().timeIntervalSince1970
    
    func getRunningRecords(cursor: Int? = nil, size: Int? = nil, startDate: Date? = nil, endDate: Date? = nil) async throws -> CursorResult<RunningRecord> {
        
        var runningRecords: [RunningRecord] = []
        
        if startDate != nil && endDate != nil {
            runningRecords = generateDummyData(startDate: startDate!, endDate: endDate!)
        } else {
            runningRecords = generateDummyData(cursor: cursor, pageSize: 30, startDate: startDate)
        }
        
        
        
        startTimestamp = runningRecords.last?.startTimestamp ?? Date().timeIntervalSince1970
        
        return CursorResult(content: runningRecords, cursor: runningRecords.last?.id ?? 0, hasNext: true)
    }

    
    private func generateDummyData(cursor: Int?, pageSize: Int, startDate: Date?) -> [RunningRecord] {
        let calendar = Calendar.current
        let now = Date()
        var id = Int(cursor ?? 10000)
        
        return (0..<pageSize).map { index ->  RunningRecord in
            let date = calendar.date(byAdding: .day, value: -1, to: startDate ?? now)!
            
            id -= 1
            
            return RunningRecord(
                id: id,
                distance: Double.random(in: 0...42),
                durationSec: TimeInterval.random(in: 300...600),
                startTimestamp: TimeInterval.random(in: 1800...3600)
            )
        }
    }

    private func generateDummyData(startDate: Date, endDate: Date) -> [RunningRecord] {
        
        let calendar = Calendar.current
        var currentDate = startDate
        var records: [RunningRecord] = []
        var id: Int = 10000

        while currentDate <= endDate {
            if let nextDate = calendar.date(byAdding: .day, value: 1, to: currentDate) {
                if Int.random(in: 0...10) < 8 {
                    records.append(RunningRecord(
                        id: id,
                        distance: Double.random(in: 0...42),
                        durationSec: TimeInterval.random(in: 300...600),
                        startTimestamp: TimeInterval.random(in: 1800...3600)
                    ))
                    
                    id-=1
                    currentDate = nextDate
                }
            } else {
                break
            }
        }

        return records
    }
}
