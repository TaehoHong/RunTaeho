import SwiftUI
import UIKit

// MARK: - Unity Avatar View (SwiftUI)
struct UnityAvatarView: View {
    let equippedItems: [ItemType: AvatarItem]
    
    var body: some View {
        UnityAvatarRepresentable(equippedItems: equippedItems)
            .aspectRatio(1.0, contentMode: .fit)
            .background(Color.gray.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
            )
    }
}

// MARK: - Unity Avatar UIViewControllerRepresentable
struct UnityAvatarRepresentable: UIViewRepresentable {
    let equippedItems: [ItemType: AvatarItem]
    @ObservedObject private var unity = Unity.shared
    
    func makeUIView(context: Context) -> UIView {
        // Unity View를 직접 반환
        if let unityView = unity.view {
            return unityView
        } else {
            // Unity가 아직 시작되지 않았을 때 임시 뷰
            let placeholderView = UIView()
            placeholderView.backgroundColor = .systemGray6
            
            let label = UILabel()
            label.text = "Unity Loading..."
            label.textAlignment = .center
            label.font = .systemFont(ofSize: 16, weight: .medium)
            label.textColor = .systemGray
            label.translatesAutoresizingMaskIntoConstraints = false
            
            placeholderView.addSubview(label)
            NSLayoutConstraint.activate([
                label.centerXAnchor.constraint(equalTo: placeholderView.centerXAnchor),
                label.centerYAnchor.constraint(equalTo: placeholderView.centerYAnchor)
            ])
            
            return placeholderView
        }
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        // Unity가 로드되었고 착용 아이템이 변경될 때마다 Unity에 전달
        updateEquippedItems(equippedItems)
    }
    
    private func updateEquippedItems(_ items: [ItemType: AvatarItem]) {
        guard unity.view != nil else { return }
        
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
            UnityService.shared.changeAvatar(unityAvatarDtos)
        }
        
        // 콘솔 로그로 확인
        print("Updated avatar items: \(items.count) items")
        for (type, item) in items {
            print("  - \(type.rawValue): \(item.name)")
        }
    }
}

// MARK: - Unity Avatar Preview Extensions
extension UnityAvatarView {
    // 애니메이션 컨트롤을 위한 메서드들
    func playAnimation(_ animation: CharacterMotion) {
        // Unity에 애니메이션 명령 전달
        UnityService.shared.changeMotion(motion: animation)
    }
    
    func resetToIdle() {
        UnityService.shared.changeMotion(motion: .IDLE)
    }
}
