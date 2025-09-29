import SwiftUI

struct PointView: View {
    @StateObject private var viewModel = PointViewModel(point: UserStateManager.shared.getPoint())
    @State private var scrollViewHeight: CGFloat = 0
    @State private var contentHeight: CGFloat = 0
    
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
                if viewModel.isLoading {
                    // 초기 로딩 표시
                    VStack {
                        ProgressView()
                            .padding(.top, 50)
                        Text("포인트 내역을 불러오고 있습니다...")
                            .font(CustomFont.custom(size: 14))
                            .foregroundColor(Color(hexCode: "999999"))
                            .padding(.top, 10)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    GeometryReader { geometry in
                        ScrollView {
                            // 스크롤 오프셋 추적을 위한 GeometryReader
                            GeometryReader { scrollGeometry in
                                Color.clear.preference(
                                    key: ScrollOffsetPreferenceKey.self,
                                    value: scrollGeometry.frame(in: .named("scroll")).minY
                                )
                            }
                            .frame(height: 0)
                            
                            LazyVStack(spacing: 0) {
                                ForEach(viewModel.filteredPointHistory) { item in
                                    PointHistoryRow(viewModel: item)
                                    
                                    if viewModel.filteredPointHistory.last?.id != item.id {
                                        Divider()
                                            .background(Color(hexCode: "f2f2f2"))
                                            .padding(.horizontal, 20)
                                    }
                                }
                                
                                // 추가 데이터 로딩 중 표시
                                if viewModel.isLoadingMore {
                                    HStack {
                                        Spacer()
                                        ProgressView()
                                            .padding()
                                        Spacer()
                                    }
                                }
                                
                                // 데이터 없음 표시
                                if viewModel.filteredPointHistory.isEmpty && !viewModel.isLoading {
                                    Text("포인트 내역이 없습니다.")
                                        .font(CustomFont.custom(size: 16))
                                        .foregroundColor(Color(hexCode: "999999"))
                                        .padding(.top, 50)
                                }
                            }
                            .padding(.top, 5)
                            .background(
                                GeometryReader { contentGeometry in
                                    Color.clear
                                        .onAppear {
                                            contentHeight = contentGeometry.size.height
                                        }
                                        .onChange(of: contentGeometry.size.height) { newHeight in
                                            contentHeight = newHeight
                                        }
                                }
                            )
                        }
                        .coordinateSpace(name: "scroll")
                        .onPreferenceChange(ScrollOffsetPreferenceKey.self) { scrollOffset in
                            // 스크롤 위치에 따른 추가 데이터 로드
                            let remainingScroll = contentHeight - scrollViewHeight - abs(scrollOffset)
                            
                            // 남은 스크롤이 200pt 이하일 때 로드
                            if remainingScroll < 200 && viewModel.hasMoreData && !viewModel.isLoadingMore {
                                Task {
                                    await viewModel.loadOlderHistories()
                                }
                            }
                        }
                        .onAppear {
                            scrollViewHeight = geometry.size.height
                        }
                        .onChange(of: geometry.size.height) { newHeight in
                            scrollViewHeight = newHeight
                        }
                        .refreshable {
                            // Pull-to-refresh
                            await viewModel.loadInitialData()
                        }
                    }
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
            Task {
                await viewModel.loadInitialData()
            }
        }
    }
}
