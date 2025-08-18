import Foundation
import HealthKit
import WatchConnectivity
import CoreMotion
import Combine

class HealthDataManager: NSObject, ObservableObject {
    private let healthStore = HKHealthStore()
    private let pedometer = CMPedometer()
    private var workoutBuilder: HKWorkoutBuilder?
    private var workoutStartDate: Date?
    private let watchDataProvider = WatchDataProvider()
    
    // Query management to prevent memory leaks
    private var activeQueries: [HKQuery] = []
    private var heartRateQuery: HKAnchoredObjectQuery?
    
    // Published properties for UI updates
    @Published var heartRate: Double = 0.0
    @Published var isWatchConnected: Bool = false
    @Published var cadence: Double = 0.0
    @Published var distance: Double = 0.0
    @Published var activeEnergyBurned: Double = 0.0
    @Published var isHealthKitAuthorized: Bool = false
    
    // Data storage with performance optimization
    private var heartRateData: [Double] = []
    private var cadenceData: [Double] = []
    private var cancellables = Set<AnyCancellable>()
    
    // Performance: Limit data array sizes to prevent memory issues
    private let maxDataPoints: Int = 1000 // Keep last 1000 data points
    private let dataCleanupThreshold: Int = 1200 // Trigger cleanup when reaching this size
    
    override init() {
        super.init()
        setupWatchDataProvider()
        requestHealthKitAuthorization()
    }
    
    deinit {
        stopAllQueries()
        pedometer.stopUpdates()
        watchDataProvider.stopDataCollection()
    }
    
    // MARK: - HealthKit Setup
    private func requestHealthKitAuthorization() {
        guard HKHealthStore.isHealthDataAvailable() else {
            print("HealthKit is not available on this device")
            return
        }
        
        let typesToRead: Set<HKObjectType> = [
            HKQuantityType.quantityType(forIdentifier: .heartRate)!,
            HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!,
            HKQuantityType.quantityType(forIdentifier: .stepCount)!,
            HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!,
            HKWorkoutType.workoutType()
        ]
        
        let typesToWrite: Set<HKSampleType> = [
            HKQuantityType.quantityType(forIdentifier: .heartRate)!,
            HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!,
            HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!,
            HKWorkoutType.workoutType()
        ]
        
        healthStore.requestAuthorization(toShare: typesToWrite, read: typesToRead) { [weak self] success, error in
            DispatchQueue.main.async {
                self?.isHealthKitAuthorized = success
                if success {
                    print("HealthKit authorization granted")
                } else {
                    print("HealthKit authorization denied: \(error?.localizedDescription ?? "Unknown error")")
                }
            }
        }
    }
    
    // MARK: - Watch Data Provider Setup
    private func setupWatchDataProvider() {
        watchDataProvider.delegate = self
    }
    
    // MARK: - Workout Session Management
    func startWorkout() {
        guard isHealthKitAuthorized else {
            print("HealthKit not authorized")
            return
        }
        
        let configuration = HKWorkoutConfiguration()
        configuration.activityType = .running
        configuration.locationType = .outdoor
        
        // iOS에서는 HKWorkoutBuilder를 사용하여 워크아웃 기록
        workoutBuilder = HKWorkoutBuilder(healthStore: healthStore, configuration: configuration, device: .local())
        workoutStartDate = Date()
        
        workoutBuilder?.beginCollection(withStart: workoutStartDate!) { success, error in
            if success {
                print("Workout builder started successfully")
                self.startRealTimeDataCollection()
            } else {
                print("Failed to start workout builder: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }
    
    func pauseWorkout() {
        // iOS에서는 워크아웃 빌더를 일시정지하지 않고 데이터 수집만 중단
        stopRealTimeDataCollection()
        watchDataProvider.pauseDataCollection()
    }
    
    func resumeWorkout() {
        // 데이터 수집 재개
        startRealTimeDataCollection()
        watchDataProvider.resumeDataCollection()
    }
    
    func endWorkout() {
        stopRealTimeDataCollection()
        watchDataProvider.stopDataCollection()
        
        // 워크아웃 완료 및 저장
        workoutBuilder?.endCollection(withEnd: Date()) { success, error in
            if success {
                self.workoutBuilder?.finishWorkout { workout, error in
                    if let workout = workout {
                        print("Workout saved successfully: \(workout)")
                    } else {
                        print("Failed to save workout: \(error?.localizedDescription ?? "Unknown error")")
                    }
                }
            }
        }
    }
    
    // MARK: - Real-time Data Collection
    private func startRealTimeDataCollection() {
        if isWatchConnected {
            startWatchDataCollection()
        } else {
            startPhoneDataCollection()
        }
    }
    
    private func stopRealTimeDataCollection() {
        // Stop any ongoing data collection
        stopAllQueries()
        pedometer.stopUpdates()
        watchDataProvider.stopDataCollection()
    }
    
    private func stopAllQueries() {
        // Stop heart rate query
        if let query = heartRateQuery {
            healthStore.stop(query)
            heartRateQuery = nil
        }
        
        // Stop all active queries
        for query in activeQueries {
            healthStore.stop(query)
        }
        activeQueries.removeAll()
    }
    
    private func startWatchDataCollection() {
        // Request data from Apple Watch
        watchDataProvider.startDataCollection()
    }
    
    private func startPhoneDataCollection() {
        // Collect data from iPhone sensors
        startHeartRateQuery()
        startPedometerUpdates()
    }
    
    // MARK: - iPhone Data Collection
    private func startHeartRateQuery() {
        // Stop any existing query first
        if let existingQuery = heartRateQuery {
            healthStore.stop(existingQuery)
            heartRateQuery = nil
        }
        
        guard let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate) else { return }
        
        let predicate = HKQuery.predicateForSamples(
            withStart: Date().addingTimeInterval(-60),
            end: Date(),
            options: .strictEndDate
        )
        
        let query = HKAnchoredObjectQuery(
            type: heartRateType,
            predicate: predicate,
            anchor: nil,
            limit: HKObjectQueryNoLimit
        ) { [weak self] query, samples, deletedObjects, anchor, error in
            guard let self = self,
                  let samples = samples as? [HKQuantitySample] else { return }
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                if let lastSample = samples.last {
                    let heartRateValue = lastSample.quantity.doubleValue(for: HKUnit.count().unitDivided(by: .minute()))
                    self.heartRate = heartRateValue
                    self.appendHeartRateData(heartRateValue)
                }
            }
        }
        
        query.updateHandler = { [weak self] query, samples, deletedObjects, anchor, error in
            guard let self = self,
                  let samples = samples as? [HKQuantitySample] else { return }
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                if let lastSample = samples.last {
                    let heartRateValue = lastSample.quantity.doubleValue(for: HKUnit.count().unitDivided(by: .minute()))
                    self.heartRate = heartRateValue
                    self.appendHeartRateData(heartRateValue)
                }
            }
        }
        
        // Store query reference and execute
        heartRateQuery = query
        healthStore.execute(query)
    }
    
    private func startPedometerUpdates() {
        if CMPedometer.isCadenceAvailable() {
            pedometer.startUpdates(from: Date()) { [weak self] data, error in
                guard let data = data else { return }
                
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    if let cadenceValue = data.currentCadence?.doubleValue {
                        let spm = cadenceValue * 60 // Convert to steps per minute
                        self.cadence = spm
                        self.appendCadenceData(spm)
                    }
                    
                    if let distance = data.distance?.doubleValue {
                        self.distance = distance
                    }
                }
            }
        }
    }
    
    // MARK: - Watch Communication
    func updateWatchConnectionStatus() {
        isWatchConnected = watchDataProvider.isWatchConnected
    }
    
    // MARK: - Data Management with Performance Optimization
    private func appendHeartRateData(_ value: Double) {
        heartRateData.append(value)
        
        // Clean up old data if array gets too large
        if heartRateData.count > dataCleanupThreshold {
            heartRateData = Array(heartRateData.suffix(maxDataPoints))
        }
    }
    
    private func appendCadenceData(_ value: Double) {
        cadenceData.append(value)
        
        // Clean up old data if array gets too large
        if cadenceData.count > dataCleanupThreshold {
            cadenceData = Array(cadenceData.suffix(maxDataPoints))
        }
    }
    
    // MARK: - Data Retrieval
    func getAverageHeartRate() -> Double {
        guard !heartRateData.isEmpty else { return 0 }
        // Use more efficient calculation for large arrays
        if heartRateData.count > 100 {
            // Sample every nth element for very large arrays
            let sampleRate = max(1, heartRateData.count / 100)
            let sampledData = heartRateData.enumerated().compactMap { index, value in
                index % sampleRate == 0 ? value : nil
            }
            return sampledData.reduce(0, +) / Double(sampledData.count)
        } else {
            return heartRateData.reduce(0, +) / Double(heartRateData.count)
        }
    }
    
    func getAverageCadence() -> Double {
        guard !cadenceData.isEmpty else { return 0 }
        // Use more efficient calculation for large arrays
        if cadenceData.count > 100 {
            let sampleRate = max(1, cadenceData.count / 100)
            let sampledData = cadenceData.enumerated().compactMap { index, value in
                index % sampleRate == 0 ? value : nil
            }
            return sampledData.reduce(0, +) / Double(sampledData.count)
        } else {
            return cadenceData.reduce(0, +) / Double(cadenceData.count)
        }
    }
    
    func clearData() {
        heartRateData.removeAll()
        cadenceData.removeAll()
        heartRate = 0.0
        cadence = 0.0
        distance = 0.0
        activeEnergyBurned = 0.0
        
        // Stop all queries when clearing data
        stopAllQueries()
    }
}

// MARK: - WatchDataProviderDelegate
extension HealthDataManager: WatchDataProviderDelegate {
    func didReceiveHeartRateData(_ heartRate: Double) {
        self.heartRate = heartRate
        self.appendHeartRateData(heartRate)
        // Reduce console logging for performance
        #if DEBUG
        print("❤️ Watch Heart Rate: \(heartRate) BPM")
        #endif
    }
    
    func didReceiveCadenceData(_ cadence: Double) {
        self.cadence = cadence
        self.appendCadenceData(cadence)
        #if DEBUG
        print("👟 Watch Cadence: \(cadence) SPM")
        #endif
    }
    
    func didReceiveDistanceData(_ distance: Double) {
        self.distance = distance
        print("📏 Watch Distance: \(distance) m")
    }
    
    func didReceiveActiveEnergyData(_ energy: Double) {
        self.activeEnergyBurned = energy
        print("🔥 Watch Active Energy: \(energy) kcal")
    }
    
    func didUpdateWatchConnectionStatus(_ isConnected: Bool) {
        self.isWatchConnected = isConnected
        print("⌚ Watch Connection Status: \(isConnected ? "Connected" : "Disconnected")")
    }
}

