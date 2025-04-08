//
//  PauseButton.swift
//  RunTaeho
//
//  Created by Taeho Hong on 2024/03/24.
//

import SwiftUI

// 공통으로 사용되는 상수값들
private enum Constants {
    static let buttonSize: CGFloat = 75
    static let barWidth: CGFloat = 4
    static let barHeight: CGFloat = 25
    static let barSpacing: CGFloat = 9
    static let cornerRadius: CGFloat = 2
    static let blurRadius: CGFloat = 3
}

struct PauseButton: View {
    @State private var isPressed = false
    var action: () -> Void
    
    var body: some View {
        ZStack {
            // 검은 원형 배경
            Circle()
                .fill(Color(red: 16/255, green: 16/255, blue: 16/255)) // #101010
                .frame(width: Constants.buttonSize, height: Constants.buttonSize)
                .blur(radius: isPressed ? Constants.blurRadius : 0)
            
            // 두 개의 세로 막대
            HStack(spacing: Constants.barSpacing) {
                // 왼쪽 막대
                PauseBar()
                
                // 오른쪽 막대
                PauseBar()
            }
        }
        .frame(width: Constants.buttonSize + Constants.blurRadius * 2, 
               height: Constants.buttonSize + Constants.blurRadius * 2)
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    isPressed = true
                }
                .onEnded { _ in
                    isPressed = false
                    action()  // 버튼에서 손을 뗄 때 action 실행
                }
        )
    }
}

// 일시정지 막대를 별도의 뷰로 분리
private struct PauseBar: View {
    var body: some View {
        RoundedRectangle(cornerRadius: Constants.cornerRadius)
            .fill(Color(red: 217/255, green: 217/255, blue: 217/255)) // #D9D9D9
            .frame(width: Constants.barWidth, height: Constants.barHeight)
            .overlay(
                RoundedRectangle(cornerRadius: Constants.cornerRadius)
                    .stroke(Color.black, lineWidth: 1)
            )
    }
}