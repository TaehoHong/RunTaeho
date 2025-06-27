import Foundation
import Combine

// 포인트 뷰 모델
class PointViewModel: ObservableObject {
    
    @Published var selectedFilter: PointFilter = .all
    @Published var showFilterDropdown: Bool = false
    @Published var currentPoints: Int = 10000
    @Published var isLoading: Bool = false
    @Published var isLoadingMore: Bool = false
    @Published var hasMoreData: Bool = true
    
    // 하이브리드 방식을 위한 프로퍼티
    private var allRecentHistories: [PointHistoryViewModel] = [] // 최근 3개월 전체 데이터
    private var olderHistories: [PointHistoryViewModel] = [] // 3개월 이전 필터링된 데이터
    private var lastPointHistoryId: Int? = nil
    
    private let pointApiService = PointApiService.shared
    
    // 필터링된 포인트 내역 (PointView에서 사용)
    var filteredPointHistory: [PointHistoryViewModel] {
        let recentFiltered = filterHistories(allRecentHistories)
        return recentFiltered + olderHistories
    }
    
    init(point: Int) {
        self.currentPoints = point
    }
    
    // 필터 변경
    func selectFilter(_ filter: PointFilter) {
        let previousFilter = selectedFilter
        selectedFilter = filter
        showFilterDropdown = false
        
        // 3개월 이전 데이터는 필터가 변경될 때만 다시 로드
        if previousFilter != filter && !olderHistories.isEmpty {
            Task {
                await loadOlderHistories(reset: true)
            }
        }
    }
    
    // 드롭다운 토글
    func toggleDropdown() {
        showFilterDropdown.toggle()
    }
    
    // 포인트 내역 새로고침 (PointView에서 호출)
    func refreshPointHistory() {
        Task {
            await loadInitialData()
        }
    }
    
    // 초기 데이터 로드
    func loadInitialData() async {
        isLoading = true
        
        do {
            // 3개월 전 날짜 계산
            let calendar = Calendar.current
            
            // 최근 3개월 데이터 전체 로드 (필터 없이)
            let recentCursor = try await pointApiService.getPointHistories(
                startCreatedDatetime: calendar.date(byAdding: .month, value: -3, to: Date())
            )
            
            self.allRecentHistories = recentCursor.content.map { PointHistoryViewModel(pointHistory: $0) }
            self.lastPointHistoryId = recentCursor.cursor
            self.hasMoreData = recentCursor.content.count > 0
            
            // 3개월 이전 데이터가 있다면 현재 필터에 맞게 추가 로드
            if hasMoreData {
                await loadOlderHistories(reset: true)
            }
            
        } catch {
            print("Error loading initial records: \(error)")
            // TODO: 에러 처리 UI 추가
        }
        
        isLoading = false
    }
    
    // 3개월 이전 데이터 로드 (필터 적용)
    func loadOlderHistories(reset: Bool = false) async {
        guard hasMoreData else { return }
        
        isLoadingMore = true
        
        do {
            let cursor = reset ? lastPointHistoryId : olderHistories.last?.id
            
            let olderCursor = try await pointApiService.getPointHistories(
                cursor: cursor
            )
            
            let newHistories = olderCursor.content.map { PointHistoryViewModel(pointHistory: $0) }
            
            if reset {
                self.olderHistories = newHistories
            } else {
                self.olderHistories.append(contentsOf: newHistories)
            }
            
            self.hasMoreData = olderCursor.content.count > 0
            
        } catch {
            print("Error loading older records: \(error)")
            // TODO: 에러 처리 UI 추가
        }
        
        isLoadingMore = false
    }
    
    // 디버깅을 위한 현재 상태 확인 메서드
    func debugLoadingState() {
        print("[PointViewModel] hasMoreData: \(hasMoreData), isLoadingMore: \(isLoadingMore)")
        print("[PointViewModel] Total items: \(filteredPointHistory.count)")
        print("[PointViewModel] Recent items: \(allRecentHistories.count), Older items: \(olderHistories.count)")
    }
    
    // 로컬 필터링 함수
    private func filterHistories(_ histories: [PointHistoryViewModel]) -> [PointHistoryViewModel] {
        switch selectedFilter {
        case .all:
            return histories
        case .earned:
            return histories.filter { $0.isPositive }
        case .spent:
            return histories.filter { !$0.isPositive }
        }
    }
    
    private func getIsEarned() -> Bool? {
        switch selectedFilter {
        case .earned:
            return true
        case .spent:
            return false
        case .all:
            return nil
        }
    }
}
