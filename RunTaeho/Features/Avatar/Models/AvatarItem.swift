import Foundation

// MARK: - Avatar Item Model
struct AvatarItem: Identifiable, Equatable, Codable {
    let id: Int
    let name: String
    let itemType: ItemType
    let filePath: String
    let unityFilePath: String
    var status: ItemStatus
    let price: Int?
}

enum ItemStatus: Codable {
    case EQUIPPED   // 착용중
    case OWNED      // 보유
    case NOT_OWNED   // 미보유
}

// MARK: - Avatar Category
enum ItemType: Int, CaseIterable, Codable {
    case HAIR = 1
    case CLOTH = 2
    case PANTS = 3
    
    var id: Int {
        return self.rawValue
    }
    
    var displayName: String {
        switch self{
        case .HAIR: return "머리"
        case .CLOTH: return "의상"
        case .PANTS: return "바지"
        }
    }
    
    var unityName: String {
        switch self{
        case .HAIR: return "Hair"
        case .CLOTH: return "Cloth"
        case .PANTS: return "Pant"
        }
    }
    
    static func getItemType(_ val:Int) -> ItemType {
        return ItemType(rawValue: val)!
    }
}

// MARK: - Avatar State
struct AvatarState {
    var selectedCategory: ItemType = .HAIR
    var equippedItems: [ItemType: AvatarItem] = [:]
    var allItems: [AvatarItem] = []
    var userPoints: Int = 10000
}
