import Foundation
import SwiftUI

@MainActor
class AddShoeViewModel: ObservableObject {
    @Published var brand = ""
    @Published var model = ""
    @Published var targetDistance = ""
    
    var isFormValid: Bool {
        !brand.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && 
        !model.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    var targetDistanceValue: Double {
        guard !targetDistance.isEmpty else { return 0.0 }
        return Double(targetDistance)!
    }
    
    func createShoe() -> AddShoeViewDto {
        return AddShoeViewDto(
            brand: brand.trimmingCharacters(in: .whitespacesAndNewlines),
            model: model.trimmingCharacters(in: .whitespacesAndNewlines),
            targetDistance: targetDistanceValue,
        )
    }
    
    func reset() {
        brand = ""
        model = ""
        targetDistance = ""
    }
}
