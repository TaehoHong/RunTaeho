import Foundation
import SwiftUI

class RunningFinishedViewModel: ObservableObject {
    @Published private(set) var distanceText: String = ""
    @Published private(set) var timeText: String = ""
    @Published private(set) var calorieText: String = ""
    @Published private(set) var heartRateText: String = ""
    @Published private(set) var paceText: String = ""
    @Published private(set) var earnedPointsText: String = ""
    @Published private(set) var totalPointsText: String = ""
    @Published private(set) var shoeBrand: String = ""
    @Published private(set) var shoeModel: String = ""
    @Published private(set) var shoeTotalDistance: String = ""
    @Published private(set) var hasShoe: Bool = false
    
    // 신발 목록 관련
    @Published private(set) var availableShoes: [Shoe] = []
    @Published private(set) var selectedShoeIndex: Int = 0
    @Published private(set) var currentShoe: Shoe?
    
    private let runningRecord: RunningRecord
    private let earnedPoints: Int
    private let totalPoints: Int
    private let selectedShoe: Shoe?
    private let onComplete: () -> Void
    
    init(runningRecord: RunningRecord, earnedPoints: Int, totalPoints: Int, selectedShoe: Shoe? = nil, onComplete: @escaping () -> Void) {
        self.runningRecord = runningRecord
        self.earnedPoints = earnedPoints
        self.totalPoints = totalPoints
        self.selectedShoe = selectedShoe
        self.onComplete = onComplete
        
        setupDisplayData()
        loadAvailableShoes()
    }
    
    private func setupDisplayData() {
        // Distance formatting
        distanceText = String(format: "%.1f km", runningRecord.distance / 1000)
        
        // Time formatting
        timeText = formatTime(seconds: Int(runningRecord.durationSec))
        
        // Calorie formatting
        calorieText = "\(runningRecord.calorie)"
        
        // Heart rate formatting
        heartRateText = "\(runningRecord.heartRate)"
        
        // Pace formatting
        paceText = formatPace(distance: runningRecord.distance, duration: runningRecord.durationSec)
        
        // Points formatting
        earnedPointsText = "+\(earnedPoints)P"
        totalPointsText = "\(totalPoints)P"
        
        // Shoe information - 현재 선택된 신발 정보 업데이트
        updateCurrentShoeInfo()
    }
    
    private func formatTime(seconds: Int) -> String {
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        let secs = seconds % 60
        
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, secs)
        } else {
            return String(format: "%d:%02d", minutes, secs)
        }
    }
    
    private func formatPace(distance: Double, duration: TimeInterval) -> String {
        guard distance > 0 else { return "0'00\"" }
        
        let paceSecondsPerKm = (duration * 1000) / distance
        let minutes = Int(paceSecondsPerKm) / 60
        let seconds = Int(paceSecondsPerKm) % 60
        
        return String(format: "%d'%02d\"", minutes, seconds)
    }
    
    // MARK: - 신발 관련 메서드
    
    private func loadAvailableShoes() {
        // TODO: API 호출로 신발 목록 로드
        // 임시 데이터로 대체
        availableShoes = getSampleShoes()
        
        // 선택된 신발이 있으면 해당 인덱스로 설정
        if let selectedShoe = selectedShoe,
           let index = availableShoes.firstIndex(where: { $0.id == selectedShoe.id }) {
            selectedShoeIndex = index
        } else if !availableShoes.isEmpty {
            selectedShoeIndex = 0
        }
        
        updateCurrentShoeInfo()
    }
    
    private func getSampleShoes() -> [Shoe] {
        return [
            Shoe(id: 1, brand: "Nike", model: "Air Zoom Pegasus 40", totalDistance: 127, isMain: true, isEnabled: true),
            Shoe(id: 2, brand: "Adidas", model: "Ultraboost 22", totalDistance: 85, isMain: false, isEnabled: true),
            Shoe(id: 3, brand: "ASICS", model: "Gel-Nimbus 25", totalDistance: 203, isMain: false, isEnabled: true),
            Shoe(id: 4, brand: "New Balance", model: "Fresh Foam X 1080", totalDistance: 156, isMain: false, isEnabled: true)
        ]
    }
    
    private func updateCurrentShoeInfo() {
        if selectedShoeIndex < availableShoes.count {
            currentShoe = availableShoes[selectedShoeIndex]
            hasShoe = true
            shoeBrand = currentShoe?.brand ?? ""
            shoeModel = currentShoe?.model ?? ""
            shoeTotalDistance = "누적거리: \(String(format: "%.1f", Double(currentShoe?.totalDistance ?? 0)))km"
        } else {
            currentShoe = nil
            hasShoe = false
            shoeBrand = ""
            shoeModel = ""
            shoeTotalDistance = ""
        }
    }
    
    func selectPreviousShoe() {
        guard !availableShoes.isEmpty else { return }
        selectedShoeIndex = selectedShoeIndex > 0 ? selectedShoeIndex - 1 : availableShoes.count - 1
        updateCurrentShoeInfo()
    }
    
    func selectNextShoe() {
        guard !availableShoes.isEmpty else { return }
        selectedShoeIndex = selectedShoeIndex < availableShoes.count - 1 ? selectedShoeIndex + 1 : 0
        updateCurrentShoeInfo()
    }
    
    // MARK: - Actions
    func onCompleteButtonTapped() {
        onComplete()
    }
    
    // MARK: - Computed Properties for Colors
    var earnedPointsColor: Color {
        return Color(red: 0.48, green: 0.91, blue: 0.48)
    }
    
    var completeButtonColor: Color {
        return Color(red: 0.48, green: 0.91, blue: 0.48)
    }
}
