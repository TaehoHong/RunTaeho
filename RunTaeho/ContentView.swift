import SwiftUI

struct ContentView: View {
    @State private var loading = false
    @State private var showState = false
    @State private var showLayout = false
    @State private var alignment = Alignment.top
    
    @State private var runningStatus: eRunningStatus = .Stopped
    
    @ObservedObject private var unity = Unity.shared
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            if loading {
                // Unity is starting up or shutting down
                ProgressView("Loading...")
                    .tint(.white)
                    .foregroundStyle(.white)
            } else if let unityContainer = unity.view.flatMap({ UIViewContainer(containee: $0) }) {
                GeometryReader { geometry in
                    let width = geometry.size.width
                    let height = geometry.size.height
                    
                    // UnityContainer occupies the top half of the screen
                    unityContainer
                        .ignoresSafeArea()
                        .frame(width: width, height: height * 0.5, alignment: .top)
                    
                    VelocityDevButtonView()
                    
                    VStack(spacing: 10) {
                        Spacer()
                        
                        // Control panel placed below UnityContainer
                        if runningStatus == .Stopped {
                            VStack(spacing: 20) {
                                StartButton {
                                    runningStatus = .Running
                                }
                            }
                        } else {
                            VStack(spacing: 25) {
                                // Top stats (BPM, Pace, Time) with centered Distance
                                StatsView()
                                
                                if runningStatus == .Running {
                                    PauseButton {
                                        runningStatus = .Paused
                                    }
                                    .padding(.bottom, 0)
                                } else if runningStatus == .Paused {
                                    HStack(spacing: 40) {
                                        Spacer()
                                        StopButton { runningStatus = .Stopped }
                                        Spacer()
                                        PlayButton { runningStatus = .Running }
                                        Spacer()
                                    }
                                }
                            }
                            .frame(width: width, height: height * 0.5)
                            .position(x: width / 2, y: height * 0.75)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            } else {
                VStack {
                    Text("Starting Unity...")
                    ProgressView()
                        .onAppear {
                            loading = true
                            DispatchQueue.main.async {
                                unity.start()
                                loading = false
                            }
                        }
                }
            }
        }
        .background(Color.white)
        .safeAreaPadding()
        .pickerStyle(.segmented)
    }
}

/* Make alignment hashable so it can be used as a
   picker selection. We only care about top, center,
   and bottom. Retroactive conformance is a bad practice
   but is much more laconic than writing out a wrapper type. */
extension Alignment: @retroactive Hashable {
    public func hash(into hasher: inout Hasher) {
        switch self {
        case .top: hasher.combine(0)
        case .center: hasher.combine(1)
        case .bottom: hasher.combine(2)
        default: hasher.combine(3)
        }
    }
}
