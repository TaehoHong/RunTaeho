import SwiftUI

struct PointEarnCard: View {
    @ObservedObject var viewModel: RunningFinishedViewModel
    
    @State private var animationPhase: AnimationPhase = .initial
    @State private var animatingPoints: Double = 0
    @State private var iconScale: CGFloat = 0.8
    @State private var centerNumberScale: CGFloat = 0.5
    @State private var centerNumberOpacity: Double = 0
    @State private var centerNumberOffset: CGSize = .zero
    @State private var centerNumberFontSize: CGFloat = 24
    @State private var showTotalPoints: Bool = false
    
    private let containerWidth: CGFloat = 362
    private let containerHeight: CGFloat = 40
    
    init(viewModel: RunningFinishedViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        ZStack {
            card
                .frame(width: containerWidth, height: containerHeight)
                .onAppear {
                    startAnimationSequence()
                }
        }
    }
    
    private var card: some View {
        ZStack {
            // 배경 그라데이션
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.95, green: 0.99, blue: 0.97),
                        Color(red: 0.93, green: 0.98, blue: 0.95)
                    ]),
                    startPoint: .leading,
                    endPoint: .trailing
                ))
                .overlay(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .stroke(Color(red: 0.82, green: 0.97, blue: 0.90), lineWidth: 1)
                )
            
            HStack {
                // 좌측: 포인트 획득 표시
                HStack(spacing: 8) {
                    Image("PointIcon")
                        .renderingMode(.original)
                        .interpolation(.none)
                        .resizable()
                        .frame(width: 20, height: 20)
                        .scaleEffect(iconScale)
                        .animation(.easeOut(duration: 0.5), value: iconScale)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("+\(viewModel.earnedPoints)P")
                            .font(.system(size: 14))
                            .foregroundColor(Color(red: 0.12, green: 0.62, blue: 0.41))
                        
                        Text("획득 포인트")
                            .font(.system(size: 11))
                            .foregroundColor(Color(red: 0.20, green: 0.64, blue: 0.43))
                            .lineLimit(1)
                    }
                }
                
                Spacer()
                
                // 우측: 총 포인트 표시
                if showTotalPoints {
                    HStack(spacing: 6) {
                        Image(systemName: "chart.line.uptrend.xyaxis")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                        
                        VStack(alignment: .trailing, spacing: 2) {
                            Text("\(viewModel.totalPoints.formatted())P")
                                .font(.system(size: 13))
                                .foregroundColor(.gray)
                            Text("총 포인트")
                                .font(.system(size: 11))
                                .foregroundColor(.gray.opacity(0.7))
                                .lineLimit(1)
                        }
                    }
                    .transition(.opacity)
                    .animation(.easeIn(duration: 0.3), value: showTotalPoints)
                }
            }
            .padding(.horizontal, 12)
            .frame(height: containerHeight)
            
            // 중앙 숫자 애니메이션 레이어
            if animationPhase != .initial && animationPhase != .completed {
                CountingText(value: animatingPoints)
                    .font(.system(size: centerNumberFontSize))
                    .foregroundColor(.gray)
                    .opacity(centerNumberOpacity)
                    .scaleEffect(centerNumberScale)
                    .offset(centerNumberOffset)
                    .animation(.easeInOut(duration: 0.8), value: centerNumberOffset)
                    .animation(.easeInOut(duration: 0.8), value: centerNumberFontSize)
                    .animation(.easeOut(duration: 0.3), value: centerNumberOpacity)
                    .animation(.easeOut(duration: 0.5), value: centerNumberScale)
            }
        }
    }
    
    // A numeric-counting text that interpolates Double values
    private struct CountingText: View, Animatable {
        var value: Double
        var animatableData: Double {
            get { value }
            set { value = newValue }
        }
        var body: some View {
            Text("\(Int(value).formatted())P")
        }
    }
    
    private func startAnimationSequence() {
        
        // Phase 1: 초기 대기 (1초)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            // Phase 2: 중앙 애니메이션 표시
            // 시작값: 총포인트 - 획득포인트 (음수 방어)
            let start = max(viewModel.totalPoints - viewModel.earnedPoints, 0)
            withTransaction(Transaction(animation: nil)) { // 즉시 반영, 애니메이션 금지
                animatingPoints = Double(start)
            }
            animationPhase = .showingCenter
            iconScale = 1.0
            centerNumberOpacity = 1.0
            centerNumberScale = 1.0
            
            // Phase 3: 숫자 카운팅 시작 (0.3초 후)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                animationPhase = .countingUp
                // 1.5초 동안 숫자 보간 (Double 기반)
                withAnimation(.easeInOut(duration: 1.5)) {
                    animatingPoints = Double(viewModel.totalPoints)
                }
                
                // Phase 4: 위치 이동 (2초 후)
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    animationPhase = .movingToCorner
                    
                    withAnimation(.easeInOut(duration: 0.8)) {
                        centerNumberOffset = CGSize(width: 140, height: -5)
                        centerNumberFontSize = 14
                    }
                    
                    // Phase 5: 완료 및 총 포인트 표시 (0.8초 후)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                        showTotalPoints = true
                        
                        // 중앙 애니메이션 페이드아웃
                        withAnimation(.easeOut(duration: 0.2)) {
                            centerNumberOpacity = 0
                        }
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            animationPhase = .completed
                        }
                    }
                }
            }
        }
    }
}

// Extension for number formatting
extension Int {
    func formatted() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ","
        return formatter.string(from: NSNumber(value: self)) ?? "\(self)"
    }
}


// 애니메이션 단계를 명확히 관리
enum AnimationPhase {
    case initial
    case showingCenter
    case countingUp
    case movingToCorner
    case completed
}
