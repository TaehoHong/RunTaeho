import SwiftUI
import SDWebImageSwiftUI

struct LoadingView: View {
    @State private var progressRate = 0.0
    let duration: Double = 2.0  // 2초 설정
    
    var body: some View {
        AnimatedImage(name:"https://i0.wp.com/www.dogwonder.co.uk/wp-content/uploads/2009/12/tumblr_ku2pvuJkJG1qz9qooo1_r1_400.gif?resize=320%2C320")
//            .indicator(Indicator.progress(style: ProgressViewStyle.linear))
//            .transition(AnyTransition.flipFromLeft)
        
//        VStack {
            
//            AnimatedImage(name: "Resource/Loading/Loading.gif")
//                .indicator(Indicator.progress)
//                .transition(AnyTransition.flipFromLeft)
//                .resizable()
//                .frame(width: 200, height: 200)
            
//            Text("로딩중...")
//                .font(CustomFont.custom(size: 20))
            
//            ProgressView(value: progressRate, total: 100)
//                .progressViewStyle(LinearProgressViewStyle())
//                .padding()
//            Text("\(Int(progressRate))%")
//                .font(CustomFont.custom(size: 20))
//        }
//        .onAppear {
//            withAnimation(.linear(duration: duration)) {
//                progressRate = 100.0
//            }
    }
}

// MARK: - Preview
struct LoadingView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // 라이트 모드
            LoadingView()
                .previewDisplayName("Light Mode")
            
//            // 다크 모드
//            LoadingView()
//                .preferredColorScheme(.dark)
//                .previewDisplayName("Dark Mode")
//            
//            // 다양한 기기에서 미리보기
//            LoadingView()
//                .previewDevice("iPhone 15 Pro")
//                .previewDisplayName("iPhone 15 Pro")
//            
//            LoadingView()
//                .previewDevice("iPhone SE (3rd generation)")
//                .previewDisplayName("iPhone SE")
        }
    }
}
