import SwiftUI

struct ProfileView: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("내정보")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding()
                
                Spacer()
            }
            .navigationTitle("프로필")
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
} 