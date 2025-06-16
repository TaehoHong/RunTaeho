import SwiftUI
import UIKit

// MARK: - Unity Avatar View
struct UnityAvatarView: UIViewControllerRepresentable {
    let equippedItems: [AvatarCategory: AvatarItem]
    
    func makeUIViewController(context: Context) -> UnityAvatarViewController {
        let controller = UnityAvatarViewController()
        controller.updateEquippedItems(equippedItems)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UnityAvatarViewController, context: Context) {
        // 착용 아이템이 변경될 때마다 Unity에 전달
        uiViewController.updateEquippedItems(equippedItems)
    }
}

// MARK: - Unity Avatar View Controller
class UnityAvatarViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUnityView()
    }
    
    private func setupUnityView() {
        // Unity View 초기화 로직
        // 실제 Unity 통합 시 구현 필요
        view.backgroundColor = .systemGray6
    }
    
    func updateEquippedItems(_ items: [AvatarCategory: AvatarItem]) {
        // Unity로 착용 아이템 정보 전달
        var itemData: [String: String] = [:]
        
        for (category, item) in items {
            itemData[category.rawValue] = item.id
        }
        
        // Unity 메시지 전송
        sendMessageToUnity(method: "UpdateAvatarItems", data: itemData)
    }
    
    private func sendMessageToUnity(method: String, data: [String: String]) {
        // Unity와의 통신 구현
        // 예: UnitySendMessage("AvatarManager", method, JSONString)
        print("Sending to Unity - Method: \(method), Data: \(data)")
    }
}

// MARK: - Unity Communication Protocol
protocol UnityAvatarCommunication {
    func updateAvatarItem(category: String, itemId: String)
    func updateAllAvatarItems(items: [String: String])
    func playAnimation(animationName: String)
    func resetAvatar()
}

// MARK: - Unity Message Handler
extension UnityAvatarViewController: UnityAvatarCommunication {
    func updateAvatarItem(category: String, itemId: String) {
        sendMessageToUnity(method: "UpdateSingleItem", data: ["category": category, "itemId": itemId])
    }
    
    func updateAllAvatarItems(items: [String: String]) {
        sendMessageToUnity(method: "UpdateAllItems", data: items)
    }
    
    func playAnimation(animationName: String) {
        sendMessageToUnity(method: "PlayAnimation", data: ["animation": animationName])
    }
    
    func resetAvatar() {
        sendMessageToUnity(method: "ResetAvatar", data: [:])
    }
}
