import Foundation

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

// MARK: - Sample Data
extension PointHistoryItem {
    static let sampleData: [PointHistoryItem] = [
        PointHistoryItem(title: "활동 보상", date: "2025.05.15 13:30", amount: 100, isPositive: true),
        PointHistoryItem(title: "아바타 구매", date: "2025.05.14 10:25", amount: 500, isPositive: false),
        PointHistoryItem(title: "친구 초대 보상", date: "2025.05.12 09:15", amount: 1000, isPositive: true),
        PointHistoryItem(title: "일일 미션 완료", date: "2025.05.11 14:20", amount: 50, isPositive: true),
        PointHistoryItem(title: "포인트 상점 이용", date: "2025.05.10 16:45", amount: 300, isPositive: false)
    ]
}
