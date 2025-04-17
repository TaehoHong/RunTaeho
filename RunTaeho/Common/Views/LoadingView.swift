import SwiftUI

struct LoadingView: View {
    @State private var progressRate = 0.0
    let duration: Double = 2.0  // 2초 설정
    
    var body: some View {
        VStack {
            Text("로딩중...")
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