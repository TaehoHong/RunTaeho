import Foundation

protocol AvatarServiceProtocol {
    func fetchAvatarItems() async throws -> [AvatarItem]
    func equipItem(_ item: AvatarItem) async throws
    func purchaseItem(_ item: AvatarItem) async throws -> Bool
    func getUserPoints() async throws -> Int
}

class AvatarService: AvatarServiceProtocol {
    static let shared = AvatarService()
    
    private init() {}
    
    // MARK: - Fetch Avatar Items
    func fetchAvatarItems() async throws -> [AvatarItem] {
        // 임시 데이터 - 실제로는 서버에서 가져와야 함
        return [
            // Hair items
            AvatarItem(
                id: "hair_001",
                name: "기본 헤어",
                category: .hair,
                imageURL: nil,
                imageName: "Hair_1",
                status: .equipped,
                price: nil
            ),
            AvatarItem(
                id: "hair_002",
                name: "스포츠 헤어",
                category: .hair,
                imageURL: nil,
                imageName: "Hair_2",
                status: .notOwned,
                price: 500
            ),
            AvatarItem(
                id: "hair_003",
                name: "더벅머리",
                category: .hair,
                imageURL: nil,
                imageName: "Hair_4",
                status: .owned,
                price: nil
            ),
            
            // Clothes items
            AvatarItem(
                id: "clothes_001",
                name: "기본 티셔츠",
                category: .clothes,
                imageURL: nil,
                imageName: "Clothes_1",
                status: .equipped,
                price: nil
            ),
            AvatarItem(
                id: "clothes_002",
                name: "운동복",
                category: .clothes,
                imageURL: nil,
                imageName: "Clothes_2",
                status: .owned,
                price: nil
            ),
            
            // Shoes items
            AvatarItem(
                id: "shoes_001",
                name: "기본 운동화",
                category: .shoes,
                imageURL: nil,
                imageName: "Shoes_1",
                status: .equipped,
                price: nil
            ),
            AvatarItem(
                id: "shoes_002",
                name: "러닝화",
                category: .shoes,
                imageURL: nil,
                imageName: "Shoes_2",
                status: .notOwned,
                price: 800
            )
        ]
    }
    
    // MARK: - Equip Item
    func equipItem(_ item: AvatarItem) async throws {
        // 서버에 아이템 장착 요청
        // 현재는 로컬에서만 처리
        print("Equipping item: \(item.name)")
    }
    
    // MARK: - Purchase Item
    func purchaseItem(_ item: AvatarItem) async throws -> Bool {
        // 서버에 구매 요청
        // 성공/실패 여부 반환
        guard let price = item.price else { return false }
        
        // 포인트 확인 로직
        let currentPoints = try await getUserPoints()
        if currentPoints >= price {
            print("Purchasing item: \(item.name) for \(price) points")
            return true
        }
        return false
    }
    
    // MARK: - Get User Points
    func getUserPoints() async throws -> Int {
        // 서버에서 유저 포인트 조회
        return 10000
    }
}
