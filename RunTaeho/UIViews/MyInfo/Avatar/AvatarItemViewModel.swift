import Foundation

// MARK: - Avatar Item ViewModel
struct AvatarItemViewModel: Identifiable {
    let id: Int
    let name: String
    let imagePath: String
    let categoryName: String
    let isEquipped: Bool
    let isOwned: Bool
    let price: Int?
    
    // Model에서 ViewModel로 변환
    init(from item: AvatarItem) {
        self.id = item.id
        self.name = item.name
        self.imagePath = item.filePath + item.name
        self.categoryName = item.itemType.displayName
        self.isEquipped = item.status == .EQUIPPED
        self.isOwned = item.status == .OWNED || item.status == .EQUIPPED
        self.price = item.price
    }
    
    // 아이템 상태를 나타내는 enum
    var status: ItemStatusViewModel {
        if isEquipped {
            return .equipped
        } else if isOwned {
            return .owned
        } else {
            return .notOwned
        }
    }
}

// MARK: - Item Status ViewModel
enum ItemStatusViewModel {
    case equipped
    case owned
    case notOwned
}

// MARK: - Category ViewModel
struct CategoryViewModel: Identifiable {
    let id = UUID()
    let name: String
    let itemType: ItemType
    
    init(itemType: ItemType) {
        self.name = itemType.displayName
        self.itemType = itemType
    }
}

// MARK: - Purchase Item ViewModel
struct PurchaseItemViewModel: Identifiable {
    let id: Int
    let name: String
    let categoryName: String
    let price: Int
    
    init(from item: AvatarItemViewModel) {
        self.id = item.id
        self.name = item.name
        self.categoryName = item.categoryName
        self.price = item.price ?? 0
    }
}
