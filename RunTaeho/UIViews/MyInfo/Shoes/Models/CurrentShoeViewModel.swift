import Foundation

struct CurrentShoeViewModel {
    let displayName: String
    let statusText: String = "현재 착용 중"
    let formattedDistance: String
    let imageSystemName: String = "shoeprints.fill"
    
    init(shoe: Shoe) {
        self.displayName = shoe.displayName
        self.formattedDistance = "총 누적거리: \(shoe.formattedDistance)"
    }
}
