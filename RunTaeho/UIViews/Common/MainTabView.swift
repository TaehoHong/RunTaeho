import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 1
    @StateObject private var appState = AppState.shared
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // 컨텐츠 스위칭
            Group {
                switch selectedTab {
                case 0:
                    MyInfoView()
                case 1:
                    RunningView()
                case 2:
                    StatisticView()
                default:
                    RunningView()
                }
            }
            .ignoresSafeArea(.keyboard)
            .padding(.bottom, appState.viewState == .Loaded ? 60 : 0)

            if appState.runningState == .Stopped, appState.viewState == .Loaded {
                CustomTabBar(selectedTab: $selectedTab)
            }
        }
        .background(Color.white)
        .accentColor(.blue)
    }
}

struct CustomTabBar: View {
    
    @Binding var selectedTab: Int

    var body: some View {
        VStack (spacing: 10) {
                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(.black)
                        .opacity(0.2)

                    HStack {
                        Spacer()
                        Button(action: { selectedTab = 0 }) {
                            VStack {
                                Image(systemName: "person.fill")
                                Text("내정보")
                            }
                        }
                        Spacer()
                        Button(action: { selectedTab = 1 }) {
                            VStack {
                                Image(systemName: "figure.run")
                                Text("러닝")
                            }
                        }
                        Spacer()
                        Button(action: { selectedTab = 2 }) {
                            VStack {
                                Image(systemName: "chart.bar.fill")
                                Text("통계")
                            }
                        }
                        Spacer()
                    }
                }
                .ignoresSafeArea(edges: .bottom)    // 탭바가 안전영역까지 확장
    }
}

