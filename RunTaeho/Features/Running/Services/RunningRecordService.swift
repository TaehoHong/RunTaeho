import Foundation

class RunningRecordService {
    
    static let shared = RunningRecordService()
    private let runningRecordApiService = RunningRecordAPIService.shared
    
    private init() { }
    
    func loadRuningRecords(startDate: Date, endDate: Date? = nil) async throws -> CursorResult<RunningRecord> {
        
        var records: [RunningRecord] = []
        var hasNext = true
        var cursor: Int? = nil
        
       while hasNext {
           let runningRecordPage = try await runningRecordApiService.getRunningRecords(cursor: cursor, size: nil, startDate: startDate, endDate: endDate ?? Date())
           records.append(contentsOf: runningRecordPage.content)
           
           if runningRecordPage.cursor != nil {
               cursor = runningRecordPage.cursor
           }
           hasNext = runningRecordPage.hasNext
        }
            
        records.sort{ x,y in x.startTimestamp > y.startTimestamp}
        
        return CursorResult(content: records, cursor: cursor, hasNext: true)
    }


    func loadMoreRecords(cursor: Int?, size: Int) async throws -> CursorResult<RunningRecord> {
        
        return try await self.runningRecordApiService.getRunningRecords(cursor: cursor, size: size, startDate: nil, endDate: nil)
        
    }
    
    func startRunning() async -> RunningRecord {
        
        let record: RunningRecord
        
        do {
            
            record = try await self.runningRecordApiService.startRunning()
            
        } catch {
            print(error)
            record = RunningRecord(id: 0)
        }
        
        return record
    }
    
    func update(runningRecord: RunningRecord) async throws {
        
        try await self.runningRecordApiService.put(runningRecord: runningRecord)
    }
}

