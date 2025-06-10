import SwiftUI

struct MyShoesView: View {
    @StateObject private var viewModel = ShoesViewModel()
    @State private var showingAddShoe = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            Color(hexCode: "FAFAFA")
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // 헤더
                HeadingView(title: "내 신발")
                
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
                                    ShoeListItem(
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
                            
                            // 새 신발 추가 버튼
                            Button(action: {
                                showingAddShoe = true
                            }) {
                                HStack {
                                    Text("+ 새 신발 추가")
                                        .font(CustomFont.custom(size: 18))
                                        .foregroundColor(.black)
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 31)
                                .background(Color(hexCode: "7AE87A"))
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
        .sheet(isPresented: $showingAddShoe) {
            AddShoeView { newShoeDto in
                viewModel.addShoe(newShoeDto)
            }
        }
    }
}

struct MyShoesView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            MyShoesView()
        }
    }
}
