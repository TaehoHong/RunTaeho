import SwiftUI

struct MyInfoView: View {
    @ObservedObject var viewModel = UserProfileViewModel()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // 헤더 타이틀
    //                HStack {
    //                    Text("내 정보")
    //                        .font(CustomFont.custom(size: 28))
    //                        .foregroundColor(Color(hexCode: "333333"))
    //                    Spacer()
    //                }
    //                .padding(.horizontal, 20)
    //                .padding(.top, 20)
                    
                    // 프로필 카드
                    ProfileCard()
                        .padding(.horizontal, 20)
                    
                    // 메인 메뉴
                    MainMenuCard()
                        .padding(.horizontal, 20)
                    
                    // 메뉴 설정 항목들
                    MenuSettingsCard()
                        .padding(.horizontal, 20)
                    
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
                Text("달려라 태호군")
                    .font(CustomFont.custom(size: 36))
                    .foregroundColor(.black)
//                Text("러너 Lv.42 | 활동량 상위 5%")
//                    .font(.system(size: 16))
//                    .foregroundColor(Color(hex: "808080"))
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
    var body: some View {
        HStack(spacing: 0) {
            // 포인트 섹션
            NavigationLink(destination: PointView()) {
                VStack(spacing: 5) {
                    Image("PointIcon")
                    Text("10,000")
                        .font(CustomFont.custom(size: 29))
                        .foregroundColor(.black)
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(PlainButtonStyle())
            
            // 구분선
            Rectangle()
                .fill(Color(hexCode: "e6e6e6"))
                .frame(width: 1)
                .padding(.vertical, 10)
            
            // 내 신발 섹션
            VStack(spacing: 8) {
                Image("shose")
                    .foregroundColor(.black)
                
                Text("내 신발")
                    .font(CustomFont.custom(size: 29))
                    .foregroundColor(.black)
            }
            .frame(maxWidth: .infinity)
            
            // 구분선
            Rectangle()
                .fill(Color(hexCode: "e6e6e6"))
                .frame(width: 1)
                .padding(.vertical, 10)
            
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
    }
}

// 메뉴 설정 카드
struct MenuSettingsCard: View {
    let menuTitles = [
        "연결 계정 관리",
        "이용 약관",
        "공지사항"
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            ForEach(Array(menuTitles.enumerated()), id: \.offset) { index, item in
                MenuSettingRow(title: item)
                
                // 구분선 (마지막 항목 제외)
                if index < menuTitles.count - 1 {
                    Rectangle()
                        .fill(Color(hexCode: "f2f2f2"))
                        .frame(height: 1)
                        .padding(.horizontal, 20)
                }
            }
        }
        .background(Color.white)
        .cornerRadius(16)
    }
}

// 메뉴 설정 행
struct MenuSettingRow: View {
    let title: String
    
    var body: some View {
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

// Color Extension for Hex
extension Color {
    init(hexCode: String) {
        var hexFormatted: String = hexCode.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).uppercased()
                
        if hexFormatted.hasPrefix("#") {
            hexFormatted = String(hexFormatted.dropFirst())
        }
        
        assert(hexFormatted.count == 6, "Invalid hex code used.")
        
        var rgbValue: UInt64 = 0
        Scanner(string: hexFormatted).scanHexInt64(&rgbValue)
        
        self.init(red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
                  green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
                  blue: CGFloat(rgbValue & 0x0000FF) / 255.0
                  )
    }
}
