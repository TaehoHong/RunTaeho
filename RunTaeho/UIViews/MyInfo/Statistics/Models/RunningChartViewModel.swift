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
//        chartData.forEach { print("date: \($0.date), distance: \($0.distanceKm)") }

        return chartData.map { $0.distanceKm }.max() ?? 0
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
        chartData.removeAll()

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
