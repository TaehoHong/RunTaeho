import SwiftUI

// 포인트 내역 행
struct PointHistoryRow: View {
    let item: PointHistoryItem
    
    var body: some View {
        HStack {
            // 내역 정보
            VStack(alignment: .leading, spacing: 2) {
                Text(item.title)
                    .font(CustomFont.custom(size: 18))
                    .foregroundColor(Color(hexCode: "1a1a1a"))
                
                Text(item.date)
                    .font(CustomFont.custom(size: 14))
                    .foregroundColor(Color(hexCode: "808080"))
            }
            
            Spacer()
            
            // 포인트 변동 금액
            Text(item.formattedAmount)
                .font(CustomFont.custom(size: 20))
                .fontWeight(.bold)
                .foregroundColor(item.isPositive ? 
                    Color(hexCode: "339933") : Color(hexCode: "cc3333"))
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 15)
        .background(Color.white)
    }
}
