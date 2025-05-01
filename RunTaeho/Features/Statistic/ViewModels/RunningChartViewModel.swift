import Foundation
import SwiftUI

class RunningChartViewModel: ObservableObject {
    // 서비스 인스턴스
    private let runningChartService = RunningChartService.shared

    // 발행 속성
    @Published var period: Period
    @Published var records: [RunningRecord] = []
    @Published var chartData: [RunningChartData] = []

    // 외부 바인딩
    var onPeriodChanged: ((Period) -> Void)?

    // 차트 관련 계산 속성
    var maxChartDistance: Double {
        let maxDistance = chartData.map { $0.distance }.max() ?? 0
        return maxDistance
    }

    var periodHeaderTitle: String {
        return runningChartService.getPeriodHeaderTitle(for: period)
    }

    // 초기화
    init(period: Period, records: [RunningRecord] = []) {
        self.period = period
        self.records = records

        // 초기 데이터 로드
        updateChartData()
    }

    // 기간 변경 시 호출
    func setPeriod(_ newPeriod: Period) {
        self.period = newPeriod
        updateChartData()
        onPeriodChanged?(newPeriod)
    }

    // 레코드 업데이트 시 호출
    func updateRecords(_ newRecords: [RunningRecord]) {
        self.records = newRecords
        updateChartData()
    }

    // 차트 데이터 업데이트
    func updateChartData() {
        // 기존 데이터 초기화
        chartData.removeAll()

        // 레코드 필터링
//        let filteredRecords = runningChartService.filterRecordsByPeriod(records: records, period: period)

        // 차트 데이터 생성
        chartData = runningChartService.generateChartData(rowRecords: records, period: period)

        // UI 업데이트를 위해 발행
        objectWillChange.send()
    }

    // X축 날짜 값 반환
    func getXAxisValues() -> [Date] {
        return runningChartService.getXAxisValues(period: period, chartData: chartData)
    }

    // X축 날짜 포맷팅
    func formatXAxisLabel(for date: Date) -> String {
        return runningChartService.formatXAxisLabel(for: date, period: period)
    }

    // 차트에서 사용할 날짜 단위 반환
    func getDateUnit() -> Calendar.Component {
        return runningChartService.getDateUnit(for: period)
    }
}
