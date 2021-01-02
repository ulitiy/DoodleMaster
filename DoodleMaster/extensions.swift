//
//  extensions.swift
//  DoodleMaster
//
//  Created by Aleksandr Ulitin on 22.12.2020.
//  Copyright © 2020 Aleksandr Ulitin. All rights reserved.
//
import SwiftUI

extension Double {
    func toString(_ d: Int = 1) -> String {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = d
        return formatter.string(from: NSNumber(value: self))!
    }
    
    func formatPercent(_ d: Int = 1) -> String {
        (self * 100).toString(d)
    }
}

extension Color {
    public init?(hex: String) {
        let r, g, b, a: Double
        let scanner = Scanner(string: hex)
        var hexNumber: UInt64 = 0

        scanner.scanHexInt64(&hexNumber)
        r = Double((hexNumber & 0xff000000) >> 24) / 255
        g = Double((hexNumber & 0x00ff0000) >> 16) / 255
        b = Double((hexNumber & 0x0000ff00) >> 8) / 255
        a = Double(hexNumber & 0x000000ff) / 255

        self.init(.sRGB, red: r, green: g, blue: b, opacity: a)
    }
}
