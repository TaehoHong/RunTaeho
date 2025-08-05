import SwiftUI

struct RunningView: View {
    @State private var showState = false
    @State private var showLayout = false
    @State private var alignment = Alignment.top
    
    @StateObject public var viewModel = RunningViewModel()
    @ObservedObject private var unity = Unity.shared
    @StateObject private var appState = AppState.shared
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            switch appState.viewState {
                case .Loading : 
                    LoadingView()
                        .onAppear {
                            DispatchQueue.main.async {
                                unity.start()
                                appState.setViewState(.Loaded)
                            }
                        }

                case .Loaded : 
                    let unityContainer = unity.view.flatMap({ UIViewContainer(containee: $0) })
                    let _ = UnityService.shared.changeAvatar(UserStateManager.shared.equippedItems)
                    GeometryReader { geometry in
                        let width = geometry.size.width
                        let height = geometry.size.height
                        
                        // UnityContainer occupies the top half of the screen
                        unityContainer
                            .ignoresSafeArea()
                            .frame(width: width, height: height * 0.5, alignment: .top)
                        
//                        DebugView(viewModel: viewModel)

                        VStack(spacing: 10) {
                            Spacer()
                            
                            // Control panel placed below UnityContainer
                            ControlPanelView(viewModel: viewModel, geometry: geometry)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
            }
        }
        .background(Color.white)
        .safeAreaPadding()
        .pickerStyle(.segmented)
        .alert("이전 러닝 데이터 복구", isPresented: $viewModel.showRecoveryAlert) {
            Button("취소") {
                viewModel.declineRecovery()
            }
            Button("복구") {
                viewModel.acceptRecovery()
            }
        } message: {
            if let data = viewModel.recoveryData {
                Text("마지막으로 저장된 러닝:\n거리: \(String(format: "%.2f", data.record.distance))m\n시간: \(Int(data.record.durationSec)/60)분 \(Int(data.record.durationSec)%60)초\n\n이 데이터를 복구하시겠습니까?")
            }
        }
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

struct ControlPanelView: View {
    @ObservedObject var viewModel: RunningViewModel
    let geometry: GeometryProxy
    
    var body: some View {
        switch viewModel.appState.runningState {
        case .Stopped:
            RunningStartView(viewModel: viewModel)
            
        case .Running:
            RunningActiveView(viewModel: viewModel, geometry: geometry)
            
        case .Paused:
            RunningPausedView(viewModel: viewModel, geometry: geometry)
            
        case .Finished:
            RunningFinishedView(viewModel: viewModel, geometry: geometry)
        }
    }
}

