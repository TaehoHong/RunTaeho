//
//  StartButton.swift
//  RunTaeho
//
//  Created by Taeho Hong on 2024/03/24.
//

import SwiftUI

struct StartButton: View {
    @State private var isPressed = false
    let action: () -> Void
    
    private enum Constants {
        enum Button {
            static let size: CGFloat = 125
            static let blurRadius: CGFloat = 3
            static let backgroundColor = Color(red: 4/255, green: 142/255, blue: 255/255) // #048EFF
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
            startText
        }
    }
    
    private var backgroundCircle: some View {
        Circle()
            .fill(Constants.Button.backgroundColor)
            .frame(width: Constants.Button.size, height: Constants.Button.size)
            .blur(radius: isPressed ? Constants.Button.blurRadius : 0)
    }
    
    private var startText: some View {
        Text("Start")
            .font(CustomFont.custom(size: 40))
            .foregroundColor(.white)
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
