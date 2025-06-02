import SwiftUI

// MARK: - 메뉴 표시 가능한 뷰 프로토콜
protocol MenuDisplayable: View {
    static var menuTitle: String { get }
    static var menuOrder: Int { get }
    static var isEnabled: Bool { get }
}

// MARK: - 기본값 제공
extension MenuDisplayable {
    static var isEnabled: Bool { true }
    static var menuOrder: Int { 0 }
}

// MARK: - 메뉴 레지스트리
struct MenuRegistry {
    static let registeredMenus: [any MenuDisplayable.Type] = [
        UserAccountConnectionView.self,
        TermsOfServiceView.self,
        NoticeView.self
    ]
    
    static var enabledMenus: [(String, any MenuDisplayable.Type)] {
        return registeredMenus
            .filter { $0.isEnabled }
            .sorted { $0.menuOrder < $1.menuOrder }
            .map { ($0.menuTitle, $0) }
    }
}

// MARK: - 메뉴 뷰 빌더
struct MenuViewBuilder {
    @ViewBuilder
    static func createView(for menuType: any MenuDisplayable.Type) -> some View {
        if menuType == UserAccountConnectionView.self {
            UserAccountConnectionView()
        } else if menuType == TermsOfServiceView.self {
            TermsOfServiceView()
        } else if menuType == NoticeView.self {
            NoticeView()
        } else {
            EmptyView()
        }
    }
}
