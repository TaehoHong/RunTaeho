//
//  StopButton.swift
//  RunTaeho
//
//  Created by Taeho Hong on 2024/03/24.
//

import SwiftUI

struct StopButton: View {
    @State private var isPressed = false
    @State private var pressStartTime: Date?
    @State private var scaleEffect: CGFloat = 1.0
    let action: () -> Void
    
    private enum Constants {
        enum Button {
            static let size: CGFloat = 75
            static let blurRadius: CGFloat = 3
            static let minPressDuration: TimeInterval = 2.0
            static let maxScaleEffect: CGFloat = 1.2
        }
        
        static var buttonFrame: CGRect {
            let size = Button.size + Button.blurRadius * 2
            return CGRect(x: 0, y: 0, width: size, height: size)
        }
    }
    
    var body: some View {
        buttonContent
            .frame(width: Constants.buttonFrame.width, height: Constants.buttonFrame.height)
            .gesture(buttonGesture)
    }
    
    // MARK: - Private Views
    private var buttonContent: some View {
        ZStack {
            backgroundCircle
            stopSymbol
        }
        .scaleEffect(scaleEffect)
        .animation(.easeInOut, value: scaleEffect)
    }
    
    private var backgroundCircle: some View {
        Circle()
            .fill(Color(red: 16/255, green: 16/255, blue: 16/255)) // #101010
            .frame(width: Constants.Button.size, height: Constants.Button.size)
    }
    
    private var stopSymbol: some View {
        RoundedRectangle(cornerRadius: 2)
            .fill(Color(red: 217/255, green: 217/255, blue: 217/255)) // #D9D9D9
            .frame(width: 25, height: 25)
            .overlay(
                RoundedRectangle(cornerRadius: 2)
                    .stroke(Color.black, lineWidth: 1)
            )
    }
    
    // MARK: - Gestures
    private var buttonGesture: some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { _ in
                if !isPressed {
                    isPressed = true
                    pressStartTime = Date()
                    
                    // 크기 증가 애니메이션 시작
                    withAnimation(.linear(duration: Constants.Button.minPressDuration)) {
                        scaleEffect = Constants.Button.maxScaleEffect
                    }
                    
                    // 2초 후에 action 실행
                    DispatchQueue.main.asyncAfter(deadline: .now() + Constants.Button.minPressDuration) {
                        if isPressed {
                            action()
                        }
                    }
                }
            }
            .onEnded { _ in
                isPressed = false
                pressStartTime = nil
                
                // 크기 원복
                withAnimation(.easeInOut(duration: 0.2)) {
                    scaleEffect = 1.0
                }
            }
    }
}


