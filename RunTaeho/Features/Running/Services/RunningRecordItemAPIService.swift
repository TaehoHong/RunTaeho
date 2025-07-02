import Foundation

class RunningRecordItemAPIService {

    static let shared = RunningRecordItemAPIService()
    private let httpClient = HTTPClient.shared
    
    func saveAll(runningRecordId: Int, items: [RunningRecordItem]) async throws {
        
        struct RequestBody: Encodable {
            let items: [RunningRecordItem]
        }
        
        
        try await httpClient.post(
            urlPath: APIPath.RunningRecordItem.save(runningRecordId),
            body: RequestBody(items: items)
        )
    }
}
