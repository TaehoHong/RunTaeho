import Foundation

class AvatarService {
    static let shared = AvatarService()
    private let itemApiService = ItemApiService.shared
    private let userItemApiService = UserItemApiService.shared
    private let avatarApiService = AvatarApiService.shared
    
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
    func updateEquippedItems(_ avatarId: Int, _ items: [AvatarItem]) async throws {
        
        let avatar = try await avatarApiService.changeAvatarItems(avatarId: avatarId, itemIds: items.map{ $0.id })
    }
    
    // MARK: - Purchase Item
    func purchaseItem(_ itemIds: [Int]) async throws -> Bool {
        do {
            try await userItemApiService.purchaseItem(itemIds: itemIds)
            return true
        } catch {
            print(error)
            return false
        }
    }
    
    // MARK: - Get User Points
    func getUserPoints() async throws -> Int {
        // 서버에서 유저 포인트 조회
        return 10000
    }
}
