//
//  RunTaehoApp.swift
//  RunTaeho
//
//  Created by Benjamin Dewey on 12/24/23.
//

import SwiftUI

@main
struct RunTaehoApp: App {
    // MARK: - State Objects
    @StateObject private var userStateManager = UserStateManager.shared
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                Color.gray.ignoresSafeArea()
                
                // 로그인 상태에 따른 화면 분기
                if userStateManager.isLoggedIn {
                    MainTabView()
                } else {
                    LoginView()
                }
            }
            // MARK: - Environment Objects 주입
            .environmentObject(userStateManager)
            .task {
                // 앱 시작시 초기 설정 - 비동기로 처리
                await MainActor.run {
                    setupApp()
                }
            }
        }
    }
    
    private func setupApp() {
        #if DEBUG
        // 디버그 모드에서만 앱 상태 리셋 (필요한 경우)
        userStateManager.resetAppState()
        #endif
        
        // 앱 시작시 필요한 초기 설정
        print("앱 시작 횟수: \(userStateManager.appLaunchCount)")
        print("마지막 앱 버전: \(userStateManager.lastAppVersion ?? "없음")")
        
        // 사용자 로그인 상태 확인
        if userStateManager.isLoggedIn {
            print("사용자 로그인 상태: \(userStateManager.currentUser?.displayName ?? "알 수 없음")")
        }
    }
}
