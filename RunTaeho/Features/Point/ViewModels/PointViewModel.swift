import Foundation
import Combine

// 포인트 뷰 모델
class PointViewModel: ObservableObject {
    @Published var selectedFilter: PointFilter = .all
    @Published var showFilterDropdown: Bool = false
    @Published var pointHistory: [PointHistoryItem] = PointHistoryItem.sampleData
    @Published var currentPoints: Int = 10000
    
    init(point: Int) {
        self.currentPoints = point
    }
    
    // 필터링된 포인트 내역
    var filteredPointHistory: [PointHistoryItem] {
        switch selectedFilter {
        case .earned:
            return pointHistory.filter { $0.isPositive }
        case .spent:
            return pointHistory.filter { !$0.isPositive }
        case .all:
            return pointHistory
        }
    }
    
    // 포인트 잔액 계산
    var calculatedBalance: Int {
        pointHistory.reduce(0) { total, item in
            total + (item.isPositive ? item.amount : -item.amount)
        }
    }
    
    // 필터 변경
    func selectFilter(_ filter: PointFilter) {
        selectedFilter = filter
        showFilterDropdown = false
    }
    
    // 드롭다운 토글
    func toggleDropdown() {
        showFilterDropdown.toggle()
    }
    
    // 포인트 내역 새로고침 (API 호출 시뮬레이션)
    func refreshPointHistory() {
        // TODO: 실제 API 호출로 대체
        // 현재는 샘플 데이터 사용
    }
}
