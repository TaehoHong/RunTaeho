//
//  RunningDebugView.swift
//  RunTaeho
//
//  Created by Hong Taeho on 8/5/25.
//

import Foundation
import SwiftUI


struct DebugView: View {
    
    @ObservedObject var viewModel: RunningViewModel

    var body: some View {
        HStack(alignment: .top) {

            VelocityDevButtonView(viewModel: viewModel)
            
            Spacer()

    // 디버깅 정보 영역
            #if DEBUG
            VStack(alignment: .leading, spacing: 10) {
                Text("🔍 디버그 정보")
                    .font(.headline)
                
                debugRunningStatus(viewModel: viewModel)
                debugLocationStatus(viewModel: viewModel)
                debugGPSAccuracy(viewModel: viewModel)
                debugDistanceInfo(viewModel: viewModel)
//                debugLastLocationUpdate(viewModel: viewModel)
                
                Button(action: {
                    viewModel.printDebugStatus()
                }) {
                    Text("전체 디버그 정보 출력")
                        .font(.caption)
                        .padding(8)
                        .background(Color.blue.opacity(0.2))
                        .cornerRadius(8)
                }
            }
            .padding()
            .background(Color.white.opacity(0.7))
            .cornerRadius(12)
            .padding()
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
            )
            #endif
        }
    }
}

// DEBUG 모드에서만 뷰를 표시하기 위한 View extension
extension View {
    @ViewBuilder func visibleInDebug() -> some View {
        #if DEBUG
        self
        #else
        EmptyView()
        #endif
    }
}

// 디버깅 정보 컴포넌트
private func debugRunningStatus(viewModel: RunningViewModel) -> some View {
    HStack {
        Text("러닝 상태:")
        Text("\(viewModel.appState.runningState)")
            .foregroundColor(.blue)
    }
    .font(.subheadline)
}

private func debugLocationStatus(viewModel: RunningViewModel) -> some View {
    HStack {
        Text("위치 권한:")
        Text(viewModel.locationAuthStatus)
            .foregroundColor(viewModel.locationAuthStatus.contains("허용") ? .green : .red)
    }
    .font(.subheadline)
}

private func debugGPSAccuracy(viewModel: RunningViewModel) -> some View {
    HStack {
        Text("GPS 정확도:")
        Text(String(format: "%.1fm", viewModel.locationAccuracy))
            .foregroundColor(viewModel.locationAccuracy < 20 ? .green : .orange)
    }
    .font(.subheadline)
}

private func debugDistanceInfo(viewModel: RunningViewModel) -> some View {
    VStack(alignment: .leading, spacing: 5) {
        Text("거리 정보:")
        Text("총 거리: \(String(format: "%.2fm", viewModel.distanceMeter))")
        Text("현재 페이스: \(viewModel.statsManager.pace.minutes)'\(String(format: "%02d", viewModel.statsManager.pace.seconds))\"")
    }
    .padding(.leading)
    .font(.subheadline)
}

//private func debugLastLocationUpdate(viewModel: RunningViewModel) -> some View {
//    VStack(alignment: .leading, spacing: 5) {
//        Text("마지막 위치 업데이트:")
//        Text(viewModel.locationManager.lastLocationUpdate)
//            .font(.caption)
//            .foregroundColor(.gray)
//    }
//    .font(.subheadline)
//}
