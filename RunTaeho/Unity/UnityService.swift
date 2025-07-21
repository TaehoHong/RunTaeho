import Foundation


class UnityService {

    static let shared = UnityService()
    
    private let UNITY_OBJECT_NAME = "Charactor"
    private let UNITY_METHOD_NAME = "SetTrigger"

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
        Unity.shared.sendMessage(UNITY_OBJECT_NAME, methodName: "SetSpeed", parameter: String(adjustedSpeed))
    }

    func stopCharactor() {
        Unity.shared.sendMessage(UNITY_OBJECT_NAME, methodName: "SetSpeed", parameter: "0")
    }
    
    func changeMotion(motion: CharacterMotion) {
        Unity.shared.sendMessage(UNITY_OBJECT_NAME, methodName: "SetTrigger", parameter: motion.value)
    }
    
    func changeAvatar(_ items: [ItemType: AvatarItem]) {
        
        // Unity로 착용 아이템 정보 전달
        var unityAvatarDtos: [UnityAvatarDto] = []
        
        for (itemType, avatarItem) in items {
            let dto = UnityAvatarDto(
                name: avatarItem.name,
                part: itemType.unityName,
                itemPath: avatarItem.unityFilePath + avatarItem.name
            )
            unityAvatarDtos.append(dto)
        }
        
        // Unity Service를 통해 아바타 변경
        if(!unityAvatarDtos.isEmpty) {
            do {
                // Unity에서 기대하는 구조로 래핑
                let wrappedData = UnityAvatarDtoList(list: unityAvatarDtos)
                let encoder = JSONEncoder()
                let jsonData = try encoder.encode(wrappedData)
                if let jsonString = String(data: jsonData, encoding: .utf8) {
                    print("SetSprites JSON: \(jsonString)")
                    Unity.shared.sendMessage(UNITY_OBJECT_NAME, methodName: "SetSprites", parameter: jsonString)
                } else {
                    print("JSON 문자열 변환 실패")
                }
            } catch {
                print("Avatar JSON 인코딩 에러: \(error)")
            }
        }
    }
}

enum CharacterMotion {
    case IDLE
    case MOVE
    case ATTACK
    case DAMAGED
    
    var value: String {
        String(describing: self)
    }
}
