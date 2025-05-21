import SwiftUI

struct PointView: View {
    @State private var selectedFilter: String = "전체"
    @State private var pointHistory: [PointHistoryItem] = [
        PointHistoryItem(title: "활동 보상", date: "2025.05.15 13:30", amount: 100, isPositive: true),
        PointHistoryItem(title: "아바타 구매", date: "2025.05.14 10:25", amount: 500, isPositive: false),
        PointHistoryItem(title: "친구 초대 보상", date: "2025.05.12 09:15", amount: 1000, isPositive: true)
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            // 상단 헤더
            Text("포인트")
                .font(CustomFont.custom(size: 20))
                .padding(.top, 20)
                .padding(.bottom, 15)
            
            // 포인트 정보 영역
            VStack(spacing: 10) {
                Text("현재 보유 포인트")
                    .font(CustomFont.custom(size: 16))
                    .foregroundColor(Color(hexCode: "666666"))
                
                HStack(spacing: 10) {
                    // 포인트 아이콘
                    PointIconView()
                    
                    // 포인트 금액
                    Text("10,000")
                        .font(CustomFont.custom(size: 40))
                        .foregroundColor(.black)
                }
                .padding(.bottom, 12)
            }
            .padding(.bottom, 10)
            
            // 구분선
            Divider()
                .background(Color(hexCode: "000000").opacity(0.35))
                .padding(.horizontal, 20)
            
            // 포인트 내역 영역
            VStack(alignment: .leading, spacing: 15) {
                HStack {
                    Text("포인트 내역")
                        .font(CustomFont.custom(size: 18))
                        .foregroundColor(Color(hexCode: "4d4d4d"))
                    
                    Spacer()
                    
                    // 필터 버튼
                    FilterButton(selectedFilter: $selectedFilter)
                }
                .padding(.horizontal, 20)
                .padding(.top, 15)
                
                Divider()
                    .background(Color(hexCode: "e6e6e6"))
                
                // 내역 리스트
                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(pointHistory) { item in
                            PointHistoryRow(item: item)
                            
                            if pointHistory.last?.id != item.id {
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
            
            Spacer()
        }
        .background(Color(hexCode: "fafafa"))
        .navigationBarTitleDisplayMode(.inline)
    }
}

// 포인트 아이콘 뷰
struct PointIconView: View {
    var body: some View {
        ZStack {
            Circle()
                .fill(Color(hexCode: "7be87b"))
                .frame(width: 50, height: 50)
            
            Text("P")
                .font(CustomFont.custom(size: 28))
                .fontWeight(.bold)
                .foregroundColor(.white)
        }
    }
}

// 필터 버튼
struct FilterButton: View {
    @Binding var selectedFilter: String
    
    var body: some View {
        Button(action: {
            // 필터 액션 로직
        }) {
            HStack(spacing: 2) {
                Text(selectedFilter)
                    .font(CustomFont.custom(size: 16))
                    .foregroundColor(Color(hexCode: "333333"))
                
                Text("▼")
                    .font(CustomFont.custom(size: 16))
                    .foregroundColor(Color(hexCode: "333333"))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color(hexCode: "f2f2f2").opacity(0.01))
            .cornerRadius(8)
        }
    }
}

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

// 포인트 내역 데이터 모델
struct PointHistoryItem: Identifiable {
    let id = UUID()
    let title: String
    let date: String
    let amount: Int
    let isPositive: Bool
    
    var formattedAmount: String {
        return "\(isPositive ? "+" : "-")\(amount)P"
    }
}

struct PointView_Previews: PreviewProvider {
    static var previews: some View {
        PointView()
    }
}
