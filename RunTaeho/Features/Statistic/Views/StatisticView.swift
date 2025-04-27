import SwiftUI
import Charts

enum Period {
    case week, month, year
    
    var title: String {
        switch self {
        case .week: return "주"
        case .month: return "월"
        case .year: return "년"
        }
    }
    
    var periodTitle: String {
        let calendar = Calendar.current
        let now = Date()
        
        switch self {
        case .week:
            let weekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now))!
            let weekEnd = calendar.date(byAdding: .day, value: 6, to: weekStart)!
            let monthFormatter = DateFormatter()
            monthFormatter.dateFormat = "M월"
            let dayFormatter = DateFormatter()
            dayFormatter.dateFormat = "d"
            
            if calendar.component(.month, from: weekStart) == calendar.component(.month, from: weekEnd) {
                return "\(monthFormatter.string(from: weekStart)) \(dayFormatter.string(from: weekStart))~\(dayFormatter.string(from: weekEnd))일"
            } else {
                return "\(monthFormatter.string(from: weekStart)) \(dayFormatter.string(from: weekStart))일~\(monthFormatter.string(from: weekEnd)) \(dayFormatter.string(from: weekEnd))일"
            }
            
        case .month:
            let formatter = DateFormatter()
            formatter.dateFormat = "M월"
            return formatter.string(from: now)
            
        case .year:
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy년"
            return formatter.string(from: now)
        }
    }
}

struct RunningRecord: Identifiable {
    let id = UUID()
    let date: Date
    let distance: Double
    let pace: TimeInterval
    let duration: TimeInterval
}

class StatisticViewModel: ObservableObject {
    @Published var selectedPeriod: Period = .month
    @Published var records: [RunningRecord] = []
    @Published var isLoading = false
    @Published var currentPage = 0
    @Published var chartData: [ChartData] = []
    
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
    
    func loadMoreRecords() {
        guard !isLoading else { return }
        
        isLoading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let newRecords = self.generateDummyData(page: self.currentPage)
            self.records.append(contentsOf: newRecords)
            self.currentPage += 1
            self.isLoading = false
            
            // 레코드 로딩 후 차트 데이터 새로 생성
            self.updateChartData()
        }
    }
    
    func updateChartData() {
        // 차트 데이터를 직접 갱신하는 메서드
        let _ = self.graphData
        print("updateChartData() 호출 - 차트 데이터 개수: \(self.chartData.count)")
    }
    
    // 선택된 기간의 레코드 필터링
    var filteredRecords: [RunningRecord] {
        let calendar = Calendar.current
        let now = Date()
        
        switch selectedPeriod {
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
    
    // 통계 계산
    var statistics: (runCount: Int, totalDistance: Double, totalDuration: TimeInterval) {
        let records = filteredRecords
        let totalDistance = records.reduce(0) { $0 + $1.distance }
        let totalDuration = records.reduce(0) { $0 + $1.duration }
        return (records.count, totalDistance, totalDuration)
    }
    
    // 그래프용 데이터 가공
    var graphData: [(date: Date, distance: Double)] {
        let calendar = Calendar.current
        let now = Date()
        var result: [(Date, Double)] = []

        // 기존 데이터 초기화
        chartData.removeAll()
        print("graphData 계산 시작 - 현재 기간: \(selectedPeriod)")
        
        switch selectedPeriod {
        case .week:
            let weekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now))!
            for day in 0..<7 {
                let date = calendar.date(byAdding: .day, value: day, to: weekStart)!
                let distance = filteredRecords
                    .filter { calendar.isDate($0.date, equalTo: date, toGranularity: .day) }
                    .reduce(0) { $0 + $1.distance }
                result.append((date, distance))
                chartData.append(ChartData(date: date, distance: distance))
            }
            
        case .month:
            let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: now))!
            let range = calendar.range(of: .day, in: .month, for: now)!
            for day in 0..<range.count {
                let date = calendar.date(byAdding: .day, value: day, to: monthStart)!
                let distance = filteredRecords
                    .filter { calendar.isDate($0.date, equalTo: date, toGranularity: .day) }
                    .reduce(0) { $0 + $1.distance }
                result.append((date, distance))
                chartData.append(ChartData(date: date, distance: distance))
            }
            
        case .year:
            let yearStart = calendar.date(from: calendar.dateComponents([.year], from: now))!
            for month in 0..<12 {
                let date = calendar.date(byAdding: .month, value: month, to: yearStart)!
                let distance = filteredRecords
                    .filter { calendar.isDate($0.date, equalTo: date, toGranularity: .month) }
                    .reduce(0) { $0 + $1.distance }
                result.append((date, distance))
                chartData.append(ChartData(date: date, distance: distance))
            }
        }
        
        return result
    }
}

struct ChartData: Identifiable {
    let id = UUID()
    let date: Date
    let distance: Double
}

struct StatisticView: View {
    @StateObject private var viewModel = StatisticViewModel()
    
    var body: some View {
        VStack(spacing: 20) {
            // 기간 선택 버튼
            HStack(spacing: 0) {
                ForEach([Period.week, .month, .year], id: \.self) { period in
                    Button(action: {
                        viewModel.selectedPeriod = period
                        // 기간 변경 시 그래프 데이터 새로 생성
                        DispatchQueue.main.async {
                            let _ = viewModel.graphData
                            print("기간 변경 후 차트 데이터 개수: \(viewModel.chartData.count)")
                        }
                    }) {
                        Text(period.title)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 15)
                            .background(viewModel.selectedPeriod == period ? Color.green.opacity(0.3) : Color.gray.opacity(0.2))
                    }
                }
            }
            
            // 그래프 영역
            VStack {
                if viewModel.chartData.isEmpty {
                    // 데이터가 없을 때 빈 상태 표시
                    VStack(spacing: 10) {
                        Text("데이터가 없습니다")
                            .font(.headline)
                        Text("현재 기간에 러닝 기록이 없습니다.")
                            .font(.caption)
                            .foregroundColor(.gray)
                        
                        Button("차트 데이터 갱신") {
                            viewModel.updateChartData()
                        }
                        .padding(.top)
                    }
                    .frame(height: 250)
                } else {
                    Chart { 
                        ForEach(viewModel.chartData) { data in
                            let _ = print("data: \(data)")
                            BarMark(
                                x: .value("Date", data.date),
                                y: .value("Distance", data.distance)
                            )
                        }
                    }
                    .frame(height: 250)  // 차트 높이 지정
                }
            }
            .padding()
            .onAppear {
                // 명시적으로 그래프 데이터 생성
                let _ = viewModel.graphData
                print("차트 데이터 개수: \(viewModel.chartData.count)")
            }

            // VStack {
            //     Text(viewModel.selectedPeriod.periodTitle)
            //         .font(.headline)
            //         .padding(.bottom, 5)
                
            //     // GraphView2(data: viewModel.graphData)
            //     GraphView(selectedPeriod: viewModel.selectedPeriod, data: viewModel.graphData)
            //         .frame(height: 250 * 2/3)
            //         .padding(.bottom, 16)
            // }
            // .padding()
            
            // 러닝 기록
            VStack(spacing: 10) {
                Text("\(viewModel.statistics.runCount) 러닝")
                    .font(.headline)
                
                HStack {
                    Text("총 거리")
                    Spacer()
                    Text(String(format: "%.1fkm", viewModel.statistics.totalDistance))
                }
                
                HStack {
                    Text("총 시간")
                    Spacer()
                    Text(formatDuration(viewModel.statistics.totalDuration))
                }
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)
            
            // 일자별 기록
            ScrollView {
                LazyVStack(spacing: 10) {
                    ForEach(viewModel.records.sorted(by: { $0.date > $1.date })) { record in
                        RunningRecordRow(record: record)
                            .onAppear {
                                if record.id == viewModel.records.last?.id {
                                    viewModel.loadMoreRecords()
                                }
                            }
                    }
                    
                    if viewModel.isLoading {
                        ProgressView()
                            .padding()
                    }
                }
                .padding()
            }
        }
        .onAppear {
            if viewModel.records.isEmpty {
                viewModel.loadMoreRecords()
                // 데이터 로드 후 약간의 지연을 두고 그래프 데이터 생성
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    let _ = viewModel.graphData
                    print("초기 차트 데이터 개수: \(viewModel.chartData.count)")
                }
            }
        }
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        let minutes = Int(duration) / 60 % 60
        let seconds = Int(duration) % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
}

// struct GraphView: View {
//     let selectedPeriod: Period
//     let data: [(date: Date, distance: Double)]
    
//     private var maxDistance: Double {
//         let max = data.map { $0.distance }.max() ?? 0
//         return max + (max * 0.1)
//     }
    
//     private func shouldShowLabel(for index: Int, in total: Int) -> Bool {
//         selectedPeriod == .week || selectedPeriod == .year || (selectedPeriod == .month && index == 0 || index == total - 1 || (index + 1) % 3 == 0)
//     }
    
//     private func formatXLabel(for date: Date) -> String {
//         let formatter = DateFormatter()
//         formatter.dateFormat = "d"
//         return formatter.string(from: date)
//     }
    
//     private func yAxisLabels(height: CGFloat) -> some View {
//         let steps = 5
//         return VStack(alignment: .trailing, spacing: 0) {
//             ForEach(0...steps, id: \.self) { i in
//                 HStack {
//                     Text(String(format: "%.1f", maxDistance * Double(steps - i) / Double(steps)))
//                         .font(.system(size: 10))
//                         .foregroundColor(.gray)
//                     Rectangle()
//                         .fill(Color.gray.opacity(0.2))
//                         .frame(width: 1, height: 1)
//                 }
//                 .frame(height: height / CGFloat(steps))
//             }
//         }
//     }
    
//     var body: some View {
//         GeometryReader { geometry in
//             let totalHeight = geometry.size.height
//             let xAxisLabelHeight: CGFloat = 20
//             let gridHeight = totalHeight - xAxisLabelHeight
//             let gridLineCount = 6
//             let lineHeight: CGFloat = 1
//             let spacing = (gridHeight - (CGFloat(gridLineCount) * lineHeight)) / CGFloat(gridLineCount - 1)
//             let totalWidth = geometry.size.width - 40  // Y-axis width reserved
//             let barWidth: CGFloat = 8
//             let availableWidth = totalWidth - (barWidth * CGFloat(data.count))
//             let barSpacing = availableWidth / CGFloat(data.count + 1)

//             HStack(spacing: 0) {
//                 // Y-axis labels and grid
//                 yAxisLabels(height: gridHeight)
//                     .frame(width: 40)

//                 ZStack(alignment: .bottom) {
//                     // horizontal grid lines
//                     VStack(spacing: spacing) {
//                         ForEach(0..<gridLineCount, id: \.self) { _ in
//                             Rectangle()
//                                 .fill(Color.gray.opacity(0.2))
//                                 .frame(height: lineHeight)
//                         }
//                     }

//                     // bars
//                     HStack(alignment: .bottom, spacing: barSpacing) {
//                         ForEach(data.indices, id: \.self) { index in
//                             let barHeight = max(gridHeight * CGFloat(data[index].distance / maxDistance), 4)
//                             VStack(spacing: 4) {
//                                 Rectangle()
//                                     .fill(Color.green.opacity(0.3))
//                                     .frame(width: barWidth, height: barHeight)
//                                 if shouldShowLabel(for: index, in: data.count) {
//                                     Text(formatXLabel(for: data[index].date))
//                                         .font(.caption)
//                                         .foregroundColor(.gray)
//                                         .frame(width: barWidth * 2)
//                                 }
//                             }
//                             .alignmentGuide(.bottom) { _ in barHeight }
//                         }
//                     }
//                 }
//                 .frame(height: gridHeight)

//                 // X-axis labels
//                 // HStack(alignment: .center, spacing: barSpacing) {
//                 //     ForEach(data.indices, id: \.self) { index in
//                 //         if shouldShowLabel(for: index, in: data.count) {
//                 //             Text(formatXLabel(for: data[index].date))
//                 //                 .font(.caption)
//                 //                 .foregroundColor(.gray)
//                 //                 .frame(width: barWidth)
//                 //         } else {
//                 //             Spacer()
//                 //                 .frame(width: barWidth)
//                 //         }
//                 //     }
//                 // }
//                 // .frame(height: xAxisLabelHeight)
//             }
//         }
//     }
// }

struct GraphView: View {
    let selectedPeriod: Period
    let data: [(date: Date, distance: Double)]

    private var maxDistance: Double {
        let max = data.map { $0.distance }.max() ?? 0
        return max + (max * 0.1)
    }

    private func shouldShowLabel(for index: Int, in total: Int) -> Bool {
        selectedPeriod == .week || selectedPeriod == .year || (selectedPeriod == .month && index == 0 || index == total - 1 || (index + 1) % 3 == 0)
    }

    private func yAxisLabels(height: CGFloat) -> some View {
        let steps = 4
        return VStack(alignment: .trailing, spacing: 0) {
            ForEach(0...steps, id: \.self) { i in
                HStack {
                    // Labels from maxDistance2 at the top to 0.0 at the bottom
                    Text(String(format: "%.1f", maxDistance * Double(steps - i) / Double(steps)))
                        .font(.system(size: 10))
                        .foregroundColor(.gray)
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: 1, height: 1)
                }
                .frame(height: height / CGFloat(steps))
            }
        }
    }

    private func formatXLabel(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }

    var body: some View {
        GeometryReader { geometry in
            let totalHeight = geometry.size.height
            let gridHeight = totalHeight
            let gridLineCount = 5
            let lineHeight: CGFloat = 1
            let spacing = (gridHeight - (CGFloat(gridLineCount) * lineHeight)) / CGFloat(gridLineCount - 1)
            let totalWidth = geometry.size.width - 40  // Reserve 40pt for Y-axis labels
            let barWidth: CGFloat = 8
            let availableWidth = totalWidth - (barWidth * CGFloat(data.count))
            let barSpacing = availableWidth / CGFloat(data.count + 1)

            VStack(spacing: 0) {
                ZStack(alignment: .bottom) {
                    HStack(spacing: 0) {
                        yAxisLabels(height: gridHeight)
                            .frame(width: 40)

                        ZStack(alignment: .bottom) {
                            VStack(spacing: spacing) {
                                ForEach(0..<gridLineCount, id: \.self) { _ in
                                    Rectangle()
                                        .fill(Color.gray.opacity(0.2))
                                        .frame(height: lineHeight)
                                }
                            }

                            HStack(alignment: .bottom, spacing: barSpacing) {
                                ForEach(data.indices, id: \.self) { index in
                                    let distance = data[index].distance
                                    let barHeight = gridHeight * CGFloat(distance / maxDistance)
                                    VStack(spacing: 4) {
                                        Rectangle()
                                            .fill(Color.blue.opacity(0.3))
                                            .frame(width: barWidth, height: barHeight)
                                        Text(formatXLabel(for: data[index].date))
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                            .fixedSize()
                                    }
                                    .alignmentGuide(.bottom) { _ in
                                        let distance = data[index].distance
                                        let barHeight = gridHeight * CGFloat(distance / maxDistance)
                                        return barHeight
                                    }
                                }
                            }
                        }
                        .frame(height: gridHeight)
                    }
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 1)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                }
            }
        }
    }
}

struct RunningRecordRow: View {
    let record: RunningRecord
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(formatDate(record.date))
                .font(.caption)
                .foregroundColor(.gray)
            
            HStack {
                Text(String(format: "%.1fkm", record.distance))
                Spacer()
                Text(formatPace(record.pace))
                Spacer()
                Text(formatDuration(record.duration))
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 M월 d일 HH시 mm분"
        return formatter.string(from: date)
    }
    
    private func formatPace(_ pace: TimeInterval) -> String {
        let minutes = Int(pace) / 60
        let seconds = Int(pace) % 60
        return String(format: "%d'%02d\"/km", minutes, seconds)
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        let minutes = Int(duration) / 60 % 60
        let seconds = Int(duration) % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
}

struct StatsMainView_Previews: PreviewProvider {
    static var previews: some View {
        StatisticView()
    }
}

