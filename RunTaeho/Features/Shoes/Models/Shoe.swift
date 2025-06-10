import Foundation

struct Shoe: Identifiable, Codable {
    let id: Int
    var brand: String
    var model: String
    var totalDistance: Double // in kilometers
    var targetDistance: Double? // optional target distance
    var isMain: Bool
    var isArchived: Bool
    let createdAt: Date
    var lastUsedAt: Date?
    
    init(
        id: Int = 0,
        brand: String,
        model: String,
        totalDistance: Double = 0,
        targetDistance: Double? = nil,
        isMain: Bool = false,
        isArchived: Bool = false,
        createdAt: Date = Date(),
        lastUsedAt: Date? = nil
    ) {
        self.id = id
        self.brand = brand
        self.model = model
        self.totalDistance = totalDistance
        self.targetDistance = targetDistance
        self.isMain = isMain
        self.isArchived = isArchived
        self.createdAt = createdAt
        self.lastUsedAt = lastUsedAt
    }
    
    var displayName: String {
        "\(brand) \(model)"
    }
    
    var formattedDistance: String {
        String(format: "%.1fkm", totalDistance)
    }
}
