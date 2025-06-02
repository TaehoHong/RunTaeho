import SwiftUI

// MARK: - 이용 약관 화면
struct TermsOfServiceView: View, MenuDisplayable {
    // MARK: - MenuDisplayable 구현
    static var menuTitle: String { "이용 약관" }
    static var menuOrder: Int { 2 }
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack(spacing: 0) {
            // 헤더
            header
            
            // 메인 콘텐츠
            ScrollView {
                VStack(spacing: 20) {
                    Text("이용 약관 내용이 여기에 표시됩니다.")
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                        .padding()
                    
                    Spacer(minLength: 50)
                }
                .padding(.horizontal, 25)
                .padding(.top, 30)
            }
            .background(Color.white)
            
            Spacer()
        }
        .background(Color.white)
    }
    
    // MARK: - 헤더
    private var header: some View {
        ZStack {
            // 중앙 제목
            Text("이용 약관")
                .font(.system(size: 24, weight: .medium))
                .foregroundColor(.black)
            
            // 왼쪽 뒤로가기 버튼
            HStack {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.black)
                }
                
                Spacer()
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 15)
        .padding(.bottom, 10)
    }
}

// MARK: - 이용 약관 화면 프리뷰
struct TermsOfServiceView_Previews: PreviewProvider {
    static var previews: some View {
        TermsOfServiceView()
            .previewDevice("iPhone 14")
    }
}
