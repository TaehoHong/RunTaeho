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
                                // Start 버튼
                                Button(action: {
                                    runningStatus = .Running
                                }) {
                                    Text("Start")
                                        .padding()
                                        .background(Color.blue.opacity(0.7))
                                        .clipShape(Circle())
                                        .foregroundColor(.white)
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
                            HStack(spacing: 104) {
                            
                                StopButtonView()
                                    .padding(.bottom, 0)
                                    .onTapGesture {
                                        runningStatus = .Stopped
                                    }

                                PlayButton()
                                .padding(.bottom, 0)
                                .onTapGesture {
                                    runningStatus = .Running
                                }
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


