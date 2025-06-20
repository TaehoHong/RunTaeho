import Foundation

protocol AvatarServiceProtocol {
    func fetchAvatarItems() async throws -> [AvatarItem]
    func equipItem(_ item: AvatarItem) async throws
    func updateEquippedItems(_ equippedItems: [ItemType: AvatarItem]) async throws
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
                id: 1,
                name: "기본 헤어",
                itemType: .HAIR,
                filePath: nil,
                status: .EQUIPPED,
                price: nil
            ),
            AvatarItem(
                id: 2,
                name: "스포츠 헤어",
                itemType: .HAIR,
                filePath: nil,
                status: .NOT_OWNED,
                price: 500
            ),
            AvatarItem(
                id: 3,
                name: "더벅머리",
                itemType: .HAIR,
                filePath: nil,
                status: .OWNED,
                price: nil
            ),
            
            // Clothes items
            AvatarItem(
                id: 4,
                name: "기본 티셔츠",
                itemType: .CLOTH,
                filePath: nil,
                status: .EQUIPPED,
                price: nil
            ),
            AvatarItem(
                id: 5,
                name: "운동복",
                itemType: .CLOTH,
                filePath: nil,
                status: .OWNED,
                price: nil
            ),
            
            // Shoes items
            AvatarItem(
                id: 6,
                name: "기본 운동화",
                itemType: .PANTS,
                filePath: nil,
                status: .EQUIPPED,
                price: nil
            ),
            AvatarItem(
                id: 7,
                name: "러닝화",
                itemType: .PANTS,
                filePath: nil,
                status: .NOT_OWNED,
                price: 800
            )
        ]
    }
    
    // MARK: - Equip Item
    func equipItem(_ item: AvatarItem) async throws {
        // 단일 아이템 착용 (하위 호환성을 위해 유지)
        print("Equipping item: \(item.name)")
    }
    
    // MARK: - Update All Equipped Items
    func updateEquippedItems(_ equippedItems: [ItemType: AvatarItem]) async throws {
        // 서버에 전체 착용 상태를 한번에 업데이트
        print("Updating all equipped items:")
        for (category, item) in equippedItems {
            print("  \(category): \(item.name)")
        }
        
        // 실제 서버 API 호출
        // let response = try await networkService.post("/api/avatar/equip-all", body: equippedItems)
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
