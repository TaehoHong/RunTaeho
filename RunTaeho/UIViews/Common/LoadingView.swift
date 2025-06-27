import SwiftUI
import UIKit
import ImageIO

struct GifImage: UIViewRepresentable {
    let gifName: String
    
    func makeUIView(context: Context) -> UIImageView {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        
        if let url = Bundle.main.url(forResource: gifName, withExtension: "gif",
                                      subdirectory: "Resource/Loading"),
           let data = try? Data(contentsOf: url) {
            imageView.image = UIImage.gif(data: data)
        }
        
        return imageView
    }
    
    func updateUIView(_ uiView: UIImageView, context: Context) {
        // 업데이트 로직이 필요하다면 여기에 추가
    }
}

// UIImage Extension for GIF support
extension UIImage {
    static func gif(data: Data) -> UIImage? {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil) else {
            return nil
        }
        
        let count = CGImageSourceGetCount(source)
        var images = [UIImage]()
        var duration = 0.0
        
        for i in 0..<count {
            guard let cgImage = CGImageSourceCreateImageAtIndex(source, i, nil) else {
                continue
            }
            
            let frameDuration = UIImage.frameDuration(at: i, source: source)
            duration += frameDuration
            
            let image = UIImage(cgImage: cgImage)
            images.append(image)
        }
        
        guard duration > 0 else { return nil }
        
        return UIImage.animatedImage(with: images, duration: duration)
    }
    
    static func frameDuration(at index: Int, source: CGImageSource) -> Double {
        var frameDuration = 0.1
        
        guard let properties = CGImageSourceCopyPropertiesAtIndex(source, index, nil) as? [CFString: Any],
              let gifProperties = properties[kCGImagePropertyGIFDictionary] as? [CFString: Any] else {
            return frameDuration
        }
        
        if let unclampedDelayTime = gifProperties[kCGImagePropertyGIFUnclampedDelayTime] as? Double {
            frameDuration = unclampedDelayTime
        } else if let delayTime = gifProperties[kCGImagePropertyGIFDelayTime] as? Double {
            frameDuration = delayTime
        }
        
        // 최소 프레임 시간 설정 (너무 빠른 애니메이션 방지)
        if frameDuration < 0.011 {
            frameDuration = 0.1
        }
        
        return frameDuration
    }
}

struct LoadingView: View {
    @State private var progressRate = 0.0
    let duration: Double = 2.0  // 2초 설정
    
    var body: some View {
        VStack {
            Text("로딩중...")
                .font(CustomFont.custom(size: 20))
            
            // GIF 이미지 추가
//            GifImage(gifName: "Loading")
//                .frame(width: 100, height: 100)
//                .padding()
            
            ProgressView(value: progressRate, total: 100)
                .progressViewStyle(LinearProgressViewStyle())
                .padding()
            Text("\(Int(progressRate))%")
                .font(CustomFont.custom(size: 20))
        }
        .onAppear {
            withAnimation(.linear(duration: duration)) {
                progressRate = 100.0
            }
        }
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
