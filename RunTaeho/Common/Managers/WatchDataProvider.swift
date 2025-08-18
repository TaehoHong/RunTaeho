import Foundation
import WatchConnectivity
import HealthKit

// Apple Watch에서 데이터를 받을 때 사용할 프로토콜
protocol WatchDataProviderDelegate: AnyObject {
    func didReceiveHeartRateData(_ heartRate: Double)
    func didReceiveCadenceData(_ cadence: Double)
    func didReceiveDistanceData(_ distance: Double)
    func didReceiveActiveEnergyData(_ energy: Double)
    func didUpdateWatchConnectionStatus(_ isConnected: Bool)
}

class WatchDataProvider: NSObject {
    weak var delegate: WatchDataProviderDelegate?
    private var wcSession: WCSession?
    
    var isWatchConnected: Bool {
        return wcSession?.isReachable ?? false
    }
    
    override init() {
        super.init()
        setupWatchConnectivity()
    }
    
    private func setupWatchConnectivity() {
        if WCSession.isSupported() {
            wcSession = WCSession.default
            wcSession?.delegate = self
            wcSession?.activate()
        }
    }
    
    // MARK: - Watch Communication
    func startDataCollection() {
        guard let session = wcSession, session.isReachable else {
            print("Watch is not reachable")
            return
        }
        
        let message: [String: Any] = [
            "action": "startDataCollection",
            "types": ["heartRate", "cadence", "distance", "activeEnergy"]
        ]
        
        session.sendMessage(message, replyHandler: { response in
            print("Watch responded: \(response)")
        }) { error in
            print("Failed to send start message to watch: \(error.localizedDescription)")
        }
    }
    
    func pauseDataCollection() {
        guard let session = wcSession, session.isReachable else { return }
        
        let message: [String: Any] = ["action": "pause"]
        
        session.sendMessage(message, replyHandler: nil) { error in
            print("Failed to send pause message to watch: \(error.localizedDescription)")
        }
    }
    
    func resumeDataCollection() {
        guard let session = wcSession, session.isReachable else { return }
        
        let message: [String: Any] = ["action": "resume"]
        
        session.sendMessage(message, replyHandler: nil) { error in
            print("Failed to send resume message to watch: \(error.localizedDescription)")
        }
    }
    
    func stopDataCollection() {
        guard let session = wcSession, session.isReachable else { return }
        
        let message: [String: Any] = ["action": "stop"]
        
        session.sendMessage(message, replyHandler: nil) { error in
            print("Failed to send stop message to watch: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Request Current Data
    func requestCurrentHeartRate() {
        guard let session = wcSession, session.isReachable else { return }
        
        let message: [String: Any] = ["request": "currentHeartRate"]
        
        session.sendMessage(message, replyHandler: { response in
            if let heartRate = response["heartRate"] as? Double {
                DispatchQueue.main.async {
                    self.delegate?.didReceiveHeartRateData(heartRate)
                }
            }
        }) { error in
            print("Failed to request heart rate: \(error.localizedDescription)")
        }
    }
    
    func requestCurrentCadence() {
        guard let session = wcSession, session.isReachable else { return }
        
        let message: [String: Any] = ["request": "currentCadence"]
        
        session.sendMessage(message, replyHandler: { response in
            if let cadence = response["cadence"] as? Double {
                DispatchQueue.main.async {
                    self.delegate?.didReceiveCadenceData(cadence)
                }
            }
        }) { error in
            print("Failed to request cadence: \(error.localizedDescription)")
        }
    }
}

// MARK: - WCSessionDelegate
extension WatchDataProvider: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        DispatchQueue.main.async {
            let isConnected = (activationState == .activated && session.isWatchAppInstalled && session.isReachable)
            self.delegate?.didUpdateWatchConnectionStatus(isConnected)
            
            if let error = error {
                print("WCSession activation failed: \(error.localizedDescription)")
            } else {
                print("WCSession activated with state: \(activationState)")
                print("Watch app installed: \(session.isWatchAppInstalled)")
                print("Watch reachable: \(session.isReachable)")
            }
        }
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        DispatchQueue.main.async {
            self.delegate?.didUpdateWatchConnectionStatus(false)
            print("WCSession became inactive")
        }
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        DispatchQueue.main.async {
            self.delegate?.didUpdateWatchConnectionStatus(false)
            print("WCSession deactivated")
        }
        
        // Reactivate the session
        session.activate()
    }
    
    func sessionReachabilityDidChange(_ session: WCSession) {
        DispatchQueue.main.async {
            let isConnected = session.isReachable && session.isWatchAppInstalled
            self.delegate?.didUpdateWatchConnectionStatus(isConnected)
            print("Watch reachability changed: \(session.isReachable)")
        }
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        DispatchQueue.main.async {
            // Handle incoming data from watch
            if let heartRate = message["heartRate"] as? Double {
                self.delegate?.didReceiveHeartRateData(heartRate)
            }
            
            if let cadence = message["cadence"] as? Double {
                self.delegate?.didReceiveCadenceData(cadence)
            }
            
            if let distance = message["distance"] as? Double {
                self.delegate?.didReceiveDistanceData(distance)
            }
            
            if let energy = message["activeEnergy"] as? Double {
                self.delegate?.didReceiveActiveEnergyData(energy)
            }
            
            // Handle status messages
            if let status = message["status"] as? String {
                print("Watch status: \(status)")
            }
        }
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        DispatchQueue.main.async {
            // Handle messages that expect a reply
            if let request = message["request"] as? String {
                switch request {
                case "appStatus":
                    replyHandler(["status": "active", "timestamp": Date().timeIntervalSince1970])
                case "workoutStatus":
                    // Send current workout status if needed
                    replyHandler(["workoutActive": true]) // or false based on current state
                default:
                    replyHandler(["error": "Unknown request"])
                }
            } else {
                replyHandler(["received": true])
            }
        }
    }
}