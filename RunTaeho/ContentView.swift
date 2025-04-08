//  ContentView.swift
//  UnitySwiftUI
//
//  Created by Benjamin Dewey on 12/24/23.
//

import SwiftUI

struct ContentView: View {
    @State private var loading = false
    @State private var showState = false
    @State private var showLayout = false
    @State private var alignment = Alignment.top
    
    @State private var runningStatus: eRunningStatus = .Stopped

    @ObservedObject private var unity = Unity.shared

    var body: some View {
        ZStack(alignment: .bottomLeading, content: {
            if loading {
                // Unity is starting up or shutting down
                ProgressView("Loading...").tint(.white).foregroundStyle(.white)
            } else if let UnityContainer = unity.view.flatMap({ UIViewContainer(containee: $0) }) {
                GeometryReader { geometry in
                    
                    UnityContainer
                        .ignoresSafeArea()
                        .frame(width: geometry.size.width, height: geometry.size.height * 0.5, alignment: .top)

                    VelocityDevButtonView()

                    VStack(spacing: 10) {
                        Spacer()
                        
                        // UnityContainer 바로 아래에 컨트롤 패널 배치
                        if runningStatus == .Stopped {
                            VStack(spacing: 20) {
                                StartButton {
                                    runningStatus = .Running
                                }
                            }
                        } else if runningStatus == .Running {
                            VStack {
                                PauseButton {
                                    runningStatus = .Paused
                                }
                                .padding(.bottom, 0)
                            }
                        } else if runningStatus == .Paused {
                            GeometryReader { geometry in
                                // StopButton - 전체 너비의 29.4% 지점에 위치
                                StopButton { 
                                    runningStatus = .Stopped
                                }
                                .padding(.bottom, 0)
                                .position(x: geometry.size.width * 0.294, y: geometry.size.height - 56)
                                
                                // PlayButton - 전체 너비의 70.8% 지점에 위치
                                PlayButton {
                                    runningStatus = .Running
                                }
                                .position(x: geometry.size.width * 0.708, y: geometry.size.height - 56)
                            }
                        }
                        
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            } else {
                // Unity is not running
                Text("Starting Unity...")
                ProgressView()
                    .onAppear {
                        /* Unity startup is slow and must must occur on the
                           main thread. Use async dispatch so we can re-render
                           with a ProgressView before the UI becomes unresponsive. */
                        loading = true
                        DispatchQueue.main.async(execute: {
                            unity.start()
                            loading = false
                        })
                    }
            }
        })
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


#Preview {
    ContentView()
}


