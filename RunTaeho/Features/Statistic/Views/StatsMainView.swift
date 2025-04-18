import SwiftUI

struct StatsMainView: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("통계")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding()
                
                Spacer()
            }
            .navigationTitle("통계")
        }
    }
}

struct StatsMainView_Previews: PreviewProvider {
    static var previews: some View {
        StatsMainView()
    }
} 