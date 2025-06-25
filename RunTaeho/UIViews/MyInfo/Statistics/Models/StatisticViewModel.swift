import Foundation
import SwiftUI
import Combine

class StatisticViewModel: ObservableObject {
    
    private let runningRecordService: RunningRecordService
    private let statisticsService: RunningChartService
    private var startDate = Date().startOfMonth()
    
    var hasNextData: Bool = false
    
    @Published var chartViewModel: RunningChartViewModel
    

    @Published var selectedPeriod: Period = .month {
        didSet {
            if oldValue != selectedPeriod {
                chartViewModel.setPeriod(selectedPeriod)
            }
            
            records.removeAll()
            
            switch selectedPeriod {
            case .month:
                startDate = Date().startOfMonth()
            case .week:
                startDate = Date().startOfWeek()
            case .year:
                startDate = Date().startOfYear()
            }
            
            Task {
                await self.loadRuningRecords(startDate: startDate)
            }
            
        }
    }
    @Published var records: [RunningRecord] = [] {
        didSet {
            chartViewModel.updateRecords(records)
        }
    }
    @Published var isLoading = false
    @Published var error: Error?
    var cursor: Int? = nil

    
    // 초기화
    init() {
        // 차트 뷰모델 생성
        self.chartViewModel = RunningChartViewModel(period: .month)
        self.runningRecordService = RunningRecordService.shared
        self.statisticsService = RunningChartService.shared
        
        // 차트 뷰모델의 기간 변경 콜백 설정
        chartViewModel.onPeriodChanged = { [weak self] newPeriod in
            self?.selectedPeriod = newPeriod
        }

        Task {
            await self.loadRuningRecords(startDate: Date().startOfMonth())
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
    
    
    @MainActor
    func loadRuningRecords(startDate: Date, endDate: Date? = nil) async {
        guard !isLoading else { return }

        isLoading = true
        do {
            let runningRecordPage = try await runningRecordService.loadRuningRecords(startDate: startDate, endDate: endDate ?? Date())

            self.records.append(contentsOf: runningRecordPage.content)
            self.isLoading = false
            self.cursor = runningRecordPage.cursor
            self.hasNextData = runningRecordPage.hasNext
            
            #if DEBUG
            print("loadRuningRecords records count: \(runningRecordPage.content)")
            #endif
            
        } catch {
            self.error = error
            print("Error loading initial records: \(error)")
        }
        
        self.records.sort{ x,y in x.startTimestamp > y.startTimestamp}
    }


    @MainActor
    func loadMoreRecords() async {
        guard !isLoading else { return }
        
        isLoading = true
        do {
            let newRecords = try await self.runningRecordService.loadMoreRecords(cursor: self.cursor, size: 30)
            self.records.append(contentsOf: newRecords.content)
            self.cursor = newRecords.cursor
            self.isLoading = false
            
            #if DEBUG
            print("loadMoreRecords newRecords: \(records.count)")
            #endif
            
        } catch {
            self.error = error
            print("Error loading initial records: \(error)")
        }
        
        self.records.sort{ x,y in x.startTimestamp > y.startTimestamp}
    }
}
