import Foundation

class AvatarService {
    static let shared = AvatarService()
    private let itemApiService = ItemApiService.shared
    
    private init() {}
    
    // MARK: - Fetch Avatar Items
    func fetchAvatarItems(cursor: Int? = nil, itemType: ItemType, excludeMyItems:Bool=false) async throws -> CursorResult<AvatarItem> {
        
        let itemCursorResult = try await itemApiService.getItems(cursor: cursor, itemTypeId: itemType.id, excludeMyItems: excludeMyItems)
        print(itemCursorResult.content.count)
        
        
        return itemCursorResult.of { item in
            AvatarItem(
                id: item.id,
                name: item.name,
                itemType: ItemType.getItemType(item.itemType.id),
                filePath: item.filePath,
                unityFilePath: item.unityFilePath,
                status: item.isOwned ? .OWNED : .NOT_OWNED ,
                price: item.point
            )
        }
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
