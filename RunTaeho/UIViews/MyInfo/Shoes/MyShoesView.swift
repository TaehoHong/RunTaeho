import SwiftUI

struct MyShoesView: View {
    @StateObject private var viewModel = ShoesViewModel()
    @State private var showingAddShoeView = false
    @State private var showingArchivedShoes = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            Color(hexCode: "FAFAFA")
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // 커스텀 헤더 (기존 HeadingView + 추가 버튼)
                ZStack {
                    // 기존 HeadingView 내용
                    HeadingView(title: "내 신발")
                    HStack {
                        Spacer()
                        AddButton {
                            showingAddShoeView = true
                        }
                    }
                    
                }
                .padding(.horizontal, 5)
                .padding(.top, 15)
                .padding(.bottom, 10)
                
                ScrollView {
                    VStack(spacing: 0) {
                        // 현재 착용 신발
                        if let activeShoe = viewModel.mainShoe {
                            CurrentShoeView(viewModel: CurrentShoeViewModel(shoe: activeShoe))
                        }
                        
                        // 보유 신발 목록
                        VStack(alignment: .leading, spacing: 0) {
                            Text("보유 신발 목록")
                                .font(CustomFont.custom(size: 18))
                                .padding(.horizontal, 25)
                                .padding(.top, 43)
                                .padding(.bottom, 18)
                            
                            // 신발 리스트
                            VStack(spacing: 0) {
                                ForEach(viewModel.shoes.filter { !$0.isArchived }) { shoe in
                                    ShoeListItemView(
                                        viewModel: ShoeListItemViewModel(shoe: shoe),
                                        onArchive: {
                                            viewModel.archiveShoe(shoe)
                                        },
                                        onDelete: {
                                            viewModel.deleteShoe(shoe)
                                        },
                                        onTap: {
                                            Task {
                                                await viewModel.setActiveShoe(shoe)
                                            }
                                        }
                                    )
                                }
                            }
                            
                            // 보관 신발 관리 버튼 (새로 추가된 부분)
                            Button(action: {
                                showingArchivedShoes = true
                            }) {
                                HStack {
                                    Spacer()
                                    Text("보관 신발 관리")
                                        .font(CustomFont.custom(size: 18))
                                        .foregroundColor(.black)
                                    Spacer()
                                }
                                .frame(height: 30)
                                .background(Color(hexCode: "D9D9D9"))
                            }
                            .padding(.horizontal, 25)
                            .padding(.top, 32)
                            .padding(.bottom, 50)
                        }
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showingAddShoeView) {
            AddShoeView { newShoeDto in
                viewModel.addShoe(newShoeDto)
            }
        }
        .sheet(isPresented: $showingArchivedShoes) {
            ArchivedShoesView(viewModel: viewModel)
        }
    }
}
