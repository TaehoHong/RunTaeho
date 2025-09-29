import Foundation

// 포인트 내역 데이터 모델
struct PointHistory: Identifiable, Codable {
    let id: Int
    let point: Int
    let pointType: String
    let createdTimestamp: Int
    
}

// MARK: - Sample Data
//extension PointHistory {
//    static let sampleData: [PointHistory] = [
//        PointHistory(id: 1, point: 100,  pointType: "활동 보상",        date: Date("2025.05.15 13:30")),
//        PointHistory(id: 2, point: 500,  pointType: "아바타 구매",       date: "2025.05.14 10:25"),
//        PointHistory(id: 3, point: 1000, pointType: "친구 초대 보상",     date: "2025.05.12 09:15"),
//        PointHistory(id: 4, point: 50,   pointType: "일일 미션 완료",     date: "2025.05.11 14:20"),
//        PointHistory(id: 5, point: 300,  pointType: "포인트 상점 이용",    date: "2025.05.10 16:45")
//    ]
//}
