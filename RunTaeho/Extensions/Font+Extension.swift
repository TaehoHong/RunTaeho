//
//  Font+Extension.swift
//  RunTaeho
//
//  Created by Taeho Hong on 2024/03/24.
//

import SwiftUI

extension Font {
    static func bmjua(size: CGFloat) -> Font {
        .custom(CustomFont.bmJUA, size: size)
    }
}

struct CustomFont {
    static let bmJUA = "BMJUAOTF"
    
    static func stats(size: CGFloat = 25) -> Font {
        Font.custom(bmJUA, size: size)
    }
    
    static func distance(size: CGFloat = 60) -> Font {
        Font.custom(bmJUA, size: size)
    }
    
    static func custom(size: CGFloat) -> Font {
        Font.custom(bmJUA, size: size)
    }
}

extension View {
    func font(size: CGFloat) -> some View {
        self.font(.custom(CustomFont.bmJUA, size: size))
    }
}
