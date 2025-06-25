import Foundation

class RunningRecordAPIService: RunningRecordAPIProtocol {

    static let shared = RunningRecordAPIService()
    private let userStateManager = UserStateManager.shared
    private let httpClient = HTTPClient.shared

    
    func getRunningRecords(cursor: Int? = nil, size: Int? = nil, startDate: Date? = nil, endDate: Date? = nil) async throws -> CursorResult<RunningRecord> {
        
        let headers: [String: String]?
        
        if let authToken = userStateManager.authToken {
            headers = ["Authorization": "Bearer \(authToken)"]
        } else {
            headers = nil
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            httpClient.get(
                urlPath: SEARCH_RUNNING_RECORDS,
                headers: headers,
                requestParam: makeRequestParam(cursor: cursor, size: size, startDate: startDate, endDate: endDate),
                responseType: CursorResult<RunningRecord>.self
            ) { result in
                switch result {
                case .success(let user):
                    print("UserInfo received: \(user)")
                    continuation.resume(returning: user)
                case .failure(let error):
                    print("Error occurred: \(error)")
                    continuation.resume(throwing: error)
                }
            }
        }
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
