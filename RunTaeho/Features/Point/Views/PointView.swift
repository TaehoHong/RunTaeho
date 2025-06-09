import SwiftUI

struct PointView: View {
    @StateObject private var viewModel = PointViewModel(point: UserStateManager.shared.getPoint())
    
    var body: some View {
        VStack(spacing: 0) {
            HeadingView(title: "포인트")
            
            // 포인트 정보 영역
            PointBalanceView(currentPoints: viewModel.currentPoints)
            
            // 포인트 내역 영역
            VStack(alignment: .leading, spacing: 15) {
                HStack {
                    Text("포인트 내역")
                        .font(CustomFont.custom(size: 18))
                        .foregroundColor(Color(hexCode: "4d4d4d"))
                    
                    Spacer()
                    
                    // 필터 버튼
                    FilterButton(
                        selectedFilter: $viewModel.selectedFilter,
                        showDropdown: $viewModel.showFilterDropdown
                    )
                }
                .padding(.horizontal, 20)
                .padding(.top, 15)
                
                Divider()
                    .background(Color(hexCode: "e6e6e6"))
                
                // 내역 리스트
                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(viewModel.filteredPointHistory) { item in
                            PointHistoryRow(item: item)
                            
                            if viewModel.filteredPointHistory.last?.id != item.id {
                                Divider()
                                    .background(Color(hexCode: "f2f2f2"))
                                    .padding(.horizontal, 20)
                            }
                        }
                    }
                    .padding(.top, 5)
                }
            }
            .frame(maxWidth: .infinity)
            .background(Color.white)
            .cornerRadius(10)
            .shadow(color: Color(hexCode: "e6e6e6"), radius: 1, x: 0, y: 1)
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
            .overlay(
                // 드롭다운 오버레이
                Group {
                    if viewModel.showFilterDropdown {
                        Color.clear
                            .contentShape(Rectangle())
                            .onTapGesture {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    viewModel.showFilterDropdown = false
                                }
                            }
                        
                        FilterDropdown(
                            selectedFilter: $viewModel.selectedFilter,
                            showDropdown: $viewModel.showFilterDropdown
                        )
                        .position(x: UIScreen.main.bounds.width - 90, y: 85)
                    }
                }
                    .allowsHitTesting(viewModel.showFilterDropdown)
            )
            
            Spacer()
        }
        .background(Color(hexCode: "fafafa"))
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.refreshPointHistory()
        }
    }
}

struct PointView_Previews: PreviewProvider {
    static var previews: some View {
        PointView()
    }
}
