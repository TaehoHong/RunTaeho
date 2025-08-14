import SwiftUI

struct PointEarnCard: View {
    @ObservedObject var viewModel: RunningFinishedViewModel
    
    @State private var totalPoints: Int = 0
    @State private var animatingPoints: Int = 0
    @State private var showCenterAnimation: Bool = false
    @State private var showTotalPoints: Bool = false
    @State private var animationComplete: Bool = false

    private let containerWidth: CGFloat = 362
    private let containerHeight: CGFloat = 40
    
    var body: some View {
        ZStack {
            card
                .frame(width: containerWidth, height: containerHeight)
                .opacity(1)
                .offset(y: 0)
                .onAppear {
                    startSequence()
                }
        }
    }

    private var card: some View {
        ZStack {
            // bg-gradient-to-r from-emerald-50 to-green-50 + border
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.95, green: 0.99, blue: 0.97), // emerald-50 유사
                        Color(red: 0.93, green: 0.98, blue: 0.95)  // green-50 유사
                    ]),
                    startPoint: .leading,
                    endPoint: .trailing
                ))
                .overlay(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .stroke(Color(red: 0.82, green: 0.97, blue: 0.90), lineWidth: 1) // emerald-100 유사
                )

            HStack {
                // 좌측: 포인트 획득 표시(아이콘 + 텍스트)
                HStack(spacing: 8) {
                    Image("PointIcon")
                      .renderingMode(.original)   // 다색 유지
                      .interpolation(.none)       // 최근접 보간
                      .resizable()
                      .frame(width: 20, height: 20)
                      .scaleEffect(showCenterAnimation ? 1.0 : 0.8) // initial: 0.8 → 1
                      .animation(.easeOut(duration: 0.5).delay(0.3), value: showCenterAnimation)

                    VStack(alignment: .leading, spacing: 2) {
                        Text("+\(viewModel.earnedPoints)P")
                            .font(size: 14)
                            .foregroundColor(Color(red: 0.12, green: 0.62, blue: 0.41)) // emerald-600

                        Text("획득 포인트")
                            .font(size: 11)
                            .foregroundColor(Color(red: 0.20, green: 0.64, blue: 0.43)) // emerald-500
                            .lineLimit(1)
                    }
                }

                Spacer()

                // 우측: 총 포인트 표시(TrendingUp 아이콘 + 텍스트)
                if showTotalPoints {
                    HStack(spacing: 6) {
                        // lucide-react TrendingUp 대체: SF Symbol
                        Image(systemName: "chart.line.uptrend.xyaxis")
                            .font(size: 12)
                            .foregroundColor(.gray)

                        VStack(alignment: .trailing, spacing: 2) {
                            Text("\(totalPoints.formatted())P")
                                .font(size: 13)
                                .foregroundColor(.gray)
                            Text("총 포인트")
                                .font(size: 11)
                                .foregroundColor(.gray.opacity(0.7))
                                .lineLimit(1)
                        }
                    }
                    .transition(.opacity.animation(.easeIn(duration: 0.3)))
                }
            }
            .padding(.horizontal, 12)
            .frame(height: containerHeight)

            // 중앙 숫자 애니메이션 레이어
            if showCenterAnimation {
                Text("\(animatingPoints.formatted())P")
                    .font(size: animationComplete ? 14 : 24)
                    .foregroundColor(.gray)
                    .opacity(1.0)
                    .scaleEffect(1.0)
                    .offset(x: animationComplete ? 140 : 0, y: animationComplete ? -5 : 0)
                    .animation(nil, value: animatingPoints)
                    .transition(.opacity)
                    .onAppear {
                        // 초기 페이드/스케일 인(React initial {opacity:0, scale:0.5} → animate {opacity:1, scale:1})
                        // SwiftUI는 위에 직접 값 지정했으므로 생략, 필요 시 추가 가능
                    }
                    .animation(.easeInOut(duration: 0.8), value: animationComplete) // x/y & 폰트 크기 변화
            }
        }
    }

    private func startSequence() {
        // 1초 후 시작(React 동일)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            showCenterAnimation = true

            // 2단계: 1000 → 1250 숫자 증가(1.5초, 60스텝 → 25ms 간격)
            let duration: Double = 1.5
            let steps: Int = 60
            let interval: TimeInterval = duration / Double(steps)
            let incrementPerStep: Double = Double(viewModel.earnedPoints) / Double(steps)
            var current: Double = Double(viewModel.totalPoints - viewModel.earnedPoints)

            // 타이머로 숫자 업데이트
            var tick = 0
            let timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { t in
                tick += 1
                current += incrementPerStep
                if current >= Double(viewModel.totalPoints) || tick >= steps {
                    animatingPoints = viewModel.totalPoints
                    t.invalidate()

                    // 0.5초 대기 후 이동/축소 애니메이션 시작
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        withAnimation(.easeInOut(duration: 0.8)) {
                            animationComplete = true
                        }

                        // 이동 애니메이션 끝난 뒤 0.8초 후 총 포인트 갱신/표시
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                            totalPoints = viewModel.totalPoints
                            withAnimation(.easeIn(duration: 0.3)) {
                                showTotalPoints = true
                            }
                            // 중앙 애니메이션 제거(React: setShowCenterAnimation(false); setAnimationComplete(false))
                            withAnimation(.easeOut(duration: 0.2)) {
                                showCenterAnimation = false
                                animationComplete = false
                            }
                        }
                    }
                } else {
                    animatingPoints = Int(floor(current))
                }
            }

            // 런루프에 추가
            RunLoop.current.add(timer, forMode: .common)
        }
    }
}
