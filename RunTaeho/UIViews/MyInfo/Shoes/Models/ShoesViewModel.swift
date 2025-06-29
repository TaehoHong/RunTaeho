import Foundation
import SwiftUI

@MainActor
class ShoesViewModel: ObservableObject {
    @Published var activedShoes: [ShoeViewModel] = []
    @Published var achievedShoes: [ShoeViewModel] = []
    @Published var mainShoe: ShoeViewModel?
    @Published var isLoading = false
    var lastShoeId: Int? = nil
    var hasNextData: Bool = true
    
    private let shoeService = ShoeService.shared
    
    init() {
        Task {
            await loadInitShoes()
        }
    }
    
    // MARK: - Public Methods
    
    func loadInitShoes() async {
        isLoading = true
        
        do {
            
            let shoes = try await shoeService.fetchShoes(cursor: lastShoeId)
            var shoeViewModel: ShoeViewModel
            
            for shoe in shoes.content {
                
                shoeViewModel = ShoeViewModel(shoe: shoe)
                
                if shoeViewModel.isMain {
                    self.mainShoe = shoeViewModel
                } else if shoeViewModel.isAchieved {
                    self.achievedShoes.append(shoeViewModel)
                } else {
                    self.activedShoes.append(shoeViewModel)
                }
            }
            
            self.lastShoeId = shoes.cursor
            self.hasNextData = shoes.hasNext
            
        } catch {
            print("Error loading shoes: 신발 목록을 불러오는데 실패했습니다.")
        }
        
        isLoading = false
    }
    
    func addShoe(_ shoeViewDto: AddShoeViewDto) {
        Task {
            
            let addShoeDto = AddShoeDto(
                brand: shoeViewDto.brand,
                model: shoeViewDto.model,
                targetDistance: shoeViewDto.targetDistance,
                isMain: self.mainShoe == nil
            )
            
            do {
                let addedShoe = ShoeViewModel(
                    shoe: try await shoeService.addShoe(addShoeDto)
                )
                
                if addedShoe.isMain {
                    self.mainShoe = addedShoe
                } else {
                    self.activedShoes.append(addedShoe)
                }
                
            } catch {
                print(error)
                print("Error adding shoe: 신발 추가에 실패했습니다.")
            }
        }
    }
    
    func deleteShoe(_ shoe: ShoeViewModel) {
//        Task {
//            do {
//                try await service.deleteShoe(id: shoe.id)
//                shoes.removeAll(where: { $0.id == shoe.id })
//                
//                // 활성화된 신발이 삭제되면 첫 번째 신발을 활성화
//                if shoe.isMain && !shoes.isEmpty {
//                    await setActiveShoe(shoes[0])
//                } else if shoes.isEmpty {
//                    mainShoe = nil
//                }
//            } catch {
//                errorMessage = "신발 삭제에 실패했습니다."
//                print("Error deleting shoe: \(error)")
//            }
//        }
    }
    
    func archiveShoe(_ shoe: ShoeViewModel) {
//        Task {
//            if let index = shoes.firstIndex(where: { $0.id == shoe.id }) {
//                var updatedShoe = shoes[index]
//                updatedShoe.isEnabled = false
//                
//                do {
//                    let archivedShoe = try await service.updateShoe(updatedShoe)
//                    shoes[index] = archivedShoe
//                    
//                    // 활성화된 신발이 보관되면 다른 신발 활성화
//                    if shoe.isMain {
//                        if let firstActive = shoes.first(where: { $0.isEnabled && $0.id != shoe.id }) {
//                            await setActiveShoe(firstActive)
//                        } else {
//                            mainShoe = nil
//                        }
//                    }
//                } catch {
//                    errorMessage = "신발 보관에 실패했습니다."
//                    print("Error archiving shoe: \(error)")
//                }
//            }
//        }
    }
    
    func setActiveShoe(_ shoe: ShoeViewModel) async {
//        do {
//            try await service.setActiveShoe(id: shoe.id)
//            
//            // 모든 신발 비활성화
//            for index in shoes.indices {
//                shoes[index].isMain = false
//            }
//            
//            // 선택한 신발 활성화
//            if let index = shoes.firstIndex(where: { $0.id == shoe.id }) {
//                shoes[index].isMain = true
//                shoes[index].lastUsedAt = Date()
//                mainShoe = shoes[index]
//            }
//        } catch {
//            errorMessage = "활성 신발 설정에 실패했습니다."
//            print("Error setting active shoe: \(error)")
//        }
    }
    
    func unarchiveShoe(_ shoe: ShoeViewModel) {
//        Task {
//            if let index = shoes.firstIndex(where: { $0.id == shoe.id }) {
//                var updatedShoe = shoes[index]
//                updatedShoe.isEnabled = true
//                
//                do {
//                    let unarchivedShoe = try await service.updateShoe(updatedShoe)
//                    shoes[index] = unarchivedShoe
//                } catch {
//                    errorMessage = "신발 복원에 실패했습니다."
//                    print("Error unarchiving shoe: \(error)")
//                }
//            }
//        }
    }
    
    func updateDistance(for shoeId: Int, distance: Double) {
//        Task {
//            if let index = shoes.firstIndex(where: { $0.id == shoeId }) {
//                var updatedShoe = shoes[index]
//                updatedShoe.totalDistance += distance
//                
//                do {
//                    let savedShoe = try await service.updateShoe(updatedShoe)
//                    shoes[index] = savedShoe
//                    if savedShoe.isMain {
//                        mainShoe = savedShoe
//                    }
//                } catch {
//                    errorMessage = "신발 거리 업데이트에 실패했습니다."
//                    print("Error updating shoe distance: \(error)")
//                }
//            }
//        }
    }
}
