import SwiftUI

// 포인트 내역 행
struct PointHistoryRow: View {
    let viewModel: PointHistoryViewModel
    
    var body: some View {
        HStack {
            // 내역 정보
            VStack(alignment: .leading, spacing: 2) {
                Text(viewModel.title)
                    .font(CustomFont.custom(size: 18))
                    .foregroundColor(Color(hexCode: "1a1a1a"))
                
                Text(viewModel.formattedDate)
                    .font(CustomFont.custom(size: 14))
                    .foregroundColor(Color(hexCode: "808080"))
            }
            
            Spacer()
            
            // 포인트 변동 금액
            Text(viewModel.formattedPoint)
                .font(CustomFont.custom(size: 20))
                .fontWeight(.bold)
                .foregroundColor(viewModel.isPositive ?
                    Color(hexCode: "339933") : Color(hexCode: "cc3333"))
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 15)
        .background(Color.white)
    }
}
