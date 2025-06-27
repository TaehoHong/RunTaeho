import SwiftUI

// 포인트 잔액 표시 뷰
struct PointBalanceView: View {
    let currentPoints: Int
    
    var formattedPoints: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: currentPoints)) ?? "0"
    }
    
    var body: some View {
        VStack(spacing: 10) {
            Text("현재 보유 포인트")
                .font(CustomFont.custom(size: 16))
                .foregroundColor(Color(hexCode: "666666"))
            
            HStack(spacing: 10) {
                // 포인트 아이콘
                Image("PointIcon")
                
                // 포인트 금액
                Text(formattedPoints)
                    .font(CustomFont.custom(size: 40))
                    .foregroundColor(.black)
            }
            .padding(.bottom, 12)
        }
        .padding(.bottom, 10)
    }
}
