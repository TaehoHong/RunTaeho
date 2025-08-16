import Foundation
import SwiftUI

class RunningFinishedViewModel: ObservableObject {
    @Published private(set) var distanceText: String = ""
    @Published private(set) var timeText: String = ""
    @Published private(set) var calorieText: String = ""
    @Published private(set) var heartRateText: String = ""
    @Published private(set) var paceText: String = ""
    @Published private(set) var shoeBrand: String = ""
    @Published private(set) var shoeModel: String = ""
    @Published private(set) var shoeTotalDistance: String = ""
    @Published private(set) var hasShoe: Bool = false
    
    // 신발 목록 관련
    @Published private(set) var availableShoes: [Shoe] = []
    @Published private(set) var selectedShoeIndex: Int = 0
    @Published private(set) var currentShoe: Shoe?
    @Published private(set) var isLoadingShoes: Bool = false
    @Published private(set) var shoeLoadError: String?
    
    public let earnedPoints: Int
    public let totalPoints: Int
    
    private var runningRecord: RunningRecord
    private let onComplete: () -> Void
    
    private let shoeService = ShoeService.shared
    private let runningRecordService = RunningRecordService.shared
    
    init(runningRecord: RunningRecord, earnedPoints: Int, onComplete: @escaping () -> Void) {
        self.runningRecord = runningRecord
        self.earnedPoints = earnedPoints
        self.totalPoints = UserStateManager.shared.totalPoint
        self.onComplete = onComplete
        
        setupDisplayData()
        Task {
            await loadAvailableShoes()
        }
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
    
    private func loadAvailableShoes() async {
        await MainActor.run {
            isLoadingShoes = true
            shoeLoadError = nil
        }
        
        do {
            var cursor: Int? = nil
            var hasNext = true
            var allShoes: [Shoe] = []
            
            while hasNext {
                let shoePage = try await shoeService.fetchShoes(cursor: cursor, isEnabled: true)
                allShoes.append(contentsOf: shoePage.content)
                cursor = shoePage.cursor
                hasNext = shoePage.hasNext
            }
            
            await MainActor.run {
                self.availableShoes = allShoes
                self.selectedShoeIndex = self.availableShoes.firstIndex(where: { $0.isMain }) ?? 0
                self.isLoadingShoes = false
                self.updateCurrentShoeInfo()
            }
            
        } catch {
            await MainActor.run {
                self.isLoadingShoes = false
                self.shoeLoadError = "신발 정보를 불러오는데 실패했습니다: \(error.localizedDescription)"
                // 에러 발생 시 샘플 데이터로 폴백
                self.selectedShoeIndex = self.availableShoes.firstIndex(where: { $0.isMain }) ?? 0
                self.updateCurrentShoeInfo()
            }
        }
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
        
        self.runningRecord.shoeId = self.currentShoe?.id
        
            Task {
                do {
                    try await runningRecordService.update(runningRecord: self.runningRecord)
                } catch {
                    print("러닝 기록 업데이트 실패 - recordId: \(self.runningRecord.id), error:\(error)")
                }
            }
        
        
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
