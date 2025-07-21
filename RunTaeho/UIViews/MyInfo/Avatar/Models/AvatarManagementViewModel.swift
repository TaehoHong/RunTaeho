import SwiftUI
import Combine

class AvatarManagementViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var categories: [CategoryViewModel] = []
    @Published var selectedCategoryIndex: Int = 0
    @Published var currentCategoryItems: [AvatarItemViewModel] = []
    @Published var isLoading = false
    @Published var totalPoint: Int = 0
    @Published var errorMessage: String?
    @Published var showPurchaseConfirmation = false
    @Published var itemsToPurchase: [PurchaseItemViewModel] = []
    
    // Unity View에서 사용할 현재 선택된 아이템들
    @Published var currentPreviewItems: [ItemType: AvatarItem] = [:]
    
    // 착용 아이템 상태 관리
    private var pendingEquippedItems: [ItemType: AvatarItem] = [:] {
        didSet {
            // pendingEquippedItems가 변경될 때마다 Unity View 업데이트
            currentPreviewItems = pendingEquippedItems
        }
    }
    private let userStateManager = UserStateManager.shared
    private var avatarItemsByCategory: [ItemType: [AvatarItem]] = [:]
    private let avatarService = AvatarService.shared
    private let unityService = UnityService.shared
    private var cancellables = Set<AnyCancellable>()
    
    private var cursor: Int? = nil
    private var hasNextData: Bool = true
    
    var selectedCategory: ItemType {
        guard selectedCategoryIndex < categories.count else { return .HAIR }
        return categories[selectedCategoryIndex].itemType
    }
    
    
    var hasChanges: Bool {
        // 현재 착용 상태와 UserStateManager의 착용 상태를 비교
        for itemType in ItemType.allCases {
            let currentItem = pendingEquippedItems[itemType]
            let originalItem = userStateManager.equippedItems[itemType]
            
            if currentItem?.id != originalItem?.id {
                return true
            }
        }
        return false
    }
    
    var shouldShowPurchaseButton: Bool {
        // 미보유 아이템이 선택되어 있는지 확인
        return !getItemsToPurchase().isEmpty
    }
    
    // MARK: - Init
    init() {
        setupCategories()
        loadAvatarData(itemType: ItemType.HAIR)
    }
    
    // MARK: - Setup
    private func setupCategories() {
        categories = ItemType.allCases.map { CategoryViewModel(itemType: $0) }
    }
    
    // MARK: - Methods
    func loadAvatarData(itemType: ItemType) {
        errorMessage = nil
        
        Task {
            do {
                let itemCursorResult = try await avatarService.fetchAvatarItems(cursor: cursor, itemType: itemType)
                
                await MainActor.run {
                    // 카테고리별로 데이터 저장
                    self.avatarItemsByCategory[itemType] = (self.avatarItemsByCategory[itemType] ?? []) + itemCursorResult.content
                    self.cursor = itemCursorResult.cursor
                    self.hasNextData = itemCursorResult.hasNext
                    
                    self.updateCurrentCategoryItems()
                    pendingEquippedItems = userStateManager.equippedItems

                    // UserStateManager의 착용 상태로 초기화
                    self.pendingEquippedItems = self.userStateManager.equippedItems
                    self.totalPoint = self.userStateManager.totalPoint
                    // 초기 Unity View 업데이트를 위해 명시적으로 설정
                    self.currentPreviewItems = self.pendingEquippedItems
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    print("error :" + error.localizedDescription)
                }
            }
        }
    }
    
    private func updateCurrentCategoryItems() {
        let categoryItems = avatarItemsByCategory[selectedCategory] ?? []
        currentCategoryItems = categoryItems.map { AvatarItemViewModel(from: $0) }
    }
    
    private func getCurrentEquippedItems() -> [ItemType: AvatarItem] {
        // pendingEquippedItems가 실제 착용 예정 상태를 나타내므로 이를 반환
        return pendingEquippedItems
    }
    
    func selectCategory(at index: Int) {
        selectedCategoryIndex = index
        updateCurrentCategoryItems()
    }
    
    func selectItem(_ itemViewModel: AvatarItemViewModel) {
        guard let item = getAllAvatarItems().first(where: { $0.id == itemViewModel.id }) else { return }
        
        let unityAvatarDto = UnityAvatarDto(
            name: item.name,
            part: item.itemType.unityName,
            itemPath: item.unityFilePath + item.name
        )
        unityService.changeAvatar([unityAvatarDto])
        
        // 현재 카테고리에서 착용 중인 아이템과 같은 아이템을 선택하면 무시
        if pendingEquippedItems[item.itemType]?.id == item.id {
            return
        }
        
        // 아이템을 pending 상태로 착용
        pendingEquippedItems[item.itemType] = item
        
        // UI 업데이트
        objectWillChange.send()
    }
    
    func isItemSelected(_ itemViewModel: AvatarItemViewModel) -> Bool {
        guard let item = getAllAvatarItems().first(where: { $0.id == itemViewModel.id }) else { return false }
        return pendingEquippedItems[item.itemType]?.id == item.id
    }
    
    private func getItemsToPurchase() -> [AvatarItem] {
        var itemsToPurchase: [AvatarItem] = []
        
        for (_, item) in pendingEquippedItems {
            // 원본 아이템 리스트에서 미보유 상태인지 확인
            if let originalItem = getAllAvatarItems().first(where: { $0.id == item.id }),
               originalItem.status == .NOT_OWNED {
                itemsToPurchase.append(originalItem)
            }
        }
        
        return itemsToPurchase
    }
    
    func attemptPurchase() {
        let items = getItemsToPurchase()
        itemsToPurchase = items.map { item in
            PurchaseItemViewModel(from: AvatarItemViewModel(from: item))
        }
        showPurchaseConfirmation = true
    }
    
    func confirmPurchase() {
        Task {
            let itemsToPurchase = getItemsToPurchase()
            
            // 총 가격 계산
            let totalPrice = itemsToPurchase.compactMap { $0.price }.reduce(0, +)
            
            // 포인트 확인
            if totalPoint < totalPrice {
                await MainActor.run {
                    self.errorMessage = "포인트가 부족합니다."
                }
                return
            }
            
            // 모든 아이템 구매
            do {
                let success = try await avatarService.purchaseItem(itemsToPurchase.map { item in item.id })
                if !success {
                    await MainActor.run {
                        
                        self.errorMessage = "\(itemsToPurchase.map { item in item.name }) 구매에 실패했습니다."
                    }
                    return
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = "구매 중 오류가 발생했습니다."
                }
                return
            }
            
            // 모든 변경사항 적용
            await applyAllChanges(purchasedItems: itemsToPurchase)
        }
    }
    
    func confirmChanges() {
        if shouldShowPurchaseButton {
            attemptPurchase()
        } else {
            Task {
                await applyAllChanges(purchasedItems: [])
            }
        }
    }
    
    private func applyAllChanges(purchasedItems: [AvatarItem]) async {
        // 1. 서버에 모든 착용 상태를 한번에 저장 (pendingEquippedItems 기준)
        do {
            // 변경된 아이템만 서버에 전송하는 것이 아니라 
            // 전체 착용 상태를 한번에 업데이트하는 것이 일관성 있음
            try await avatarService.updateEquippedItems(userStateManager.avatarId, pendingEquippedItems.map { $0.value })
        } catch {
            print("API 호출 에러: \(error)")
            return
        }
        
        // 상태 업데이트
        print("MainActor.run 시작")
        await MainActor.run {
            print("MainActor.run 내부 진입")
            // 구매한 아이템들의 ID 저장
            let purchasedItemIds = Set(purchasedItems.map { $0.id })
            
            // 구매한 아이템 포인트 차감
            for purchasedItem in purchasedItems {
                if let price = purchasedItem.price {
                    totalPoint -= price
                    userStateManager.totalPoint -= price
                }
            }
            
            // 착용 상태 업데이트 (구매한 아이템은 바로 EQUIPPED로)
            for (category, item) in pendingEquippedItems {
                // 기존 착용 아이템 해제
                self.unequipItemsInCategory(category, except: item.id)
                
                // 새 아이템 착용 (구매한 아이템이면 바로 EQUIPPED로, 기존 보유 아이템도 EQUIPPED로)
                if purchasedItemIds.contains(item.id) {
                    // 구매한 아이템은 바로 EQUIPPED로 설정
                    self.updateItemStatus(itemId: item.id, newStatus: .EQUIPPED)
                } else {
                    // 기존 보유 아이템도 EQUIPPED로 설정
                    self.updateItemStatus(itemId: item.id, newStatus: .EQUIPPED)
                }
            }
            
            // UserStateManager에 현재 착용 상태 저장
            userStateManager.equippedItems = pendingEquippedItems
            
            // Unity 프리뷰 업데이트
            currentPreviewItems = pendingEquippedItems
            
            // UI 갱신을 위해 현재 카테고리 아이템들을 강제로 새로고침
            currentCategoryItems = []
            let categoryItems = avatarItemsByCategory[selectedCategory] ?? []
            currentCategoryItems = categoryItems.map { item in AvatarItemViewModel(from: item) }
            
            // 구매 팝업 닫기
            showPurchaseConfirmation = false
            
            // UI 강제 업데이트
            objectWillChange.send()
        }
    }
    
    func cancelChanges() {
        // UserStateManager의 상태로 복원
        pendingEquippedItems = userStateManager.equippedItems
        objectWillChange.send()
    }
    
    // MARK: - Helper Methods
    private func getAllAvatarItems() -> [AvatarItem] {
        return avatarItemsByCategory.values.flatMap { $0 }
    }
    
    private func updateItemStatus(itemId: Int, newStatus: ItemStatus) {
        for (category, items) in avatarItemsByCategory {
            if let index = items.firstIndex(where: { $0.id == itemId }) {
                let oldStatus = avatarItemsByCategory[category]?[index].status
                avatarItemsByCategory[category]?[index].status = newStatus
                print("아이템 상태 업데이트: ID \(itemId), \(oldStatus) -> \(newStatus)")
                break
            }
        }
    }
    
    private func unequipItemsInCategory(_ category: ItemType, except itemId: Int) {
        guard let items = avatarItemsByCategory[category] else { return }
        for (index, item) in items.enumerated() {
            if item.status == .EQUIPPED && item.id != itemId {
                avatarItemsByCategory[category]?[index].status = .OWNED
            }
        }
    }
}
