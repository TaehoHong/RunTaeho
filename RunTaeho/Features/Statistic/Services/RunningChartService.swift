import Foundation

class RunningChartService {
    // 싱글톤 인스턴스
    static let shared: RunningChartService = RunningChartService()

    private init() {}

    // 선택된 기간에 따라 레코드 필터링
    func filterRecordsByPeriod(records: [RunningRecord], period: Period) -> [RunningRecord] {
        let calendar = getCalendar()
        let now = Date()
        var calendarComponenet = Calendar.Component.month
        var startDate: Date

        switch period {
        case .week:
            startDate = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now))!
            calendarComponenet = Calendar.Component.weekOfYear

        case .year:
            startDate = calendar.date(from: calendar.dateComponents([.year], from: now))!
            calendarComponenet = Calendar.Component.year

        default:
            startDate = calendar.date(from: calendar.dateComponents([.year, .month], from: now))!
            calendarComponenet = Calendar.Component.month
        }

        return records.filter { calendar.isDate($0.date, equalTo: startDate, toGranularity: calendarComponenet) }
    }

    // 그래프 데이터 생성
    func generateChartData(rowRecords: [RunningRecord], period: Period) -> [RunningChartData] {
        let calendar = getCalendar()
        let now = Date()
        var chartData: [RunningChartData] = []
        var calendarComponenet = Calendar.Component.month
        var startDate: Date

        var range: Range<Int>!

        switch period {
        case .week:
            range = 0..<7
            startDate = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now))!
            calendarComponenet = Calendar.Component.weekOfYear
        case .year:
            range = 0..<12
            startDate = calendar.date(from: calendar.dateComponents([.year], from: now))!
            calendarComponenet = Calendar.Component.year
        default:
            let max = calendar.range(of: .day, in: .month, for: now)!.count
            range = 0..<(max)
            startDate = calendar.date(from: calendar.dateComponents([.year, .month], from: now))!
            calendarComponenet = Calendar.Component.month
        }

        let records = rowRecords.filter { calendar.isDate($0.date, equalTo: startDate, toGranularity: calendarComponenet) }

        chartData = range.map { day in
            let date = calendar.date(byAdding: getGranularity(period: period), value: day, to: startDate)!
            let normalizedDate = period == .year ? calendar.date(from: calendar.dateComponents([.year, .month], from: date))!
            : calendar.startOfDay(for: date)
            

            let distance = records.filter {
                calendar.isDate($0.date, equalTo: normalizedDate, toGranularity: getGranularity(period: period))
            }.reduce(0){ $0 + $1.distance }

            return RunningChartData(date: normalizedDate, distance: distance)
        }
//        print("chartData: \(chartData)")
        return chartData
    }

    private func getGranularity(period: Period) -> Calendar.Component {
        return period == .year ? .month : .day
    }

    // X축 날짜 값들 반환
    func getXAxisValues(period: Period, chartData: [RunningChartData]) -> [Date] {
        
        if period == .month {
            return chartData.enumerated()
                .filter { index, _ in  (index % 3 == 0 || index == chartData.count - 1) }
                .map { $0.element.date }
        } else {
            return chartData.map { data in data.date }
        }
    }

    // X축 날짜 라벨 포맷팅
    func formatXAxisLabel(for date: Date, period: Period) -> String {
        let calendar = getCalendar()
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = .current

        switch period {
        case .week:
            // 월이 바뀌는 경우 M/d 형식, 아니면 d 형식
            let now = Date()
            let weekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now))!

            if calendar.component(.month, from: weekStart) != calendar.component(.month, from: date) {
                dateFormatter.dateFormat = "M/d"
            } else {
                dateFormatter.dateFormat = "d"
            }
            
            return dateFormatter.string(from: date)

        case .month:
            dateFormatter.dateFormat = "d"
            return dateFormatter.string(from: date)

        case .year:
            dateFormatter.dateFormat = "M"
            return dateFormatter.string(from: date) + "월"
        }
    }

    // 기간 헤더 제목 생성
    func getPeriodHeaderTitle(for period: Period) -> String {
        let calendar = getCalendar()
        let dateFormatter = DateFormatter()
        let now = Date()

        switch period {
        case .week:
            let weekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now))!
            let weekEnd = calendar.date(byAdding: .day, value: 6, to: weekStart)!
            dateFormatter.dateFormat = "M월 d일~"
            let startStr = dateFormatter.string(from: weekStart)
            dateFormatter.dateFormat = "M월 d일"
            let endStr = dateFormatter.string(from: weekEnd)
            return startStr + endStr
        case .month:
            dateFormatter.dateFormat = "M월"
            return dateFormatter.string(from: now)
        case .year:
            dateFormatter.dateFormat = "yyyy년"
            return dateFormatter.string(from: now)
        }
    }

    // 통계 계산
    func calculateStatistics(from records: [RunningRecord]) -> (runCount: Int, totalDistance: Double, totalDuration: TimeInterval) {
        let totalDistance = records.reduce(0) { $0 + $1.distance }
        let totalDuration = records.reduce(0) { $0 + $1.duration }
        return (records.count, totalDistance, totalDuration)
    }

    // 날짜 단위 반환
    func getDateUnit(for period: Period) -> Calendar.Component {
        switch period {
        case .week: return .day
        case .month: return .day
        case .year: return .month
        }
    }

    private func getCalendar() -> Calendar {
        var calendar = Calendar.current
        calendar.timeZone = TimeZone(identifier: TimeZone.current.identifier)!
        calendar.firstWeekday = 2  // 월요일을 1주의 첫날로 설정
        return calendar
    }
}
