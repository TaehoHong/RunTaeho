import Foundation

struct Shoe: Identifiable, Codable {
    let id: Int
    var brand: String
    var model: String
    var totalDistance: Int // in kilometers
    var targetDistance: Int? // optional target distance
    var isMain: Bool
    var isEnabled: Bool
    
    init(
        id: Int = 0,
        brand: String,
        model: String,
        totalDistance: Int = 0,
        targetDistance: Int? = nil,
        isMain: Bool = false,
        isEnabled: Bool = false
    ) {
        self.id = id
        self.brand = brand
        self.model = model
        self.totalDistance = totalDistance
        self.targetDistance = targetDistance
        self.isMain = isMain
        self.isEnabled = isEnabled
    }
}
