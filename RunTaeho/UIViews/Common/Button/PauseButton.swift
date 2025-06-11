//
//  PauseButton.swift
//  RunTaeho
//
//  Created by Taeho Hong on 2024/03/24.
//

import SwiftUI

// 버튼 관련 상수값들을 논리적으로 그룹화
private enum Constants {
    enum Button {
        static let size: CGFloat = 75
        static let blurRadius: CGFloat = 3
    }
    
    enum Bar {
        static let width: CGFloat = 4
        static let height: CGFloat = 25
        static let spacing: CGFloat = 9
        static let cornerRadius: CGFloat = 2
    }
    
    static var buttonFrame: CGRect {
        let size = Button.size + Button.blurRadius * 2
        return CGRect(x: 0, y: 0, width: size, height: size)
    }
}

struct PauseButton: View {
    @State private var isPressed = false
    let action: () -> Void
    
    // MARK: - Body
    var body: some View {
        buttonContent
            .frame(width: Constants.buttonFrame.width, height: Constants.buttonFrame.height)
            .gesture(buttonGesture)
    }
    
    // MARK: - Private Views
    private var buttonContent: some View {
        ZStack {
            backgroundCircle
            pauseBars
        }
    }
    
    private var backgroundCircle: some View {
        Circle()
            .fill(Color(red: 16/255, green: 16/255, blue: 16/255)) // #101010
            .frame(width: Constants.Button.size, height: Constants.Button.size)
            .blur(radius: isPressed ? Constants.Button.blurRadius : 0)
    }
    
    private var pauseBars: some View {
        HStack(spacing: Constants.Bar.spacing) {
            PauseBar()
            PauseBar()
        }
    }
    
    // MARK: - Gestures
    private var buttonGesture: some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { _ in
                isPressed = true
            }
            .onEnded { value in
                defer { isPressed = false }
                if Constants.buttonFrame.contains(value.location) {
                    action()
                }
            }
    }
}

// MARK: - Pause Bar Shape
private struct PauseBar: View {
    var body: some View {
        RoundedRectangle(cornerRadius: Constants.Bar.cornerRadius)
            .fill(Color(red: 217/255, green: 217/255, blue: 217/255)) // #D9D9D9
            .frame(width: Constants.Bar.width, height: Constants.Bar.height)
            .overlay(
                RoundedRectangle(cornerRadius: Constants.Bar.cornerRadius)
                    .stroke(Color.black, lineWidth: 1)
            )
    }
}