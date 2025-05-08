import Foundation

class RunningRecordService {
    
    static let shared = RunningRecordService()
    private let runningRecordService: RunningRecordAPIProtocol = RunningRecordDummyService.shared
    
    private init() { }
    
    func loadRuningRecords(startDate: Date, endDate: Date? = nil) async throws -> Pageable<RunningRecord> {
        
        var records: [RunningRecord] = []
        var hasNext = true
        
       while hasNext {
           let runningRecordPage = try await runningRecordService.getRunningRecords(cursor: nil, size: nil, startDate: startDate, endDate: endDate ?? Date())
           records.append(contentsOf: runningRecordPage.data)
           hasNext = runningRecordPage.hasNext
        }
            
        records.sort{ x,y in x.date > y.date}
        
        return Pageable(data: records, size: records.count, cursor: records.last?.id ?? 0, hasNext: false)
    }


    func loadMoreRecords(cursor: Int64, size: Int) async throws -> Pageable<RunningRecord> {
        
        return try await self.runningRecordService.getRunningRecords(cursor: cursor, size: size, startDate: nil, endDate: nil)
        
    }
}
