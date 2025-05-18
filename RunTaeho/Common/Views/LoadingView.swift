import SwiftUI
import WebKit

struct GifImage: UIViewRepresentable {
    let gifName: String
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.isOpaque = false
        webView.backgroundColor = UIColor.clear
        webView.scrollView.isScrollEnabled = false
        
        if let url = Bundle.main.url(forResource: gifName, withExtension: "gif",
                                      subdirectory: "Resource/Loading") {
            let data = try! Data(contentsOf: url)
            webView.load(data, 
                        mimeType: "image/gif", 
                        characterEncodingName: "UTF-8", 
                        baseURL: url.deletingLastPathComponent())
        }
        
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        // 업데이트 로직이 필요하다면 여기에 추가
    }
}

struct LoadingView: View {
    @State private var progressRate = 0.0
    let duration: Double = 2.0  // 2초 설정
    
    var body: some View {
        VStack {
            Text("로딩중...")
            
            // GIF 이미지 추가
            GifImage(gifName: "Loading")
                .frame(width: 100, height: 100)
                .padding()
            
            ProgressView(value: progressRate, total: 100)
                .progressViewStyle(LinearProgressViewStyle())
                .padding()
            Text("\(Int(progressRate))%")
        }
        .onAppear {
            withAnimation(.linear(duration: duration)) {
                progressRate = 100.0
            }
        }
    }
}