import Foundation

class RunningRecordAPIService {

    static let shared = RunningRecordAPIService()
    private let userStateManager = UserStateManager.shared
    private let httpClient = HTTPClient.shared
    
    func startRunning() async throws -> RunningRecord {
        
        struct RunningRecordId: Codable {
            let id: Int
        }
        
        let recordId = try await httpClient.post(
            urlPath: APIPath.RunningRecord.start,
            body: ["startTimestamp": String(Int(Date().timeIntervalSince1970))],
            responseType: RunningRecordId.self
        ).id
        
        return RunningRecord(id: recordId)
    }
    
    func end(runningRecord: RunningRecord) async throws -> EndRunningRecord {
        return try await httpClient.post(
            urlPath: APIPath.RunningRecord.end(runningRecord.id),
            body: runningRecord,
            responseType: EndRunningRecord.self
        )
    }
    
    func put(runningRecord: RunningRecord) async throws {
        try await httpClient.put(
            urlPath: APIPath.RunningRecord.put(runningRecord.id),
            body: runningRecord
        )
    }

    
    func getRunningRecords(cursor: Int? = nil, size: Int? = nil, startDate: Date? = nil, endDate: Date? = nil) async throws -> CursorResult<RunningRecord> {
        
        let headers: [String: String]?
        
        if let authToken = userStateManager.authToken {
            headers = ["Authorization": "Bearer \(authToken)"]
        } else {
            headers = nil
        }
        
        return try await httpClient.get(
                urlPath: APIPath.RunningRecord.search,
                headers: headers,
                requestParam: makeRequestParam(cursor: cursor, size: size, startDate: startDate, endDate: endDate),
                responseType: CursorResult<RunningRecord>.self
        )
    }
    
    private func makeRequestParam(cursor: Int? = nil, size: Int? = nil, startDate: Date? = nil, endDate: Date? = nil) -> RequestParam {
        
        
        var params: [String: String] = [:]
        if let cursor = cursor {
            params["cursor"] = String(cursor)
        }
        if let size = size {
            params["size"] = String(size)
        }
        if let startDate = startDate {
            params["startTimestamp"] = String(Int(startDate.timeIntervalSince1970))
        }
        if let endDate = endDate {
            params["endTimestamp"] = String(Int(endDate.timeIntervalSince1970))
        }
        
        return RequestParam(params: params)
    }
}
