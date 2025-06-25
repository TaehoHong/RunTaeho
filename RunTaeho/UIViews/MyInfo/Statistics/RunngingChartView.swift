import SwiftUI
import Foundation
import Charts

struct RunningChartView: View {

    private let chartHight: CGFloat = 200
    @ObservedObject var viewModel: RunningChartViewModel

    var body: some View {
        VStack(spacing: 0) {
            Text(viewModel.periodHeaderTitle)
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top, 10)
                .padding(.bottom, 5)

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
                .frame(height: chartHight)
            } else {
                chartContent
            }
        }
        .padding()
        .onAppear {
            viewModel.updateChartData()
        }
    }

    private var chartContent: some View {
        // Y축 스케일 계산
        let maxYValue = viewModel.maxChartDistance + 3
        let xAxisValues = viewModel.getXAxisValues()

        return Chart {
            ForEach(viewModel.chartData) { data in
                BarMark(
                    x: .value("Date", data.date),// unit: viewModel.getDateUnit()),
                    y: .value("Distance", data.distanceKm),
                    width: viewModel.period == .month ? 5 : 10
                )
                .cornerRadius(4)
                .foregroundStyle(Color())
            }
        }
        .chartYScale(domain: 0...maxYValue)
        .chartXScale(
            domain: .automatic(includesZero: false),
            range: .plotDimension(padding: 10)
        )
        .chartXAxis {

            AxisMarks(preset: .aligned, values: xAxisValues) { value in
                if let date = value.as(Date.self) {
                    AxisValueLabel(centered: false) {
                        let text = viewModel.formatXAxisLabel(for: date)
                        Text(text)
                            .font(CustomFont.custom(size: 10))
                    }
                    AxisTick()
                    // 그리드 선 제거
                    AxisGridLine(stroke: StrokeStyle(lineWidth: 0))
                }
            }
        }
        .chartYAxis {
            // Y축 사전 계산
            let maxValue = viewModel.maxChartDistance + 3
            let _ = print("maxValue: \(maxValue)")
            let strideValue = maxValue / 5

            // Y축 라벨 5개로 설정
            AxisMarks(position: .leading, values: .stride(by: strideValue > 0 ? strideValue : 1)) { value in
                AxisGridLine()
                if let distance = value.as(Double.self) {
                    AxisValueLabel {
                        Text("\(String(format: "%.1f", distance))")
                            .font(CustomFont.custom(size: 10))
                    }
                }
            }
        }
        .padding(.horizontal)  // 차트 좌우 여백 추가
        .frame(height: chartHight)  // 차트 높이 지정
    }
}
