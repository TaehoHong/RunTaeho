import Foundation

// MARK: - Avatar Item Model
struct AvatarItem: Identifiable, Equatable {
    let id: String
    let name: String
    let category: AvatarCategory
    let imageURL: String?
    let imageName: String?
    var status: ItemStatus
    let price: Int?
    
    enum ItemStatus {
        case equipped   // 착용중
        case owned      // 보유
        case notOwned   // 미보유
    }
}

// MARK: - Avatar Category
enum AvatarCategory: String, CaseIterable {
    case hair = "머리"
    case clothes = "의상"
    case shoes = "신발"
    
    var displayName: String {
        return self.rawValue
    }
}

// MARK: - Avatar State
struct AvatarState {
    var selectedCategory: AvatarCategory = .hair
    var equippedItems: [AvatarCategory: AvatarItem] = [:]
    var allItems: [AvatarItem] = []
    var userPoints: Int = 10000
}
