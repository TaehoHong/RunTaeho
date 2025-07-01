import Foundation
import SwiftUI

@MainActor
class ShoesViewModel: ObservableObject {
    @Published var activeShoes: [ShoeViewModel] = []
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
                    self.activeShoes.append(shoeViewModel)
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
                
                self.activeShoes.append(addedShoe)
                
                if addedShoe.isMain {
                    self.mainShoe = addedShoe
                }
                
                
                
            } catch {
                print(error)
                print("Error adding shoe: 신발 추가에 실패했습니다.")
            }
        }
    }
    
    func deleteShoe(_ shoe: ShoeViewModel) {
        Task {
            if let index = activeShoes.firstIndex(where: { $0.id == shoe.id }) {
                var shoe = activeShoes.remove(at: index)
                
                do {
                    try await shoeService.deleteShoe(id: shoe.id)
                    
                } catch {
                    activeShoes.insert(shoe, at: index)
                    
                    print("Error deleting shoe: 신발 삭제 실패했습니다.")
                }
            }
        }
    }
    
    func archiveShoe(_ shoe: ShoeViewModel) {
        Task {
            if let index = activeShoes.firstIndex(where: { $0.id == shoe.id }) {
                var achievedShoe = activeShoes.remove(at: index)
                achievedShoe.isAchieved = true
                
                do {
                    try await shoeService.achieveShoe(id: achievedShoe.id)
                    achievedShoes.append(achievedShoe)
                    
                    // 활성화된 신발이 보관되면 다른 신발 활성화
                    if shoe.isMain {
                        if let firstActive = activeShoes.first {
                            await setActiveShoe(firstActive)
                        } else {
                            mainShoe = nil
                        }
                    }
                } catch {
                    achievedShoe.isAchieved = false
                    activeShoes.insert(achievedShoe, at: index)
                    if let index = achievedShoes.firstIndex(where: { $0.id == shoe.id }) {
                        achievedShoes.remove(at: index)
                    }
                    
                    print("Error archiving shoe: 신발 보관에 실패했습니다.")
                }
            }
        }
    }
    
    func setActiveShoe(_ shoe: ShoeViewModel) {
        Task {
            if let index = achievedShoes.firstIndex(where: { $0.id == shoe.id }) {
                var shoe = achievedShoes.remove(at: index)
                shoe.isAchieved = false
                
                do {
                    try await shoeService.setActiveShoe(id: shoe.id)
                    activeShoes.append(shoe)
                    
                } catch {
                    shoe.isAchieved = false
                    achievedShoes.insert(shoe, at: index)
                    if let index = activeShoes.firstIndex(where: { $0.id == shoe.id }) {
                        activeShoes.remove(at: index)
                    }
                    
                    print("Error activing shoe: 신발 활성화 실패했습니다.")
                }
            }
        }
    }
}
