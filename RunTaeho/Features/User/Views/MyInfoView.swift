import SwiftUI

struct MyInfoView: View {
    @ObservedObject var viewModel = UserProfileViewModel()
    @EnvironmentObject var userStateManager: UserStateManager
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    
                    // 프로필 카드
                    ProfileCard()
                        .padding(.horizontal, 20)
                    
                    // 메인 메뉴
                    MainMenuCard()
                        .padding(.horizontal, 20)
                    
                    // 메뉴 설정 항목들
                    MenuSettingsCard()
                        .padding(.horizontal, 20)
                    
                    // 로그아웃 버튼
                    LogoutButton()
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                    
                    Spacer()
                }
            }
            .background(Color(hexCode: "fafafa"))
            .navigationTitle("내 정보")
            .navigationBarTitleDisplayMode(.inline)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

// 프로필 카드
struct ProfileCard: View {
    @EnvironmentObject var userStateManager: UserStateManager
    
    var body: some View {
        HStack(spacing: 15) {
            // 프로필 이미지
            Circle()
                .fill(Color(hexCode: "d9d9d9"))
                .frame(width: 83, height: 83)
                .overlay(
                    Circle()
                        .stroke(Color(hexCode: "4d99e5"), lineWidth: 2)
                )
            
            // 프로필 정보
            VStack(alignment: .leading, spacing: 8) {
                Text(userStateManager.currentUser?.displayName ?? "사용자")
                    .font(CustomFont.custom(size: 36))
                    .foregroundColor(.black)
                
                if let user = userStateManager.currentUser {
                    Text("러너 Lv.\(user.level) | 포인트: \(user.totalPoints)P")
                        .font(.system(size: 16))
                        .foregroundColor(Color(hexCode: "808080"))
                }
            }
            
            Spacer()
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(16)
    }
}

// 메인 메뉴 카드
struct MainMenuCard: View {
    @EnvironmentObject var userStateManager: UserStateManager
    @State private var showPointView = false
    @State private var showMyShoesView = false
    
    var body: some View {
        HStack(spacing: 0) {
            // 포인트 섹션
            Button(action: {
                showPointView = true
            }) {
                VStack(spacing: 5) {
                    Image("PointIcon")
                    Text("\(userStateManager.currentUser?.totalPoints ?? 0)")
                        .font(CustomFont.custom(size: 29))
                        .foregroundColor(.black)
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(PlainButtonStyle())
            
            // 구분선
            verticalDivider
            
            // 내 신발 섹션
            Button(action: {
                showMyShoesView = true
            }) {
                VStack(spacing: 8) {
                    Image("shose")
                        .foregroundColor(.black)
                    
                    Text("내 신발")
                        .font(CustomFont.custom(size: 29))
                        .foregroundColor(.black)
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(PlainButtonStyle())
            
            // 구분선
            verticalDivider
            
            // 아바타 섹션
            VStack(spacing: 8) {
                Image("avata_icon")
                    .foregroundColor(.black)
                
                Text("아바타")
                    .font(CustomFont.custom(size: 29))
                    .foregroundColor(.black)
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.vertical, 20)
        .padding(.horizontal, 15)
        .background(Color.white)
        .cornerRadius(16)
        .fullScreenCover(isPresented: $showPointView) {
            PointView()
        }
        .fullScreenCover(isPresented: $showMyShoesView) {
            MyShoesView()
        }
    }
}

var verticalDivider: some View {
    Rectangle()
        .fill(Color(hexCode: "e6e6e6"))
        .frame(width: 1)
        .padding(.vertical, 10)
}

// 메뉴 설정 카드
struct MenuSettingsCard: View {
    @State private var selectedMenuType: (any MenuDisplayable.Type)?
    
    var body: some View {
        VStack(spacing: 0) {
            ForEach(Array(MenuRegistry.enabledMenus.enumerated()), id: \.offset) { index, menuData in
                let (title, menuType) = menuData
                MenuSettingRow(title: title) {
                    selectedMenuType = menuType
                }
                
                // 구분선 (마지막 항목 제외)
                if index < MenuRegistry.enabledMenus.count - 1 {
                    Rectangle()
                        .fill(Color(hexCode: "f2f2f2"))
                        .frame(height: 1)
                        .padding(.horizontal, 20)
                }
            }
        }
        .background(Color.white)
        .cornerRadius(16)
        .fullScreenCover(item: Binding<MenuTypeWrapper?>(
            get: { selectedMenuType.map(MenuTypeWrapper.init) },
            set: { selectedMenuType = $0?.menuType }
        )) { wrapper in
            MenuViewBuilder.createView(for: wrapper.menuType)
        }
    }
}

// MARK: - MenuType Wrapper (Identifiable을 위해 필요)
struct MenuTypeWrapper: Identifiable {
    let id = UUID()
    let menuType: any MenuDisplayable.Type
}

// 메뉴 설정 행
struct MenuSettingRow: View {
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            menuRowContent
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var menuRowContent: some View {
        HStack(spacing: 15) {
            // 제목
            Text(title)
                .font(CustomFont.custom(size: 24))
                .foregroundColor(.black)
            
            Spacer()
            
            // 화살표
            Image(systemName: "chevron.right")
                .font(CustomFont.custom(size: 16))
                .foregroundColor(Color(hexCode: "666666"))
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 15)
    }
}

// MARK: - 로그아웃 버튼
struct LogoutButton: View {
    @EnvironmentObject var userStateManager: UserStateManager
    @State private var showLogoutAlert = false
    
    var body: some View {
        Button(action: {
            showLogoutAlert = true
        }) {
            HStack {
                Image(systemName: "rectangle.portrait.and.arrow.right")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.red)
                
                Text("로그아웃")
                    .font(CustomFont.custom(size: 24))
                    .foregroundColor(.red)
                
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 15)
        }
        .background(Color.white)
        .cornerRadius(16)
        .alert("로그아웃", isPresented: $showLogoutAlert) {
            Button("취소", role: .cancel) { }
            Button("로그아웃", role: .destructive) {
                userStateManager.logout()
            }
        } message: {
            Text("정말로 로그아웃하시겠습니까?")
        }
    }
}
