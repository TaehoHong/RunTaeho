import Foundation
import CoreLocation

// 러닝 데이터 관리자
class RunningDataManager {
    static let shared = RunningDataManager()
    
    private let documentsDirectory: URL
    private let runningDataFileName = "running_data.json"
    private let tempDataFileName = "temp_running_data.json"
    
    // MARK: - 현재 러닝 세션 관리
    private var currentRunningRecord: RunningRecord?
    private var currentRunningSegments: [RunningRecordItem] = []
    private var segmentIdCounter: Int = 1
    
    private init() {
        documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
    
    // MARK: - 러닝 세션 관리
    
    /// 새 러닝 세션 시작 (서버에서 받은 ID 또는 0)
    func startNewRunningSession(record: RunningRecord) {
        currentRunningRecord = record
        currentRunningSegments.removeAll()
        segmentIdCounter = 1
        
        print("🏃‍♂️ 새 러닝 세션 시작: Record ID = \(record.id)")
    }
    
    /// 10m마다 세그먼트 추가
    func addRunningSegment(
        distance: Double,
        cadence: Int = 0,
        heartRate: Int,
        calories: Int,
        duration: TimeInterval,
        startTimestamp: TimeInterval,
        locations: [LocationData]
    ) {
        guard let currentRecord = currentRunningRecord else {
            print("❌ 현재 러닝 세션이 없습니다.")
            return
        }
        
        let segment = RunningRecordItem(
            id: segmentIdCounter,
            distance: distance,
            cadence: cadence,
            hartRate: heartRate,
            calories: calories,
            orderIndex: segmentIdCounter - 1,
            durationSec: duration,
            startTimestamp: startTimestamp,
            locations: locations
        )
        
        currentRunningSegments.append(segment)
        segmentIdCounter += 1
        
        print("📍 세그먼트 추가: \(distance)m, 총 세그먼트 수: \(currentRunningSegments.count)")
        
        // 임시 저장 (백그라운드 대비)
        saveTempSessionData()
    }
    
    /// 현재 세그먼트들 반환
    func getCurrentSegments() -> [RunningRecordItem] {
        return currentRunningSegments
    }
    
    /// 현재 러닝 기록 반환
    func getCurrentRunningRecord() -> RunningRecord? {
        return currentRunningRecord
    }
    
    /// 러닝 세션 완료 - 최종 통계 계산 및 반환
    func finishRunningSession() -> (RunningRecord, [RunningRecordItem])? {
        guard var finalRecord = currentRunningRecord else {
            print("❌ 현재 러닝 세션이 없습니다.")
            return nil
        }
        
        // 세그먼트들로부터 총합 계산
        let totalDistance = currentRunningSegments.reduce(0) { $0 + $1.distance }
        let totalCalories = currentRunningSegments.reduce(0) { $0 + $1.calories }
        let totalDuration = currentRunningSegments.reduce(0) { $0 + $1.durationSec }
        let avgHeartRate = currentRunningSegments.isEmpty ? 0 : 
            currentRunningSegments.reduce(0) { $0 + $1.hartRate } / currentRunningSegments.count
        let avgCadence = currentRunningSegments.isEmpty ? 0 :
            currentRunningSegments.reduce(0) { $0 + $1.cadence } / currentRunningSegments.count
        
        // RunningRecord 업데이트 (새로운 생성자가 필요할 수 있음)
        let updatedRecord = RunningRecord(
            id: finalRecord.id,
            distance: totalDistance,
            cadence: avgCadence,
            heartRate: avgHeartRate,
            calorie: Int(totalCalories),
            durationSec: totalDuration,
            startTimestamp: finalRecord.startTimestamp
        )
        
        let segments = currentRunningSegments
        
        // 현재 세션 초기화
        currentRunningRecord = nil
        currentRunningSegments.removeAll()
        segmentIdCounter = 1
        
        // 임시 데이터 삭제
        deleteTempData()
        
        print("✅ 러닝 세션 완료: 총 거리 \(totalDistance)m, 총 시간 \(totalDuration)초, 세그먼트 수 \(segments.count)")
        
        return (updatedRecord, segments)
    }
    
    /// 현재 세션 취소
    func cancelCurrentSession() {
        currentRunningRecord = nil
        currentRunningSegments.removeAll()
        segmentIdCounter = 1
        deleteTempData()
        print("❌ 러닝 세션이 취소되었습니다.")
    }
    
    // MARK: - 임시 데이터 저장 (세션 복구용)
    
    /// 현재 세션 데이터를 임시 저장
    private func saveTempSessionData() {
        guard let currentRecord = currentRunningRecord else { return }
        
        let tempData: [String: Any] = [
            "runningRecord": [
                "id": currentRecord.id,
                "startTimestamp": currentRecord.startTimestamp
            ],
            "segments": currentRunningSegments.map { segment in
                [
                    "id": segment.id,
                    "distance": segment.distance,
                    "cadence": segment.cadence,
                    "hartRate": segment.hartRate,
                    "calories": segment.calories,
                    "orderIndex": segment.orderIndex,
                    "durationSec": segment.durationSec,
                    "startTimestamp": segment.startTimestamp,
                    "locations": segment.locations?.map { location in
                        [
                            "latitude": location.latitude,
                            "longitude": location.longitude,
                            "timestamp": location.timestamp.timeIntervalSince1970,
                            "speed": location.speed,
                            "altitude": location.altitude
                        ]
                    } ?? []
                ]
            },
            "segmentIdCounter": segmentIdCounter,
            "lastSaved": Date().timeIntervalSince1970
        ]
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: tempData)
            let fileURL = documentsDirectory.appendingPathComponent(tempDataFileName)
            try jsonData.write(to: fileURL)
        } catch {
            print("❌ 임시 세션 데이터 저장 실패: \(error)")
        }
    }
    
    /// 임시 세션 데이터 복원
    func loadTempSessionData() -> (record: RunningRecord, segments: [RunningRecordItem])? {
        let fileURL = documentsDirectory.appendingPathComponent(tempDataFileName)
        
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            return nil
        }
        
        do {
            let jsonData = try Data(contentsOf: fileURL)
            let tempData = try JSONSerialization.jsonObject(with: jsonData) as? [String: Any]
            
            guard let recordData = tempData?["runningRecord"] as? [String: Any],
                  let recordId = recordData["id"] as? Int,
                  let startTimestamp = recordData["startTimestamp"] as? TimeInterval,
                  let segmentsData = tempData?["segments"] as? [[String: Any]],
                  let savedSegmentIdCounter = tempData?["segmentIdCounter"] as? Int else {
                return nil
            }
            
            // RunningRecord 복원
            let restoredRecord = RunningRecord(id: recordId)
            
            // 세그먼트들 복원
            let restoredSegments = segmentsData.compactMap { segmentDict -> RunningRecordItem? in
                guard let id = segmentDict["id"] as? Int,
                      let distance = segmentDict["distance"] as? Double,
                      let cadence = segmentDict["cadence"] as? Int,
                      let hartRate = segmentDict["hartRate"] as? Int,
                      let calories = segmentDict["calories"] as? Int,
                      let orderIndex = segmentDict["orderIndex"] as? Int,
                      let durationSec = segmentDict["durationSec"] as? TimeInterval,
                      let startTimestamp = segmentDict["startTimestamp"] as? TimeInterval,
                      let locationsData = segmentDict["locations"] as? [[String: Any]] else {
                    return nil
                }
                
                let locations = locationsData.compactMap { locationDict -> LocationData? in
                    guard let latitude = locationDict["latitude"] as? Double,
                          let longitude = locationDict["longitude"] as? Double,
                          let timestamp = locationDict["timestamp"] as? TimeInterval,
                          let speed = locationDict["speed"] as? Double,
                          let altitude = locationDict["altitude"] as? Double else {
                        return nil
                    }
                    
                    return LocationData(
                        latitude: latitude,
                        longitude: longitude,
                        timestamp: Date(timeIntervalSince1970: timestamp),
                        speed: speed,
                        altitude: altitude
                    )
                }
                
                return RunningRecordItem(
                    id: id,
                    distance: distance,
                    cadence: cadence,
                    hartRate: hartRate,
                    calories: calories,
                    orderIndex: orderIndex,
                    durationSec: durationSec,
                    startTimestamp: startTimestamp,
                    locations: locations
                )
            }
            
            print("✅ 임시 세션 데이터 복원 완료: Record ID \(recordId), 세그먼트 수 \(restoredSegments.count)")
            return (restoredRecord, restoredSegments)
        } catch {
            print("❌ 임시 세션 데이터 복원 실패: \(error)")
            return nil
        }
    }
    
    /// 복원된 세션 데이터로 현재 세션 설정
    func restoreSession(record: RunningRecord, segments: [RunningRecordItem]) {
        currentRunningRecord = record
        currentRunningSegments = segments
        segmentIdCounter = segments.count + 1
        
        print("🔄 세션 복원 완료: Record ID \(record.id), 세그먼트 수 \(segments.count)")
    }
    
    
    // MARK: - 데이터 저장/로드
    
    /// 완료된 러닝 기록 저장 (서버 전송 후 로컬 저장용)
    func saveCompletedRunningRecord(_ record: RunningRecord, segments: [RunningRecordItem]) {
        // TODO: 완료된 러닝 기록을 로컬 DB에 저장
        // 현재는 기존 방식과 호환성을 위해 segments만 저장
        var allSegments = loadAllRunningData()
        allSegments.append(contentsOf: segments)
        
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let jsonData = try encoder.encode(allSegments)
            let fileURL = documentsDirectory.appendingPathComponent(runningDataFileName)
            try jsonData.write(to: fileURL)
            
            print("✅ 완료된 러닝 기록 저장: Record ID \(record.id), 세그먼트 수 \(segments.count)")
        } catch {
            print("❌ 완료된 러닝 기록 저장 실패: \(error)")
        }
    }
    
    /// 모든 러닝 데이터 불러오기 (기존 호환성 유지)
    func loadAllRunningData() -> [RunningRecordItem] {
        let fileURL = documentsDirectory.appendingPathComponent(runningDataFileName)
        
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            return []
        }
        
        do {
            let jsonData = try Data(contentsOf: fileURL)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            return try decoder.decode([RunningRecordItem].self, from: jsonData)
        } catch {
            print("❌ 러닝 데이터 불러오기 실패: \(error)")
            return []
        }
    }
    
    // MARK: - 유틸리티
    
    /// 임시 데이터 삭제
    func deleteTempData() {
        let fileURL = documentsDirectory.appendingPathComponent(tempDataFileName)
        
        try? FileManager.default.removeItem(at: fileURL)
    }
    
    /// 현재 세션이 진행 중인지 확인
    func hasActiveSession() -> Bool {
        return currentRunningRecord != nil
    }
    
    /// 현재 세션의 통계 요약
    func getCurrentSessionSummary() -> (distance: Double, segments: Int, duration: TimeInterval)? {
        guard currentRunningRecord != nil else { return nil }
        
        let totalDistance = currentRunningSegments.reduce(0) { $0 + $1.distance }
        let totalDuration = currentRunningSegments.reduce(0) { $0 + $1.durationSec }
        
        return (totalDistance, currentRunningSegments.count, totalDuration)
    }
}
