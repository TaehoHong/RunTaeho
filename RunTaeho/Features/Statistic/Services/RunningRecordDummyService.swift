import Foundation

class RunningRecordDummyService: RunningRecordAPIProtocol {

    static let shared = RunningRecordDummyService()
    private var lastDate: Date = Date()
    
    func getRunningRecords(cursor: Int64? = nil, size: Int? = nil, startDate: Date? = nil, endDate: Date? = nil) async throws -> Pageable<RunningRecord> {
        
        var runningRecords: [RunningRecord] = []
        
        if startDate != nil && endDate != nil {
            runningRecords = generateDummyData(startDate: startDate!, endDate: endDate!)
        } else {
            runningRecords = generateDummyData(cursor: cursor, pageSize: 30, startDate: startDate)
        }
        
        lastDate = runningRecords.last?.date ?? Date()
        
        return Pageable(data: runningRecords, size: runningRecords.count, cursor: runningRecords.last?.id ?? 0, hasNext: false)
    }

    
    private func generateDummyData(cursor: Int64?, pageSize: Int, startDate: Date?) -> [RunningRecord] {
        let calendar = Calendar.current
        let now = Date()
        var id = Int64(cursor ?? 10000)
        
        return (0..<pageSize).map { index ->  RunningRecord in
            let date = calendar.date(byAdding: .day, value: -1, to: startDate ?? now)!
            
            id -= 1
            
            return RunningRecord(
                id: id,
                date: date,
                distance: Double.random(in: 0...42),
                pace: TimeInterval.random(in: 300...600),
                duration: TimeInterval.random(in: 1800...3600)
            )
        }
    }

    private func generateDummyData(startDate: Date, endDate: Date) -> [RunningRecord] {
        
        let calendar = Calendar.current
        var currentDate = startDate
        var records: [RunningRecord] = []
        var id: Int64 = 10000

        while currentDate <= endDate {
            if let nextDate = calendar.date(byAdding: .day, value: 1, to: currentDate) {
                if Int.random(in: 0...10) < 8 {
                    records.append(RunningRecord(
                        id: id,
                        date: currentDate,
                        distance: Double.random(in: 0...30),
                        pace: TimeInterval.random(in: 300...600),
                        duration: TimeInterval.random(in: 1800...3600)
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
