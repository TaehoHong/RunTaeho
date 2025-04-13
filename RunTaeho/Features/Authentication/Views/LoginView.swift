import SwiftUI

struct LoginView: View {
    @State private var isShowingContentView = false

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 10) {

                Button(action: {
                    isShowingContentView = true
                }) {
                    Image("ios_neutral_sq_SI")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 240, height: 38)
                }

                Button(action: {
                    isShowingContentView = true
                }) {
                    Image("appleid_button")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 240, height: 38)
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height * 0.5)
            .position(x: geometry.size.width / 2, y: geometry.size.height * 0.75)
            .fullScreenCover(isPresented: $isShowingContentView) {
                RunningView()
            }
            .navigationTitle("로그인")
        }   
    }
}
