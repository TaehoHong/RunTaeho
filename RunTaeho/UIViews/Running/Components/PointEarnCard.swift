import SwiftUI

struct PointEarnCard: View {
    
    @ObservedObject var viewModel: RunningFinishedViewModel
    
    @State private var pointBarWidth: CGFloat = 0.0
    @State private var scaleEffect: CGFloat = 0.8
    @State private var opacity: Double = 0.0
    
    let earnedPoints: Int = 250
    let totalPoints: Int = 1250
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                // 포인트 획득 표시
                HStack(spacing: 8) {
                    Image("PointIcon")
                      .renderingMode(.original)   // 다색 유지
                      .interpolation(.none)       // 최근접 보간
                      .resizable()
                      .frame(width: 20, height: 20)
                    
                    VStack(alignment: .leading, spacing: 0) {
                        Text("+\(viewModel.earnedPointsText)P")
                            .font(CustomFont.custom(size: 16))
                            .foregroundColor(Color.green)
                            .opacity(opacity)
                        
                        Text("포인트 획득")
                            .font(CustomFont.custom(size: 12))
                            .foregroundColor(Color.green)
                            .opacity(0.8)
                    }
                }
                .scaleEffect(scaleEffect)
                
                Spacer()
                
                // 총 포인트 표시
                HStack(spacing: 8) {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .font(size: 12)
                        .foregroundColor(.gray)
                    
                    VStack(alignment: .trailing, spacing: 0) {
                        Text("\(totalPoints)P")
                            .font(size: 12)
                            .foregroundColor(.gray)
                        
                        Text("총 포인트")
                            .font(size: 12)
                            .foregroundColor(.gray.opacity(0.6))
                    }
                }
            }
            
            // 포인트 바 애니메이션
            VStack(spacing: 0) {
                Spacer()
                    .frame(height: 6)
                
                HStack {
                    Rectangle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.green.opacity(0.7), Color.green]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: pointBarWidth, height: 4)
                        .cornerRadius(2)
                    
                    Spacer()
                }
                .frame(height: 4)
                .background(Color.green.opacity(0.2))
                .cornerRadius(2)
            }
            .opacity(opacity)
        }
        .padding(12)
        .frame(width: 362, height: 40)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.green.opacity(0.1),
                    Color.green.opacity(0.05)
                ]),
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.green.opacity(0.3), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        .opacity(opacity)
        .onAppear {
            withAnimation(.easeOut(duration: 0.6)) {
                opacity = 1.0
            }
            
            withAnimation(.easeOut(duration: 0.5).delay(0.3)) {
                scaleEffect = 1.0
            }
            
            withAnimation(.easeOut(duration: 1.2).delay(1.0)) {
                pointBarWidth = 72.4 // 20% of 362
            }
        }
    }
}
