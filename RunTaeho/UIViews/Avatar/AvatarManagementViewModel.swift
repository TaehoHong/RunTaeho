import SwiftUI
import Combine

class AvatarManagementViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var avatarState = AvatarState()
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showPurchaseConfirmation = false
    @Published var selectedItemForPurchase: AvatarItem?
    
    // 초기 착용 아이템 상태를 저장
    private var originalEquippedItems: [AvatarCategory: AvatarItem] = [:]
    private var pendingEquippedItems: [AvatarCategory: AvatarItem] = [:]
    
    // MARK: - Properties
    private let avatarService: AvatarServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    var filteredItems: [AvatarItem] {
        avatarState.allItems.filter { $0.category == avatarState.selectedCategory }
    }
    
    var hasChanges: Bool {
        // 현재 착용 상태와 원래 착용 상태를 비교
        for category in AvatarCategory.allCases {
            let currentItem = pendingEquippedItems[category]
            let originalItem = originalEquippedItems[category]
            
            if currentItem?.id != originalItem?.id {
                return true
            }
        }
        return false
    }
    
    var shouldShowPurchaseButton: Bool {
        // 미보유 아이템이 선택되어 있는지 확인
        for (_, item) in pendingEquippedItems {
            if item.status == .notOwned {
                return true
            }
        }
        return false
    }
    
    // MARK: - Init
    init(avatarService: AvatarServiceProtocol = AvatarService.shared) {
        self.avatarService = avatarService
        loadAvatarData()
    }
    
    // MARK: - Methods
    func loadAvatarData() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let items = try await avatarService.fetchAvatarItems()
                let points = try await avatarService.getUserPoints()
                
                await MainActor.run {
                    self.avatarState.allItems = items
                    self.avatarState.userPoints = points
                    self.updateEquippedItems()
                    // 초기 착용 상태 저장
                    self.originalEquippedItems = self.avatarState.equippedItems
                    self.pendingEquippedItems = self.avatarState.equippedItems
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                }
            }
        }
    }
    
    func selectCategory(_ category: AvatarCategory) {
        avatarState.selectedCategory = category
    }
    
    func selectItem(_ item: AvatarItem) {
        // 현재 카테고리에서 착용 중인 아이템과 같은 아이템을 선택하면 무시
        if pendingEquippedItems[item.category]?.id == item.id {
            return
        }
        
        // 아이템을 pending 상태로 착용
        pendingEquippedItems[item.category] = item
    }
    
    func isItemSelected(_ item: AvatarItem) -> Bool {
        return pendingEquippedItems[item.category]?.id == item.id
    }
    
    func attemptPurchase() {
        // 미보유 아이템 찾기
        for (category, item) in pendingEquippedItems {
            if item.status == .notOwned {
                selectedItemForPurchase = item
                showPurchaseConfirmation = true
                break
            }
        }
    }
    
    func confirmChanges() {
        Task {
            // 구매가 필요한 아이템이 있는지 확인
            var itemsToPurchase: [AvatarItem] = []
            for (category, item) in pendingEquippedItems {
                if item.status == .notOwned {
                    itemsToPurchase.append(item)
                }
            }
            
            // 구매 처리
            for item in itemsToPurchase {
                do {
                    let success = try await avatarService.purchaseItem(item)
                    if !success {
                        await MainActor.run {
                            self.errorMessage = "포인트가 부족합니다."
                        }
                        return
                    }
                } catch {
                    await MainActor.run {
                        self.errorMessage = "구매에 실패했습니다."
                    }
                    return
                }
            }
            
            // 모든 변경사항 적용
            for (category, item) in pendingEquippedItems {
                if originalEquippedItems[category]?.id != item.id {
                    do {
                        try await avatarService.equipItem(item)
                    } catch {
                        await MainActor.run {
                            self.errorMessage = "아이템 착용에 실패했습니다."
                        }
                    }
                }
            }
            
            // 상태 업데이트
            await MainActor.run {
                // 구매한 아이템 상태 변경
                for purchasedItem in itemsToPurchase {
                    if let index = avatarState.allItems.firstIndex(where: { $0.id == purchasedItem.id }) {
                        avatarState.allItems[index].status = .owned
                        if let price = purchasedItem.price {
                            avatarState.userPoints -= price
                        }
                    }
                }
                
                // 착용 상태 업데이트
                for (category, item) in pendingEquippedItems {
                    // 기존 착용 아이템 해제
                    if let currentIndex = avatarState.allItems.firstIndex(where: {
                        $0.category == category && $0.status == .equipped && $0.id != item.id
                    }) {
                        avatarState.allItems[currentIndex].status = .owned
                    }
                    
                    // 새 아이템 착용
                    if let index = avatarState.allItems.firstIndex(where: { $0.id == item.id }) {
                        avatarState.allItems[index].status = .equipped
                    }
                }
                
                updateEquippedItems()
                originalEquippedItems = avatarState.equippedItems
                pendingEquippedItems = avatarState.equippedItems
            }
        }
    }
    
    func purchaseItem() {
        guard let item = selectedItemForPurchase else { return }
        
        Task {
            do {
                let success = try await avatarService.purchaseItem(item)
                if success {
                    await MainActor.run {
                        // 구매 성공 - 아이템 상태 변경
                        if let index = avatarState.allItems.firstIndex(where: { $0.id == item.id }) {
                            avatarState.allItems[index].status = .owned
                            if let price = item.price {
                                avatarState.userPoints -= price
                            }
                        }
                        showPurchaseConfirmation = false
                        selectedItemForPurchase = nil
                    }
                } else {
                    await MainActor.run {
                        self.errorMessage = "포인트가 부족합니다."
                    }
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = "구매에 실패했습니다."
                }
            }
        }
    }
    

    
    func cancelChanges() {
        // 원래 상태로 복원
        pendingEquippedItems = originalEquippedItems
    }
    
    private func updateEquippedItems() {
        avatarState.equippedItems.removeAll()
        for item in avatarState.allItems where item.status == .equipped {
            avatarState.equippedItems[item.category] = item
        }
    }
}
