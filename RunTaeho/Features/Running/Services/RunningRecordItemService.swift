import Foundation

class RunningRecordItemService {

    static let shared = RunningRecordItemService()
    private let runningRecordItemApiService = RunningRecordItemAPIService.shared
    
    func saveAll(runningRecordId: Int, items: [RunningRecordItem]) async throws {
        do {
            try await runningRecordItemApiService.saveAll(runningRecordId: runningRecordId, items: items)
            
            // 업로드 성공 시 모든 아이템을 업로드 완료로 표시
            for item in items {
                item.markAsUploaded()
            }
            
            print("✅ \(items.count)개 세그먼트 업로드 완료 및 상태 업데이트")
            
        } catch {
            print("❌ 세그먼트 업로드 실패: \(error)")
            throw error
        }
    }
}
