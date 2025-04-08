//
//  PlayButton.swift
//  RunTaeho
//
//  Created by Taeho Hong on 2024/03/24.
//

import SwiftUI

struct PlayButton: View {
    // 상수값들을 타입 프로퍼티로 정의
    private static let buttonSize: CGFloat = 75
    private static let triangleWidth: CGFloat = 20
    private static let triangleHeight: CGFloat = 22
    private static let triangleOffset: CGFloat = 3
    
    var body: some View {
        ZStack {
            // 초록색 원형 배경
            Circle()
                .fill(Color(red: 59/255, green: 162/255, blue: 57/255)) // #3BA239
                .frame(width: Self.buttonSize, height: Self.buttonSize)
            
            // 흰색 재생 삼각형
            PlaySymbol()
                .fill(Color.white)
                .frame(width: Self.triangleWidth, height: Self.triangleHeight)
                .offset(x: Self.triangleOffset) // 살짝 오른쪽으로 이동
        }
    }
}

// 재생 심볼을 별도의 Shape로 분리
struct PlaySymbol: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        // rect를 기준으로 삼각형 그리기
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: 0, y: rect.height))
        path.addLine(to: CGPoint(x: rect.width, y: rect.height/2))
        path.closeSubpath()
        
        return path
    }
} 