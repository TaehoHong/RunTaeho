import SwiftUI

struct RunningFinishedView: View {
    @ObservedObject var runningViewModel: RunningViewModel
    @StateObject private var viewModel: RunningFinishedViewModel
    let geometry: GeometryProxy
    
    init(viewModel: RunningViewModel, geometry: GeometryProxy) {
        self.runningViewModel = viewModel
        self.geometry = geometry
        
        if let record = viewModel.finishedRunningRecord {
            self._viewModel = StateObject(wrappedValue: RunningFinishedViewModel(
                runningRecord: record,
                earnedPoints: viewModel.earnedPoints,
                onComplete: {
                    viewModel.resetToStopped()
                }
            ))
        } else {
            // Provide a default empty record if nil
            self._viewModel = StateObject(wrappedValue: RunningFinishedViewModel(
                runningRecord: RunningRecord(id: 0),
                earnedPoints: 0,
                onComplete: {
                    viewModel.resetToStopped()
                }
            ))
        }
    }
    
    var body: some View {
        let width = geometry.size.width
        let height = geometry.size.height
        
        ScrollView {
            VStack(spacing: 15) {
                // Point Information Card
                PointEarnCard(viewModel: viewModel)
                
                // Main Distance Card
                MainDistanceCard(viewModel: viewModel)
                
                // Detailed Statistics Card
                DetailedStatisticsCard(viewModel: viewModel)
                
                // Shoe Selection Area
                if viewModel.hasShoe {
                    ShoeSelectionArea(viewModel: viewModel)
                }
                
                // Complete Button
                CompleteButton(viewModel: viewModel)
            }
            .padding(.horizontal, 10)
        }
        .frame(width: width, height: height * 0.5)
        .position(x: width / 2, y: height * 0.75)
    }
}


struct MainDistanceCard: View {
    @ObservedObject var viewModel: RunningFinishedViewModel
    
    var body: some View {
        VStack {
            Text(viewModel.distanceText)
                .font(CustomFont.custom(size: 36))
                .foregroundColor(.black)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 60)
        .background(Color.white)
        .cornerRadius(8)
    }
}

struct DetailedStatisticsCard: View {
    @ObservedObject var viewModel: RunningFinishedViewModel
    
    var body: some View {
        VStack(spacing: 15) {
            HStack(spacing: 20) {
                StateItemCompactView(
                    title: viewModel.timeText,
                    subtitle: "시간"
                )
                
                StateItemCompactView(
                    title: viewModel.calorieText,
                    subtitle: "칼로리"
                )
            }
            
            HStack(spacing: 20) {
                StateItemCompactView(
                    title: viewModel.heartRateText,
                    subtitle: "심박수"
                )
                
                StateItemCompactView(
                    title: viewModel.paceText,
                    subtitle: "페이스"
                )
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 15)
        .background(Color.white)
        .cornerRadius(8)
    }
}

struct ShoeSelectionArea: View {
    @ObservedObject var viewModel: RunningFinishedViewModel
    @State private var dragOffset: CGFloat = 0
    
    var body: some View {
        VStack(spacing: 15) {
            // 신발 선택 제목
            HStack {
                Text("러닝 신발 선택")
                    .font(CustomFont.custom(size: 16))
                    .foregroundColor(.black)
                Spacer()
            }
            .padding(.horizontal, 20)
            
            // 신발 카드 슬라이더 (3개 카드가 보이는 형태)
            GeometryReader { geometry in
                let cardWidth: CGFloat = 200
                let cardSpacing: CGFloat = 70
                let totalWidth = geometry.size.width
                let centerOffset = (totalWidth - cardWidth) / 2
                
                ZStack {
                    ForEach(Array(viewModel.availableShoes.enumerated()), id: \.offset) { index, shoe in
                        ShoeCardForSlider(shoe: shoe, isActive: index == viewModel.selectedShoeIndex)
                            .offset(x: CGFloat(index - viewModel.selectedShoeIndex) * (cardWidth + cardSpacing) + dragOffset + centerOffset)
                            .scaleEffect(index == viewModel.selectedShoeIndex ? 1.0 : 0.85)
                            .opacity(index == viewModel.selectedShoeIndex ? 1.0 : 0.6)
                            .animation(.spring(response: 0.6, dampingFraction: 0.8, blendDuration: 0), value: viewModel.selectedShoeIndex)
                            .animation(.easeOut(duration: 0.2), value: dragOffset)
                    }
                }
            }
            .frame(height: 200)
            .clipped()
            .gesture(
                DragGesture()
                    .onChanged { value in
                        dragOffset = value.translation.width
                    }
                    .onEnded { value in
                        let threshold: CGFloat = 50
                        let velocity = value.predictedEndTranslation.width - value.translation.width
                        
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.8, blendDuration: 0)) {
                            if value.translation.width > threshold || velocity > 300 {
                                // 오른쪽으로 스와이프 → 이전 신발
                                viewModel.selectPreviousShoe()
                            } else if value.translation.width < -threshold || velocity < -300 {
                                // 왼쪽으로 스와이프 → 다음 신발
                                viewModel.selectNextShoe()
                            }
                            
                            // 드래그 오프셋 리셋
                            dragOffset = 0
                        }
                    }
            )
        }
        .padding(.vertical, 15)
        .background(Color.white)
        .cornerRadius(12)
    }
}

struct ShoeCardForSlider: View {
    let shoe: Shoe
    let isActive: Bool
    
    var body: some View {
        VStack(spacing: 12) {
            // 신발 이미지
            Rectangle()
                .fill(Color(.systemGray5))
                .frame(height: 100)
                .cornerRadius(8)
                .overlay(
                    Image("shose")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 80, height: 60)
                )
            
            // 신발 정보
            VStack(spacing: 4) {
                Text(shoe.brand)
                    .font(CustomFont.custom(size: 12))
                    .foregroundColor(.gray)
                
                Text(shoe.model)
                    .font(CustomFont.custom(size: 14))
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                
                Text("누적거리: \(String(format: "%.1f", Double(shoe.totalDistance)))km")
                    .font(CustomFont.custom(size: 11))
                    .foregroundColor(.gray)
            }
        }
        .frame(width: 200)
        .padding(.horizontal, 15)
        .padding(.vertical, 12)
        .background(isActive ? Color.white : Color(.systemGray6).opacity(0.3))
        .cornerRadius(12)
        .shadow(
            color: isActive ? .black.opacity(0.1) : .clear,
            radius: isActive ? 8 : 0,
            x: 0,
            y: isActive ? 4 : 0
        )
    }
}

struct ShoeCard: View {
    @ObservedObject var viewModel: RunningFinishedViewModel
    
    var body: some View {
        VStack(spacing: 12) {
            // 신발 이미지
            Rectangle()
                .fill(Color(.systemGray5))
                .frame(height: 120)
                .cornerRadius(8)
                .overlay(
                    Image("shose")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 100, height: 80)
                )
            
            // 신발 정보
            VStack(spacing: 4) {
                Text(viewModel.shoeBrand)
                    .font(CustomFont.custom(size: 12))
                    .foregroundColor(.gray)
                
                Text(viewModel.shoeModel)
                    .font(CustomFont.custom(size: 14))
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                
                Text(viewModel.shoeTotalDistance)
                    .font(CustomFont.custom(size: 11))
                    .foregroundColor(.gray)
            }
        }
        .frame(width: 200)
        .padding(.horizontal, 15)
        .padding(.vertical, 12)
        .background(Color(.systemGray6).opacity(0.3))
        .cornerRadius(12)
    }
}

struct CompleteButton: View {
    @ObservedObject var viewModel: RunningFinishedViewModel
    
    var body: some View {
        Button(action: {
            viewModel.onCompleteButtonTapped()
        }) {
            HStack {
                Spacer()
                Text("확인")
                    .font(CustomFont.custom(size: 18))
                    .foregroundColor(.black)
                Spacer()
            }
            .frame(height: 45)
            .background(viewModel.completeButtonColor)
            .cornerRadius(8)
        }
        .padding(.horizontal, 20)
    }
}

struct StateItemCompactView: View {
    let title: String
    let subtitle: String
    
    var body: some View {
        VStack(spacing: 3) {
            Text(title)
                .font(CustomFont.custom(size: 30))
                .foregroundColor(.black)
            
            Text(subtitle)
                .font(CustomFont.custom(size: 18))
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 50)
    }
}
