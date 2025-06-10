import Foundation

struct ShoeListItemViewModel: Identifiable {
    let id: Int
    let displayName: String
    let formattedDistance: String
    let isMain: Bool
    
    init(shoe: Shoe) {
        self.id = shoe.id
        self.displayName = shoe.displayName
        self.formattedDistance = "누적거리: \(shoe.formattedDistance)"
        self.isMain = shoe.isMain
    }
}
