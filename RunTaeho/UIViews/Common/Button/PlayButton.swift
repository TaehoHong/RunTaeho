//
//  PlayButton.swift
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
    
    enum Triangle {
        static let width: CGFloat = 20
        static let height: CGFloat = 22
        static let offset: CGFloat = 3
    }
    
    static var buttonFrame: CGRect {
        let size = Button.size + Button.blurRadius * 2
        return CGRect(x: 0, y: 0, width: size, height: size)
    }
}

struct PlayButton: View {
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
            playSymbol
        }
    }
    
    private var backgroundCircle: some View {
        Circle()
            .fill(Color(red: 59/255, green: 162/255, blue: 57/255)) // #3BA239
            .frame(width: Constants.Button.size, height: Constants.Button.size)
            .blur(radius: isPressed ? Constants.Button.blurRadius : 0)
    }
    
    private var playSymbol: some View {
        PlaySymbol()
            .fill(Color.white)
            .frame(width: Constants.Triangle.width, height: Constants.Triangle.height)
            .offset(x: Constants.Triangle.offset)
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

// MARK: - Play Symbol Shape
private struct PlaySymbol: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: 0, y: rect.height))
        path.addLine(to: CGPoint(x: rect.width, y: rect.height/2))
        path.closeSubpath()
        return path
    }
} 