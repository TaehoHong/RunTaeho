import SwiftUI

struct ArchivedShoesView: View {
    @StateObject private var viewModel: ShoesViewModel
    @Environment(\.dismiss) private var dismiss
    
    init(viewModel: ShoesViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        ZStack {
            Color(hexCode: "FAFAFA")
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // 헤더
                HeadingView(title: "보관 신발")
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        Text("보관 신발 목록")
                            .font(CustomFont.custom(size: 18))
                            .padding(.horizontal, 25)
                            .padding(.top, 43)
                            .padding(.bottom, 18)
                        
                        // 보관된 신발 리스트
                        VStack(spacing: 0) {
                            ForEach(viewModel.shoes.filter { $0.isArchived }) { shoe in
                                ArchivedShoeListItemView(
                                    viewModel: ShoeListItemViewModel(shoe: shoe),
                                    onUnarchive: {
                                        viewModel.unarchiveShoe(shoe)
                                    }
                                )
                            }
                        }
                        
                        if viewModel.shoes.filter({ $0.isArchived }).isEmpty {
                            VStack(spacing: 16) {
                                Text("보관된 신발이 없습니다")
                                    .font(CustomFont.custom(size: 16))
                                    .foregroundColor(.gray)
                                    .padding(.top, 60)
                                
                                Text("신발을 보관하면 여기에 표시됩니다")
                                    .font(CustomFont.custom(size: 14))
                                    .foregroundColor(.gray.opacity(0.7))
                            }
                            .frame(maxWidth: .infinity)
                        }
                        
                        Spacer(minLength: 50)
                    }
                }
            }
        }
        .navigationBarHidden(true)
    }
}

struct ArchivedShoeListItemView: View {
    let viewModel: ShoeListItemViewModel
    let onUnarchive: () -> Void
    
    var body: some View {
        HStack(spacing: 0) {
            // 신발 이미지
            Rectangle()
                .fill(Color(hexCode: "D9D9D9"))
                .frame(width: 50, height: 50)
                .padding(.leading, 30)
            
            // 신발 정보
            VStack(alignment: .leading, spacing: 2) {
                Text("\(viewModel.displayName)")
                    .font(CustomFont.custom(size: 16))
                    .foregroundColor(.black)
                
                Text(viewModel.formattedDistance)
                    .font(CustomFont.custom(size: 12))
                    .foregroundColor(Color(hexCode: "808080"))
            }
            .padding(.leading, 20)
            
            Spacer()
            
            // 꺼내기 버튼
            Button(action: onUnarchive) {
                Text("꺼내기")
                    .font(CustomFont.custom(size: 18))
                    .foregroundColor(.black)
                    .frame(width: 61, height: 80)
                    .background(Color(hexCode: "7AE87A"))
            }
        }
        .frame(height: 80)
        .background(Color.white)
        .overlay(
            Rectangle()
                .stroke(Color(hexCode: "E6E6E6"), lineWidth: 1)
        )
    }
}
