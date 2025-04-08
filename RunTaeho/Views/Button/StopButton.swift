import SwiftUI

struct StopButtonView: View {
    var body: some View {
        ZStack {
            // 바깥쪽 검은 원
            Circle()
                .fill(Color(red: 16/255, green: 16/255, blue: 16/255)) // #101010
                .frame(width: 75, height: 75)
            
            // 안쪽 흰색 사각형
            Rectangle()
                .fill(Color(red: 217/255, green: 217/255, blue: 217/255)) // #D9D9D9
                .frame(width: 21, height: 21)
        }
    }
}