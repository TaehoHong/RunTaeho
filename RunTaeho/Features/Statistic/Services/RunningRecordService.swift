import Foundation

class RunningRecordService {
    
    static let shared = RunningRecordService()
//    private let runningRecordService: RunningRecordAPIProtocol = RunningRecordDummyService.shared
    private let runningRecordService: RunningRecordAPIProtocol = RunningRecordAPIService.shared
    
    private init() { }
    
    func loadRuningRecords(startDate: Date, endDate: Date? = nil) async throws -> CursorResult<RunningRecord> {
        
        var records: [RunningRecord] = []
        var hasNext = true
        var cursor: Int? = nil
        
       while hasNext {
           let runningRecordPage = try await runningRecordService.getRunningRecords(cursor: cursor, size: nil, startDate: startDate, endDate: endDate ?? Date())
           records.append(contentsOf: runningRecordPage.content)
           cursor = runningRecordPage.cursor
           hasNext = runningRecordPage.hasNext
        }
            
        records.sort{ x,y in x.startTimestamp > y.startTimestamp}
        
        return CursorResult(content: records, cursor: cursor, hasNext: false)
    }


    func loadMoreRecords(cursor: Int?, size: Int) async throws -> CursorResult<RunningRecord> {
        
        return try await self.runningRecordService.getRunningRecords(cursor: cursor, size: size, startDate: nil, endDate: nil)
        
    }
}
