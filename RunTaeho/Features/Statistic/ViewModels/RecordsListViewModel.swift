import Foundation
import SwiftUI

class RecordsListViewModel: ObservableObject {
    // 서비스 인스턴스
    private let runningRecordService: RunningRecordAPIProtocol
    
    // 발행 속성
    @Published var records: [RunningRecord] = []
    @Published var isLoading: Bool = false
    @Published var error: Error?
    @Published var hasMoreData: Bool = true
    
    // 페이지네이션 관련
    private var currentPage: Int = 0
    private let pageSize: Int = 20
    
    init() {
        self.runningRecordService = RunningRecordDummyService.shared
    }
    
    // 초기 데이터 로드
    @MainActor
    func loadInitialData() async {
        guard !isLoading else { return }
        
        isLoading = true
        error = nil
        currentPage = 0
        records.removeAll()
        
        do {
            let fetchedRecords = try await runningRecordService.getRunningRecords(page: currentPage, pageSize: pageSize)
            self.records = fetchedRecords
            self.hasMoreData = fetchedRecords.count == pageSize
        } catch {
            self.error = error
            print("Error loading initial records: \(error)")
        }
        
        isLoading = false
    }
    
    // 추가 데이터 로드
    @MainActor
    func loadMoreData() async {
        guard !isLoading && hasMoreData else { return }
        
        isLoading = true
        currentPage += 1
        
        do {
            let fetchedRecords = try await runningRecordService.getRunningRecords(page: currentPage, pageSize: pageSize)
            self.records.append(contentsOf: fetchedRecords)
            self.hasMoreData = fetchedRecords.count == pageSize
        } catch {
            self.error = error
            print("Error loading more records: \(error)")
        }
        
        isLoading = false
    }
    
    // 특정 인덱스에서 추가 데이터 로드 필요 여부 확인
    func shouldLoadMoreData(at index: Int) -> Bool {
        return index >= records.count - 5 && !isLoading && hasMoreData
    }
} 
