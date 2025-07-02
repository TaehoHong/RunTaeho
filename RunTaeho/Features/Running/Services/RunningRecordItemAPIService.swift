import Foundation

class RunningRecordItemAPIService {

    static let shared = RunningRecordItemAPIService()
    private let httpClient = HTTPClient.shared
    
    func saveAll(runningRecordId: Int, items: [RunningRecordItem]) async throws {
        try await httpClient.post(
            urlPath: APIPath.RunningRecordItem.save(runningRecordId),
            body: items
        )
    }
}
