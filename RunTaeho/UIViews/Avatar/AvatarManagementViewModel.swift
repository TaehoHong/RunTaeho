import SwiftUI
import Combine

class AvatarManagementViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var avatarState = AvatarState()
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showPurchaseConfirmation = false
    @Published var selectedItemForPurchase: AvatarItem?
    
    // MARK: - Properties
    private let avatarService: AvatarServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    var filteredItems: [AvatarItem] {
        avatarState.allItems.filter { $0.category == avatarState.selectedCategory }
    }
    
    var hasChanges: Bool {
        // 변경사항이 있는지 확인하는 로직
        return true // 임시로 true 반환
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
        switch item.status {
        case .equipped:
            // 이미 착용중인 아이템
            break
        case .owned:
            // 보유한 아이템 - 착용
            equipItem(item)
        case .notOwned:
            // 미보유 아이템 - 구매 확인
            selectedItemForPurchase = item
            showPurchaseConfirmation = true
        }
    }
    
    private func equipItem(_ item: AvatarItem) {
        Task {
            do {
                try await avatarService.equipItem(item)
                await MainActor.run {
                    // 기존 착용 아이템 해제
                    if let currentIndex = avatarState.allItems.firstIndex(where: {
                        $0.category == item.category && $0.status == .equipped
                    }) {
                        avatarState.allItems[currentIndex].status = .owned
                    }
                    
                    // 새 아이템 착용
                    if let index = avatarState.allItems.firstIndex(where: { $0.id == item.id }) {
                        avatarState.allItems[index].status = .equipped
                    }
                    
                    updateEquippedItems()
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = "아이템 착용에 실패했습니다."
                }
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
    
    func confirmChanges() {
        // 변경사항 저장
        print("Changes confirmed")
    }
    
    func cancelChanges() {
        // 변경사항 취소
        loadAvatarData()
    }
    
    private func updateEquippedItems() {
        avatarState.equippedItems.removeAll()
        for item in avatarState.allItems where item.status == .equipped {
            avatarState.equippedItems[item.category] = item
        }
    }
}
