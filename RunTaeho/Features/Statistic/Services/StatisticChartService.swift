import Foundation

class StatisticChartService {
    // 싱글톤 인스턴스
    static let shared: StatisticChartService = StatisticChartService()
    
    private init() {}
    
    // 선택된 기간에 따라 레코드 필터링
    func filterRecordsByPeriod(records: [RunningRecord], period: Period) -> [RunningRecord] {
        let calendar = getCalendar()
        let now = Date()
        
        switch period {
        case .week:
            let weekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now))!
            return records.filter { calendar.isDate($0.date, equalTo: weekStart, toGranularity: .weekOfYear) }
        case .month:
            let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: now))!
            return records.filter { calendar.isDate($0.date, equalTo: monthStart, toGranularity: .month) }
        case .year:
            let yearStart = calendar.date(from: calendar.dateComponents([.year], from: now))!
            return records.filter { calendar.isDate($0.date, equalTo: yearStart, toGranularity: .year) }
        }
    }
    
    // 그래프 데이터 생성
    func generateChartData(fromRecords records: [RunningRecord], forPeriod period: Period) -> [ChartData] {
        let calendar = getCalendar()
        let now = Date()
        var chartData: [ChartData] = []
        
        switch period {
        case .week:
            // 주간 보기는 모든 날짜를 포함 (7일)
            let weekStart = calendar.startOfDay(for: calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now))!)
            for day in 0..<7 {
                let date = calendar.date(byAdding: .day, value: day, to: weekStart)!
                let normalizedDate = calendar.startOfDay(for: date)
                let distance = records
                    .filter { calendar.isDate($0.date, equalTo: normalizedDate, toGranularity: .day) }
                    .reduce(0) { $0 + $1.distance }
                chartData.append(ChartData(date: normalizedDate, distance: distance))
            }
            
        case .month:
            // 월간 보기에는 모든 날짜 데이터 포함
            let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: now))!
            let range = calendar.range(of: .day, in: .month, for: now)!
            for day in 0..<range.count {
                let date = calendar.date(byAdding: .day, value: day, to: monthStart)!
                let normalizedDate = calendar.startOfDay(for: date)
                let distance = records
                    .filter { calendar.isDate($0.date, equalTo: normalizedDate, toGranularity: .day) }
                    .reduce(0) { $0 + $1.distance }
                chartData.append(ChartData(date: normalizedDate, distance: distance))
            }
            
        case .year:
            // 연간 보기는 모든 월 데이터 포함 (12개월)
            let yearStart = calendar.date(from: calendar.dateComponents([.year], from: now))!
            for month in 0..<12 {
                let date = calendar.date(byAdding: .month, value: month, to: yearStart)!
                // 각 월의 1일로 정규화
                let normalizedDate = calendar.date(from: calendar.dateComponents([.year, .month], from: date))!
                let distance = records
                    .filter { calendar.isDate($0.date, equalTo: normalizedDate, toGranularity: .month) }
                    .reduce(0) { $0 + $1.distance }
                chartData.append(ChartData(date: normalizedDate, distance: distance))
            }
        }
        print("chartData: \(chartData)")
        return chartData
    }
    
    // X축 날짜 값들 반환
    func getXAxisValues(for period: Period) -> [Date] {
        let calendar = getCalendar()
        let now = Date()
        
        switch period {
        case .week:
            // 주간 보기는 모든 날짜 표시 (7일)
            let weekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now))!
            return (0..<8).map { i -> Date in
                let date = calendar.date(byAdding: .day, value: i, to: weekStart)!
                return calendar.startOfDay(for: date)
            }
            
        case .month:
            // 월간 보기는 첫날, 마지막날, 그리고 중간에 3일 간격으로 표시
            let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: now))!
            let range = calendar.range(of: .day, in: .month, for: now)!.count
            var dates = [monthStart] // 첫날
            
            // 3일 간격으로 중간 날짜 추가
            for day in stride(from: 3, to: range, by: 3) {
                if let date = calendar.date(byAdding: .day, value: day, to: monthStart) {
                    dates.append(calendar.startOfDay(for: date))
                }
            }
            
            // 마지막 날 추가
            if let lastDayDate = calendar.date(byAdding: .day, value: range - 1, to: monthStart) {
                let normalizedLastDay = calendar.startOfDay(for: lastDayDate)
                if !dates.contains(where: { calendar.isDate($0, inSameDayAs: normalizedLastDay) }) {
                    dates.append(normalizedLastDay)
                }
            }
            
            dates.append(calendar.date(byAdding: .day, value: 1, to: dates.last!)!)
            return dates
            
        case .year:
            // 연간 보기는 모든 월 표시 (12개월)
            let yearStart = calendar.date(from: calendar.dateComponents([.year], from: now))!
            return (0..<13).map { i -> Date in
                let date = calendar.date(byAdding: .month, value: i, to: yearStart)!
                return calendar.date(from: calendar.dateComponents([.year, .month], from: date))!
            }
        }
    }
    
    // X축 날짜 라벨 포맷팅
    func formatXAxisLabel(for date: Date, period: Period) -> String {
        let calendar = getCalendar()
        let dateFormatter = DateFormatter()

        let localizedDate = calendar.date(
            byAdding: .second,
            value: TimeZone.current.secondsFromGMT(),
            to: date
        ) ?? date

        // let _ = print("localizedDate: \(localizedDate)")

        switch period {
        case .week:
            // 월이 바뀌는 경우 M/d 형식, 아니면 d 형식
            let now = Date()
            let weekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now))!
            
            if calendar.component(.month, from: weekStart) != calendar.component(.month, from: localizedDate) {
                dateFormatter.dateFormat = "M/d"
                return dateFormatter.string(from: localizedDate)
            } else {
                dateFormatter.dateFormat = "d"
                return dateFormatter.string(from: localizedDate)
            }
            
        case .month:
            dateFormatter.dateFormat = "d"
            return dateFormatter.string(from: localizedDate)
            
        case .year:
            dateFormatter.dateFormat = "M"
            return dateFormatter.string(from: localizedDate) + "월"
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