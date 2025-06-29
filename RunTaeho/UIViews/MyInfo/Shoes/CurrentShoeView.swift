import SwiftUI

struct CurrentShoeView: View {
    let viewModel: ShoeViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 20) {
                // 신발 이미지
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(hexCode: "CCCCCC"))
                    .frame(width: 70, height: 70)
                    .overlay(
                        Image(systemName: viewModel.imageSystemName)
                            .foregroundColor(.gray)
                            .font(CustomFont.custom(size: 30))
                    )
                
                VStack(alignment: .leading, spacing: 5) {
                    // 신발명
                    Text(viewModel.displayName)
                        .font(CustomFont.custom(size: 20))
                        .foregroundColor(.black)
                    
                    // 총 누적거리
                    Text(viewModel.formattedDistance)
                        .font(CustomFont.custom(size: 12))
                        .foregroundColor(Color(hexCode: "4D4D4D"))
                }
                
                Spacer()
            }
            .padding(.horizontal, 30)
            .padding(.vertical, 25)
        }
        .background(Color.white)
        .padding(.top, 43)
    }
}
