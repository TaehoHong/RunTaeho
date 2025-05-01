import Foundation
import SwiftUI
import Combine

class StatisticViewModel: ObservableObject {
    
    private let runningRecordService: RunningRecordAPIProtocol
    private let statisticsService: RunningChartService
    
    // 하위 뷰모델
    @Published var chartViewModel: RunningChartViewModel
    
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

    
    // 초기화
    init() {
        // 차트 뷰모델 생성
        self.chartViewModel = RunningChartViewModel(period: .month)
        self.runningRecordService = RunningRecordDummyService.shared
        self.statisticsService = RunningChartService.shared
        
        // 차트 뷰모델의 기간 변경 콜백 설정
        chartViewModel.onPeriodChanged = { [weak self] newPeriod in
            self?.selectedPeriod = newPeriod
        }        
    }
    
    // 필터링된 레코드
    var filteredRecords: [RunningRecord] {
        return statisticsService.filterRecordsByPeriod(records: records, period: selectedPeriod)
    }
    
    // 통계 계산
    var statistics: (runCount: Int, totalDistance: Double, totalDuration: TimeInterval) {
        return statisticsService.calculateStatistics(from: filteredRecords)
    }
    
    // 더미 데이터 생성 (나중에 실제 데이터로 교체)
    
    
    // 더 많은 레코드 로드
    func loadMoreRecords() {
        guard !isLoading else { return }
        
        isLoading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let newRecords = self.runningRecordService.getRunningRecords(page: self.currentPage, pageSize: 0)
            self.records.append(contentsOf: newRecords)
            self.currentPage += 1
            self.isLoading = false
        }
    }
}
