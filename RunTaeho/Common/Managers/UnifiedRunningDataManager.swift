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
    
    // Performance optimization: Track if metrics actually changed
    private var lastPublishedMetrics: RunningMetrics = .zero
    private var metricsUpdateThreshold: TimeInterval = 0.5 // Minimum time between UI updates
    private var lastUIUpdateTime: Date = Date()
    
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
    private var updateTimer: Timer?
    private let updateQueue = DispatchQueue(label: "com.runtaeho.unified.update", qos: .userInitiated)
    
    // MARK: - Configuration
    private let updateInterval: TimeInterval = 1.0 // seconds
    private let userWeight: Double = 70.0 // kg - should come from user settings
    
    // Performance thresholds
    private let minimumDistanceChange: Double = 0.5 // meters
    private let minimumHeartRateChange: Int = 2 // BPM
    private let minimumCadenceChange: Int = 5 // SPM
    
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
        updateTimer?.invalidate()
        updateTimer = nil
        cancellables.removeAll()
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
        
        // Stop timer during pause to save resources
        stopMetricsUpdateTimer()
        
        // Pause data collection but keep sources active
        healthDataSource.pauseTracking()
        watchDataSource.pauseTracking()
        phoneDataSource.pauseTracking()
        mockDataSource.pauseTracking()
        
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
        mockDataSource.resumeTracking()
        
        lastUpdateTime = Date()
        
        // Restart timer after resume
        startMetricsUpdateTimer()
        
        print("▶️ Unified tracking resumed")
        return .success(())
    }
    
    func stopTracking() {
        guard isTrackingActive else { return }
        
        isTrackingActive = false
        
        // Stop timer first to prevent further updates
        stopMetricsUpdateTimer()
        
        healthDataSource.stopTracking()
        watchDataSource.stopTracking()
        phoneDataSource.stopTracking()
        mockDataSource.stopTracking()
        
        activeDataSources.removeAll()
        
        print("🛑 Unified tracking stopped")
    }
    
    // MARK: - Data Source Management
    private func setupDataSourceObservers() {
        // Timer will be created when tracking starts
        // This prevents timer from running when not needed
    }
    
    private func updateActiveDataSources() {
        activeDataSources = Set(allDataSources.compactMap { source in
            source.isAvailable ? source.sourceType : nil
        })
    }
    
    private func startMetricsUpdateTimer() {
        // Cancel any existing timer
        updateTimer?.invalidate()
        
        // Create new timer with weak self to prevent retain cycle
        updateTimer = Timer.scheduledTimer(withTimeInterval: updateInterval, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            self.updateQueue.async { [weak self] in
                guard let self = self, self.isTrackingActive else { return }
                self.updateMetrics()
            }
        }
        
        // Ensure timer runs in common modes for background operation
        if let timer = updateTimer {
            RunLoop.current.add(timer, forMode: .common)
        }
    }
    
    private func stopMetricsUpdateTimer() {
        updateTimer?.invalidate()
        updateTimer = nil
    }
    
    // MARK: - Metrics Calculation
    private func updateMetrics() {
        // Only update active data sources if needed (every 5 seconds)
        if Date().timeIntervalSince(lastUpdateTime) > 5.0 {
            updateActiveDataSources()
        }
        
        let heartRate = getBestDataForHeartRate()
        let cadence = getBestDataForCadence()
        let distance = getBestDataForDistance()
        
        // Check if values changed significantly
        let heartRateChanged = abs(heartRate - currentMetrics.heartRate) >= minimumHeartRateChange
        let cadenceChanged = abs(cadence - currentMetrics.cadence) >= minimumCadenceChange
        
        // Update total distance only if change is significant
        let distanceDelta = distance - currentMetrics.distance
        if distanceDelta > minimumDistanceChange {
            totalDistance += distanceDelta
        }
        
        // Skip calculation if no significant changes
        if !heartRateChanged && !cadenceChanged && distanceDelta < minimumDistanceChange {
            return
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
        
        // Only update UI if metrics changed significantly or enough time passed
        let shouldUpdateUI = newMetrics != lastPublishedMetrics ||
                           Date().timeIntervalSince(lastUIUpdateTime) >= metricsUpdateThreshold
        
        if shouldUpdateUI {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.currentMetrics = newMetrics
                self.lastPublishedMetrics = newMetrics
                self.lastUIUpdateTime = Date()
            }
        }
        
        lastUpdateTime = Date()
    }
    
    // MARK: - Data Source Selection Logic
    // Cache for data source availability to reduce repeated checks
    private var sourceAvailabilityCache: [DataSourceType: Bool] = [:]
    private var cacheUpdateTime: Date = Date()
    private let cacheValidityDuration: TimeInterval = 2.0
    
    private func updateSourceAvailabilityCache() {
        guard Date().timeIntervalSince(cacheUpdateTime) > cacheValidityDuration else { return }
        
        sourceAvailabilityCache.removeAll()
        for source in allDataSources {
            sourceAvailabilityCache[source.sourceType] = source.isAvailable
        }
        cacheUpdateTime = Date()
    }
    
    private func getBestDataForHeartRate() -> Int {
        updateSourceAvailabilityCache()
        
        for sourceType in DataSourcePriority.heartRate {
            // Use cached availability check
            guard sourceAvailabilityCache[sourceType] == true,
                  let source = getDataSource(for: sourceType) else { continue }
            
            let value = source.heartRate
            if value > 0 {
                return Int(value)
            }
        }
        return currentMetrics.heartRate // Return last known value instead of 0
    }
    
    private func getBestDataForCadence() -> Int {
        updateSourceAvailabilityCache()
        
        for sourceType in DataSourcePriority.cadence {
            guard sourceAvailabilityCache[sourceType] == true,
                  let source = getDataSource(for: sourceType) else { continue }
            
            let value = source.cadence
            if value > 0 {
                return Int(value)
            }
        }
        return currentMetrics.cadence // Return last known value instead of 0
    }
    
    private func getBestDataForDistance() -> Double {
        updateSourceAvailabilityCache()
        
        for sourceType in DataSourcePriority.distance {
            guard sourceAvailabilityCache[sourceType] == true,
                  let source = getDataSource(for: sourceType) else { continue }
            
            let value = source.distance
            if value > 0 {
                return value
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
    
    // MARK: - Calculations (Optimized)
    // Cache for expensive calculations
    private var lastCalorieCalculationTime: TimeInterval = 0
    private var lastCalorieValue: Double = 0
    
    private func calculatePace(distance: Double, time: TimeInterval) -> RunningMetrics.PaceData {
        guard distance > 0 && time > 0 else {
            return currentMetrics.pace // Return last known pace instead of zero
        }
        
        let distanceInKm = distance / 1000.0
        guard distanceInKm > 0 else {
            return currentMetrics.pace
        }
        
        let paceSeconds = time / distanceInKm // seconds per kilometer
        
        // Validate pace is reasonable (between 3:00 and 15:00 per km)
        if paceSeconds < 180 || paceSeconds > 900 {
            return currentMetrics.pace // Return last known valid pace
        }
        
        return RunningMetrics.PaceData(totalSeconds: paceSeconds)
    }
    
    private func calculateSpeed(distance: Double, time: TimeInterval) -> Double {
        guard time > 0 && distance >= 0 else { return currentMetrics.speed }
        
        let speed = (distance / time) * 3.6 // m/s to km/h
        
        // Validate speed is reasonable (0-30 km/h for running)
        guard speed >= 0 && speed <= 30 else {
            return currentMetrics.speed // Return last known valid speed
        }
        
        return speed
    }
    
    private func calculateCalories(time: TimeInterval) -> Double {
        // Cache calories calculation (update every 10 seconds)
        if abs(time - lastCalorieCalculationTime) < 10 && lastCalorieValue > 0 {
            return lastCalorieValue
        }
        
        // Dynamic MET based on speed
        let speed = currentMetrics.speed
        let runningMET: Double
        
        switch speed {
        case 0..<6:
            runningMET = 6.0  // Slow jog
        case 6..<8:
            runningMET = 8.3  // Light running
        case 8..<10:
            runningMET = 9.8  // Moderate running
        case 10..<12:
            runningMET = 11.0 // Fast running
        default:
            runningMET = 12.5 // Very fast running
        }
        
        let hours = time / 3600.0
        let calories = runningMET * userWeight * hours
        
        // Update cache
        lastCalorieCalculationTime = time
        lastCalorieValue = calories
        
        return calories
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
    
    deinit {
        pedometer.stopUpdates()
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
    private var isPaused = false
    private var timer: Timer?
    
    deinit {
        stopTracking()
    }
    
    func startTracking() {
        isTracking = true
        isPaused = false
        stopTimer() // Clear any existing timer
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.generateMockData()
        }
    }
    
    func pauseTracking() {
        isPaused = true
        stopTimer() // Stop timer during pause to save resources
    }
    
    func resumeTracking() {
        guard isTracking else { return }
        isPaused = false
        
        // Restart timer
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.generateMockData()
        }
    }
    
    func stopTracking() {
        isTracking = false
        isPaused = false
        stopTimer()
        
        heartRate = 0.0
        cadence = 0.0
        distance = 0.0
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func generateMockData() {
        guard isTracking else { return }
        
        heartRate = Double.random(in: 120...160)
        cadence = Double.random(in: 160...180)
        // Distance would be accumulated separately
    }
}
