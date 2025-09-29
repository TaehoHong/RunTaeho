import Foundation
import SwiftUI

@MainActor
class AddShoeViewModel: ObservableObject {
    @Published var brand = ""
    @Published var model = ""
    @Published var targetDistanceKm = ""
    
    var isFormValid: Bool {
        !brand.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && 
        !model.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    var targetDistanceMeter: Int {
        guard !targetDistanceKm.isEmpty else { return 0}
        return Int(targetDistanceKm)! * 1000
    }
    
    func createShoe() -> AddShoeViewDto {
        return AddShoeViewDto(
            brand: brand.trimmingCharacters(in: .whitespacesAndNewlines),
            model: model.trimmingCharacters(in: .whitespacesAndNewlines),
            targetDistance: targetDistanceMeter,
        )
    }
    
    func reset() {
        brand = ""
        model = ""
        targetDistanceKm = ""
    }
}
