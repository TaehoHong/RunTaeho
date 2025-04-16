class CharactorMoveMentService {

    static let shared = CharactorMoveMentService()
    
    private let UNITY_OBJECT_NAME = "Charactor"
    private let UNITY_METHOD_NAME = "SetSpeed"

    private let MAX_INPUT_SPEED = 17.0
    private let MIN_INPUT_SPEED = 7.0

    private let MIN_SPEED = 3.0
    private let MAX_SPEED = 7.0

    private init() { }

    func moveCharactor(speed: Double) {
        let adjustedSpeed: Double
        
        if speed >= MAX_INPUT_SPEED {
            adjustedSpeed = MIN_SPEED
        } else if speed <= MIN_INPUT_SPEED {
            adjustedSpeed = MAX_SPEED
        } else {
            adjustedSpeed = MIN_SPEED + Double(speed - MAX_SPEED) * 0.4
        }

        print("speed: \(speed)")
        print("adjustedSpeed: \(adjustedSpeed)")
        Unity.shared.sendMessage(UNITY_OBJECT_NAME, methodName: UNITY_METHOD_NAME, parameter: String(adjustedSpeed))
    }

    func stopCharactor() {
        Unity.shared.sendMessage(UNITY_OBJECT_NAME, methodName: UNITY_METHOD_NAME, parameter: "0")
    }
}