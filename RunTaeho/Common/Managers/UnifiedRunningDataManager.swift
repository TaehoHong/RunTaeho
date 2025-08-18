import Foundation
import CoreLocation
import HealthKit
import CoreMotion
import Combine

// MARK: - Data Models
struct RunningMetrics: Equatable {
    let heartRate: Int
    var cadence: Int
    let distance: Double // meters
    let pace: PaceData
    let speed: Double // km/h
    let calories: Double
    let timestamp: Date
    
    struct PaceData: Equatable {
        let minutes: Int
        let seconds: Int
        let totalSeconds: Double
        
        init(totalSeconds: Double) {
            let clampedSeconds = max(0, totalSeconds)
            self.totalSeconds = clampedSeconds
            self.minutes = Int(clampedSeconds) / 60
            self.seconds = Int(clampedSeconds) % 60
        }
        
        /// Human readable pace string (e.g. "5:30")
        var formatted: String {
            return String(format: "%d:%02d", minutes, seconds)
        }
    }
    
    /// Initialize with safe defaults
    static let zero = RunningMetrics(
        heartRate: 0,
        cadence: 0,
        distance: 0.0,
        pace: PaceData(totalSeconds: 0),
        speed: 0.0,
        calories: 0.0,
        timestamp: Date()
    )
}

// MARK: - Data Source Types
enum DataSourceType: CaseIterable, Hashable {
    case watch
    case phone
    case healthKit
    case mock // for testing
    
    /// Human readable name for the data source
    var displayName: String {
        switch self {
        case .watch: return "Apple Watch"
        case .phone: return "iPhone"
        case .healthKit: return "HealthKit"
        case .mock: return "Test Data"
        }
    }
    
    /// Icon name for the data source
    var iconName: String {
        switch self {
        case .watch: return "applewatch"
        case .phone: return "iphone"
        case .healthKit: return "heart.fill"
        case .mock: return "testtube.2"
        }
    }
}

struct DataSourcePriority {
    /// Priority order for heart rate data (highest to lowest)
    static let heartRate: [DataSourceType] = [.watch, .healthKit, .mock]
    
    /// Priority order for cadence data (highest to lowest)
    static let cadence: [DataSourceType] = [.watch, .phone, .mock]
    
    /// Priority order for distance data (highest to lowest)
    static let distance: [DataSourceType] = [.watch, .phone]
    
    /// Priority order for location data (highest to lowest)
    static let location: [DataSourceType] = [.phone, .watch]
}

// MARK: - Data Source Protocol
protocol RunningDataSourceProtocol: AnyObject {
    var heartRate: Double { get }
    var cadence: Double { get }
    var distance: Double { get }
    var isAvailable: Bool { get }
    var sourceType: DataSourceType { get }
    
    /// Start data collection
    func startTracking()
    
    /// Pause data collection (keep sensors active)
    func pauseTracking()
    
    /// Resume data collection
    func resumeTracking()
    
    /// Stop data collection and clean up
    func stopTracking()
}

// MARK: - Error Types
enum UnifiedDataManagerError: Error, LocalizedError {
    case trackingAlreadyActive
    case trackingNotActive
    case noAvailableDataSources
    case invalidConfiguration
    
    var errorDescription: String? {
        switch self {
        case .trackingAlreadyActive:
            return "Tracking is already active"
        case .trackingNotActive:
            return "Tracking is not currently active"
        case .noAvailableDataSources:
            return "No data sources are available"
        case .invalidConfiguration:
            return "Invalid data manager configuration"
        }
    }
}

// MARK: - Main Unified Data Manager
class UnifiedRunningDataManager: ObservableObject {
    
    // MARK: - Published Properties
    @Published private(set) var currentMetrics: RunningMetrics = .zero
    @Published private(set) var isTrackingActive: Bool = false
    @Published private(set) var activeDataSources: Set<DataSourceType> = []
    @Published private(set) var lastError: UnifiedDataManagerError?
    
    // MARK: - Data Sources
    private let healthDataSource: HealthDataSource
    private let watchDataSource: WatchDataSource
    private let phoneDataSource: PhoneDataSource
    private let mockDataSource: MockDataSource
    
    // MARK: - Internal State
    private var allDataSources: [RunningDataSourceProtocol] {
        [healthDataSource, watchDataSource, phoneDataSource, mockDataSource]
    }
    
    private var startTime: Date?
    private var totalDistance: Double = 0.0
    private var lastUpdateTime: Date = Date()
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Configuration
    private let updateInterval: TimeInterval = 1.0 // seconds
    private let userWeight: Double = 70.0 // kg - should come from user settings
    
    // MARK: - Initialization
    init(healthDataManager: HealthDataManager? = nil, 
         watchDataProvider: WatchDataProvider? = nil,
         locationManager: LocationManager? = nil) {
        
        self.healthDataSource = HealthDataSource(healthDataManager: healthDataManager)
        self.watchDataSource = WatchDataSource(watchDataProvider: watchDataProvider)
        self.phoneDataSource = PhoneDataSource(locationManager: locationManager)
        self.mockDataSource = MockDataSource()
        
        setupDataSourceObservers()
        updateActiveDataSources()
    }
    
    deinit {
        stopTracking()
    }
    
    // MARK: - Public Methods
    @discardableResult
    func startTracking() -> Result<Void, UnifiedDataManagerError> {
        guard !isTrackingActive else {
            lastError = .trackingAlreadyActive
            return .failure(.trackingAlreadyActive)
        }
        
        updateActiveDataSources()
        
        guard !activeDataSources.isEmpty else {
            lastError = .noAvailableDataSources
            return .failure(.noAvailableDataSources)
        }
        
        isTrackingActive = true
        startTime = Date()
        totalDistance = 0.0
        lastUpdateTime = Date()
        lastError = nil
        
        // Start all available data sources
        healthDataSource.startTracking()
        watchDataSource.startTracking()
        phoneDataSource.startTracking()
        
        startMetricsUpdateTimer()
        
        print("🏃 Unified tracking started with sources: \(activeDataSources)")
        return .success(())
    }
    
    @discardableResult
    func pauseTracking() -> Result<Void, UnifiedDataManagerError> {
        guard isTrackingActive else {
            lastError = .trackingNotActive
            return .failure(.trackingNotActive)
        }
        
        // Pause data collection but keep sources active
        healthDataSource.pauseTracking()
        watchDataSource.pauseTracking()
        phoneDataSource.pauseTracking()
        
        print("⏸️ Unified tracking paused")
        return .success(())
    }
    
    @discardableResult
    func resumeTracking() -> Result<Void, UnifiedDataManagerError> {
        guard isTrackingActive else {
            lastError = .trackingNotActive
            return .failure(.trackingNotActive)
        }
        
        healthDataSource.resumeTracking()
        watchDataSource.resumeTracking()
        phoneDataSource.resumeTracking()
        
        lastUpdateTime = Date()
        
        print("▶️ Unified tracking resumed")
        return .success(())
    }
    
    func stopTracking() {
        guard isTrackingActive else { return }
        
        isTrackingActive = false
        
        healthDataSource.stopTracking()
        watchDataSource.stopTracking()
        phoneDataSource.stopTracking()
        
        activeDataSources.removeAll()
        
        print("🛑 Unified tracking stopped")
    }
    
    // MARK: - Data Source Management
    private func setupDataSourceObservers() {
        // Observe changes from all data sources
        Timer.scheduledTimer(withTimeInterval: updateInterval, repeats: true) { [weak self] _ in
            guard let self = self, self.isTrackingActive else { return }
            self.updateMetrics()
        }
    }
    
    private func updateActiveDataSources() {
        activeDataSources = Set(allDataSources.compactMap { source in
            source.isAvailable ? source.sourceType : nil
        })
    }
    
    private func startMetricsUpdateTimer() {
        // Real-time updates while tracking
    }
    
    // MARK: - Metrics Calculation
    private func updateMetrics() {
        updateActiveDataSources()
        
        let heartRate = getBestDataForHeartRate()
        let cadence = getBestDataForCadence()
        let distance = getBestDataForDistance()
        
        // Update total distance
        let distanceDelta = distance - currentMetrics.distance
        if distanceDelta > 0 {
            totalDistance += distanceDelta
        }
        
        // Calculate derived metrics
        let elapsedTime = Date().timeIntervalSince(startTime ?? Date())
        let pace = calculatePace(distance: totalDistance, time: elapsedTime)
        let speed = calculateSpeed(distance: totalDistance, time: elapsedTime)
        let calories = calculateCalories(time: elapsedTime)
        
        // Create new metrics
        let newMetrics = RunningMetrics(
            heartRate: heartRate,
            cadence: cadence,
            distance: totalDistance,
            pace: pace,
            speed: speed,
            calories: calories,
            timestamp: Date()
        )
        
        // Update on main thread
        DispatchQueue.main.async {
            self.currentMetrics = newMetrics
        }
        
        lastUpdateTime = Date()
    }
    
    // MARK: - Data Source Selection Logic
    private func getBestDataForHeartRate() -> Int {
        for sourceType in DataSourcePriority.heartRate {
            if let source = getDataSource(for: sourceType), source.isAvailable {
                let value = source.heartRate
                if value > 0 {
                    return Int(value)
                }
            }
        }
        return 0
    }
    
    private func getBestDataForCadence() -> Int {
        for sourceType in DataSourcePriority.cadence {
            if let source = getDataSource(for: sourceType), source.isAvailable {
                let value = source.cadence
                if value > 0 {
                    return Int(value)
                }
            }
        }
        return 0
    }
    
    private func getBestDataForDistance() -> Double {
        for sourceType in DataSourcePriority.distance {
            if let source = getDataSource(for: sourceType), source.isAvailable {
                let value = source.distance
                if value > 0 {
                    return value
                }
            }
        }
        return currentMetrics.distance
    }
    
    private func getDataSource(for type: DataSourceType) -> RunningDataSourceProtocol? {
        switch type {
        case .watch:
            return watchDataSource
        case .phone:
            return phoneDataSource
        case .healthKit:
            return healthDataSource
        case .mock:
            return mockDataSource
        }
    }
    
    // MARK: - Calculations
    private func calculatePace(distance: Double, time: TimeInterval) -> RunningMetrics.PaceData {
        guard distance > 0 else {
            return RunningMetrics.PaceData(totalSeconds: 0)
        }
        
        let paceSeconds = (time / distance) * 1000 // pace per kilometer
        return RunningMetrics.PaceData(totalSeconds: paceSeconds)
    }
    
    private func calculateSpeed(distance: Double, time: TimeInterval) -> Double {
        guard time > 0 else { return 0.0 }
        return (distance / time) * 3.6 // m/s to km/h
    }
    
    private func calculateCalories(time: TimeInterval) -> Double {
        // MET calculation: MET * weight(kg) * time(hours)
        let runningMET = 9.8 // Average for 8km/h running
        let hours = time / 3600.0
        return runningMET * userWeight * hours
    }
    
    // MARK: - Debug Information
    func getDebugInfo() -> String {
        return """
        🏃 Unified Running Data Manager Status:
        - Tracking Active: \(isTrackingActive)
        - Active Sources: \(activeDataSources.map { "\($0)" }.joined(separator: ", "))
        - Heart Rate: \(currentMetrics.heartRate) BPM
        - Cadence: \(currentMetrics.cadence) SPM
        - Distance: \(String(format: "%.2f", currentMetrics.distance))m
        - Pace: \(currentMetrics.pace.minutes):\(String(format: "%02d", currentMetrics.pace.seconds)) /km
        - Speed: \(String(format: "%.2f", currentMetrics.speed)) km/h
        - Calories: \(String(format: "%.1f", currentMetrics.calories)) kcal
        """
    }
}

// MARK: - Data Source Implementations
private class HealthDataSource: RunningDataSourceProtocol {
    var heartRate: Double { healthDataManager?.heartRate ?? 0.0 }
    var cadence: Double { healthDataManager?.cadence ?? 0.0 }
    var distance: Double { healthDataManager?.distance ?? 0.0 }
    var isAvailable: Bool { healthDataManager?.isHealthKitAuthorized ?? false }
    let sourceType: DataSourceType = .healthKit
    
    private weak var healthDataManager: HealthDataManager?
    
    init(healthDataManager: HealthDataManager?) {
        self.healthDataManager = healthDataManager
    }
    
    func startTracking() {
        healthDataManager?.startWorkout()
    }
    
    func pauseTracking() {
        healthDataManager?.pauseWorkout()
    }
    
    func resumeTracking() {
        healthDataManager?.resumeWorkout()
    }
    
    func stopTracking() {
        healthDataManager?.endWorkout()
    }
}

private class WatchDataSource: RunningDataSourceProtocol {
    var heartRate: Double { _heartRate }
    var cadence: Double { _cadence }
    var distance: Double { _distance }
    var isAvailable: Bool { watchDataProvider?.isWatchConnected ?? false }
    let sourceType: DataSourceType = .watch
    
    private weak var watchDataProvider: WatchDataProvider?
    private var _heartRate: Double = 0.0
    private var _cadence: Double = 0.0
    private var _distance: Double = 0.0
    
    init(watchDataProvider: WatchDataProvider?) {
        self.watchDataProvider = watchDataProvider
        self.watchDataProvider?.delegate = self
    }
    
    func startTracking() {
        watchDataProvider?.startDataCollection()
    }
    
    func pauseTracking() {
        watchDataProvider?.pauseDataCollection()
    }
    
    func resumeTracking() {
        watchDataProvider?.resumeDataCollection()
    }
    
    func stopTracking() {
        watchDataProvider?.stopDataCollection()
    }
}

// MARK: - WatchDataSource + WatchDataProviderDelegate
extension WatchDataSource: WatchDataProviderDelegate {
    func didReceiveHeartRateData(_ heartRate: Double) {
        _heartRate = heartRate
    }
    
    func didReceiveCadenceData(_ cadence: Double) {
        _cadence = cadence
    }
    
    func didReceiveDistanceData(_ distance: Double) {
        _distance = distance
    }
    
    func didReceiveActiveEnergyData(_ energy: Double) {
        // Handle energy data if needed
    }
    
    func didUpdateWatchConnectionStatus(_ isConnected: Bool) {
        // Handle connection status if needed
    }
}

private class PhoneDataSource: RunningDataSourceProtocol {
    var heartRate: Double = 0.0
    var cadence: Double { _cadence }
    var distance: Double { locationManager?.getTotalDistance() ?? 0.0 }
    var isAvailable: Bool { locationManager != nil }
    let sourceType: DataSourceType = .phone
    
    private weak var locationManager: LocationManager?
    private let pedometer = CMPedometer()
    private var _cadence: Double = 0.0
    
    init(locationManager: LocationManager?) {
        self.locationManager = locationManager
    }
    
    func startTracking() {
        locationManager?.startTracking()
        startPedometerTracking()
    }
    
    func pauseTracking() {
        locationManager?.pauseTracking()
        pedometer.stopUpdates()
    }
    
    func resumeTracking() {
        locationManager?.resumeTracking()
        startPedometerTracking()
    }
    
    func stopTracking() {
        locationManager?.stopTracking()
        pedometer.stopUpdates()
    }
    
    private func startPedometerTracking() {
        if CMPedometer.isCadenceAvailable() {
            pedometer.startUpdates(from: Date()) { [weak self] data, error in
                guard let data = data else { return }
                
                DispatchQueue.main.async {
                    if let cadenceValue = data.currentCadence?.doubleValue {
                        self?._cadence = cadenceValue * 60 // Convert to steps per minute
                    }
                }
            }
        }
    }
}

private class MockDataSource: RunningDataSourceProtocol {
    var heartRate: Double = 0.0
    var cadence: Double = 0.0
    var distance: Double = 0.0
    var isAvailable: Bool = true // Always available for testing
    let sourceType: DataSourceType = .mock
    
    private var isTracking = false
    private var timer: Timer?
    
    func startTracking() {
        isTracking = true
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.generateMockData()
        }
    }
    
    func pauseTracking() {
        // Keep generating data but mark as paused if needed
    }
    
    func resumeTracking() {
        // Resume normal operation
    }
    
    func stopTracking() {
        isTracking = false
        timer?.invalidate()
        timer = nil
        
        heartRate = 0.0
        cadence = 0.0
        distance = 0.0
    }
    
    private func generateMockData() {
        guard isTracking else { return }
        
        heartRate = Double.random(in: 120...160)
        cadence = Double.random(in: 160...180)
        // Distance would be accumulated separately
    }
}
