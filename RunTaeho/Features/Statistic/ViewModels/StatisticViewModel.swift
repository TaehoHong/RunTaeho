import Foundation
import SwiftUI
import Combine

class StatisticViewModel: ObservableObject {
    // 서비스 인스턴스
    private let statisticService = StatisticChartService.shared
    
    // 하위 뷰모델
    @Published var chartViewModel: ChartViewModel
    
    // 발행 속성
    @Published var selectedPeriod: Period = .month {
        didSet {
            if oldValue != selectedPeriod {
                chartViewModel.setPeriod(selectedPeriod)
            }
        }
    }
    @Published var records: [RunningRecord] = [] {
        didSet {
            chartViewModel.updateRecords(records)
        }
    }
    @Published var isLoading = false
    @Published var currentPage = 0
    
    // 구독 취소용 변수
    private var cancellables = Set<AnyCancellable>()
    
    // 초기화
    init() {
        // 차트 뷰모델 생성
        self.chartViewModel = ChartViewModel(period: .month)
        
        // 차트 뷰모델의 기간 변경 콜백 설정
        chartViewModel.onPeriodChanged = { [weak self] newPeriod in
            self?.selectedPeriod = newPeriod
        }
    }
    
    // 필터링된 레코드
    var filteredRecords: [RunningRecord] {
        return statisticService.filterRecordsByPeriod(records: records, period: selectedPeriod)
    }
    
    // 통계 계산
    var statistics: (runCount: Int, totalDistance: Double, totalDuration: TimeInterval) {
        return statisticService.calculateStatistics(from: filteredRecords)
    }
    
    // 더미 데이터 생성 (나중에 실제 데이터로 교체)
    private func generateDummyData(page: Int) -> [RunningRecord] {
        let calendar = Calendar.current
        let now = Date()
        return (0..<10).map { index ->  RunningRecord in
            let daysToSubtract = page * 10 + index
            let date = calendar.date(byAdding: .day, value: -daysToSubtract, to: now)!
            return RunningRecord(
                date: date,
                distance: Double.random(in: 0...10),
                pace: TimeInterval.random(in: 300...600),
                duration: TimeInterval.random(in: 1800...3600)
            )
        }
    }
    
    // 더 많은 레코드 로드
    func loadMoreRecords() {
        guard !isLoading else { return }
        
        isLoading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let newRecords = self.generateDummyData(page: self.currentPage)
            self.records.append(contentsOf: newRecords)
            self.currentPage += 1
            self.isLoading = false
        }
    }
}
