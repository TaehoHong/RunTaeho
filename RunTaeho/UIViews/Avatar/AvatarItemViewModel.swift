import Foundation

// MARK: - Avatar Item ViewModel
struct AvatarItemViewModel: Identifiable {
    let id: String
    let name: String
    let categoryName: String
    let imageName: String?
    let isEquipped: Bool
    let isOwned: Bool
    let price: Int?
    
    // Model에서 ViewModel로 변환
    init(from item: AvatarItem) {
        self.id = item.id
        self.name = item.name
        self.categoryName = item.category.displayName
        self.imageName = item.imageName
        self.isEquipped = item.status == .equipped
        self.isOwned = item.status == .owned || item.status == .equipped
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
    let category: AvatarCategory
    
    init(category: AvatarCategory) {
        self.name = category.displayName
        self.category = category
    }
}

// MARK: - Purchase Item ViewModel
struct PurchaseItemViewModel: Identifiable {
    let id: String
    let name: String
    let categoryName: String
    let imageName: String?
    let price: Int
    
    init(from item: AvatarItemViewModel) {
        self.id = item.id
        self.name = item.name
        self.categoryName = item.categoryName
        self.imageName = item.imageName
        self.price = item.price ?? 0
    }
}