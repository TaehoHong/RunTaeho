import SwiftUI

struct ShoeListItemView: View {
    let viewModel: ShoeListItemViewModel
    let onArchive: () -> Void
    let onDelete: () -> Void
    let onTap: () -> Void
    
    @State private var offset: CGFloat = 0
    @State private var isSwiped = false
    
    var body: some View {
        ZStack {
            // 스와이프 액션 버튼들
            HStack(spacing: 0) {
                Spacer()
                
                // 착용 버튼 (메인 신발이 아닐 때만 표시)
                if !viewModel.isMain {
                    Button(action: {
                        withAnimation {
                            offset = 0
                            isSwiped = false
                        }
                        onTap()
                    }) {
                        Text("착용")
                            .font(CustomFont.custom(size: 18))
                            .foregroundColor(.black)
                            .frame(width: 61, height: 80)
                            .background(Color(hexCode: "7AE87A"))
                    }
                }
                
                // 보관 버튼
                Button(action: {
                    withAnimation {
                        offset = 0
                        isSwiped = false
                    }
                    onArchive()
                }) {
                    Text("보관")
                        .font(CustomFont.custom(size: 18))
                        .foregroundColor(.black)
                        .frame(width: 61, height: 80)
                        .background(Color(hexCode: "B1B1B1"))
                }
                
                // 삭제 버튼
                Button(action: {
                    withAnimation {
                        offset = 0
                        isSwiped = false
                    }
                    onDelete()
                }) {
                    Text("삭제")
                        .font(CustomFont.custom(size: 18))
                        .foregroundColor(.white)
                        .frame(width: 60, height: 80)
                        .background(Color(hexCode: "FF5252"))
                }
            }
            
            // 메인 컨텐츠
            HStack(spacing: 20) {
                // 신발 이미지
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(hexCode: "D9D9D9"))
                    .frame(width: 50, height: 50)
                    .overlay(
                        Image(systemName: viewModel.imageSystemName)
                            .foregroundColor(.gray)
                            .font(CustomFont.custom(size: 24))
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    // 신발명
                    Text(viewModel.displayName)
                        .font(CustomFont.custom(size: 16))
                        .foregroundColor(.black)
                    
                    // 누적거리
                    Text(viewModel.formattedDistance)
                        .font(CustomFont.custom(size: 12))
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                if viewModel.isMain {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(CustomFont.custom(size: 20))
                }
            }
            .padding(.horizontal, 30)
            .padding(.vertical, 15)
            .background(Color.white)
            .offset(x: offset)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        let maxOffset = viewModel.isMain ? -121.0 : -182.0  // 착용 버튼이 있으면 더 넓게
                        if value.translation.width < 0.0 && value.translation.width > maxOffset {
                            offset = value.translation.width
                        }
                    }
                    .onEnded { value in
                        withAnimation(.spring()) {
                            let maxOffset = viewModel.isMain ? -121.0 : -182.0
                            if value.translation.width < -60 {
                                offset = maxOffset
                                isSwiped = true
                            } else {
                                offset = 0
                                isSwiped = false
                            }
                        }
                    }
            )
            .onTapGesture {
                if isSwiped {
                    withAnimation(.spring()) {
                        offset = 0
                        isSwiped = false
                    }
                }
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
