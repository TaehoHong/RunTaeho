//
//  ScrollOffsetPreferenceKey.swift
//  RunTaeho
//
//  Created by Hong Taeho on 6/27/25.
//

import SwiftUI

struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}
