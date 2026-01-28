//
//  Color+Extensions.swift
//  Guage
//
//  Created by Jonathan Corpuz on 2025-12-11.
//

import SwiftUI

extension Color {
    /// Primary dark shade used for text and icons on light backgrounds.
    ///
    /// - Note: Use this instead of '.black'
    /// - Note: Matches Hex #292929
    static let menuBlack = Color(red: 41/255, green: 41/255, blue: 41/255)
    
    /// Off-white background color used for cards and sheets
    ///
    /// - Note: Matches Hex #E5E5E5
    static let menuWhite = Color(red: 229/255, green: 229/255, blue: 229/255)
    
    static let menuGreenAccent = Color(red: 16/255, green: 181/255, blue: 118/255)
    
    static let menuRedAccent = Color(red: 217/255, green: 98/255, blue: 82/255)
}
