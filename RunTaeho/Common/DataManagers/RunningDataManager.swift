import Foundation
import CoreLocation

// 러닝 데이터 관리자
class RunningDataManager {
    static let shared = RunningDataManager()
    
    private let documentsDirectory: URL
    private let runningDataFileName = "running_data.json"
    private let tempDataFileName = "temp_running_data.json"
    
    private init() {
        documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
    
    // MARK: - 임시 데이터 저장 (백그라운드에서 주기적으로 호출)
    func saveTempRunningData(distance: Double, duration: TimeInterval, locations: [CLLocation]) {
        let locationData = locations.map { LocationData(from: $0) }
        
        let tempData: [String: Any] = [
            "distance": distance,
            "duration": duration,
            "locations": locationData.map { location in
                [
                    "latitude": location.latitude,
                    "longitude": location.longitude,
                    "timestamp": location.timestamp.timeIntervalSince1970,
                    "speed": location.speed,
                    "altitude": location.altitude
                ]
            },
            "lastSaved": Date().timeIntervalSince1970
        ]
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: tempData)
            let fileURL = documentsDirectory.appendingPathComponent(tempDataFileName)
            try jsonData.write(to: fileURL)
            
            print("✅ 임시 러닝 데이터 저장 완료: 거리 \(distance)m, 시간 \(duration)초")
        } catch {
            print("❌ 임시 데이터 저장 실패: \(error)")
        }
    }
    
    // MARK: - 임시 데이터 복원
    func loadTempRunningData() -> (distance: Double, duration: TimeInterval, locations: [LocationData])? {
        let fileURL = documentsDirectory.appendingPathComponent(tempDataFileName)
        
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            print("임시 데이터 파일이 없습니다.")
            return nil
        }
        
        do {
            let jsonData = try Data(contentsOf: fileURL)
            let tempData = try JSONSerialization.jsonObject(with: jsonData) as? [String: Any]
            
            guard let distance = tempData?["distance"] as? Double,
                  let duration = tempData?["duration"] as? TimeInterval,
                  let locationsArray = tempData?["locations"] as? [[String: Any]] else {
                return nil
            }
            
            let locations = locationsArray.compactMap { dict -> LocationData? in
                guard let latitude = dict["latitude"] as? Double,
                      let longitude = dict["longitude"] as? Double,
                      let timestamp = dict["timestamp"] as? TimeInterval,
                      let speed = dict["speed"] as? Double,
                      let altitude = dict["altitude"] as? Double else {
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
            
            print("✅ 임시 러닝 데이터 복원 완료")
            return (distance, duration, locations)
        } catch {
            print("❌ 임시 데이터 복원 실패: \(error)")
            return nil
        }
    }
    
    // MARK: - 임시 데이터 삭제
    func deleteTempData() {
        let fileURL = documentsDirectory.appendingPathComponent(tempDataFileName)
        try? FileManager.default.removeItem(at: fileURL)
        print("임시 데이터 삭제됨")
    }
    
    // MARK: - 최종 러닝 데이터 저장
    func saveRunningData(_ data: RunningRecordItem) {
        var allData = loadAllRunningData()
        allData.append(data)
        
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let jsonData = try encoder.encode(allData)
            let fileURL = documentsDirectory.appendingPathComponent(runningDataFileName)
            try jsonData.write(to: fileURL)
            
            print("✅ 러닝 데이터 저장 완료: \(data.distance)m, \(data.durationSec)초")
            
            // 임시 데이터 삭제
            deleteTempData()
        } catch {
            print("❌ 러닝 데이터 저장 실패: \(error)")
        }
    }
    
    // MARK: - 모든 러닝 데이터 불러오기
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
}
