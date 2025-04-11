import SwiftUI

struct LoginView: View {
    @State private var isShowingContentView = false

    var body: some View {
        VStack {
            Button(action: {
                isShowingContentView = true
            }) {
                Text("로그인")
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(8)
            }
        }
        .fullScreenCover(isPresented: $isShowingContentView) {
            ContentView()
        }
        .navigationTitle("로그인")
    }
}
