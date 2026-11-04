//
//  LabTheme.swift
//  1 Ice Maker Lab
//
//  Created by Roman on 10/28/26.
//

import SwiftUI
import UIKit

enum LabTheme {
    enum Spacing {
        static let xs: CGFloat = 6
        static let sm: CGFloat = 10
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
    }

    enum Radius {
        static let sm: CGFloat = 12
        static let md: CGFloat = 18
        static let lg: CGFloat = 28
        static let pill: CGFloat = 999
    }

    enum Motion {
        static let quick: Animation = .spring(response: 0.35, dampingFraction: 0.78)
        static let soft: Animation = .spring(response: 0.55, dampingFraction: 0.82)
        static let float: Animation = .easeInOut(duration: 2.8).repeatForever(autoreverses: true)
        static let pulse: Animation = .easeInOut(duration: 1.4).repeatForever(autoreverses: true)
    }
}

enum LabColor {
    /// Primary brand blue — cool sky / arctic blue.
    static let glacier = Color(red: 0.18, green: 0.52, blue: 0.92)
    static let cyanIce = Color(red: 0.45, green: 0.78, blue: 1.00)
    static let deepTeal = Color(red: 0.06, green: 0.22, blue: 0.48)
    static let ink = Color(red: 0.05, green: 0.12, blue: 0.28)
    static let inkSoft = Color(red: 0.22, green: 0.34, blue: 0.52)
    static let mist = Color(red: 0.90, green: 0.95, blue: 1.00)
    static let frost = Color(red: 0.72, green: 0.86, blue: 0.98)
    static let amber = Color(red: 0.93, green: 0.66, blue: 0.22)
    static let coral = Color(red: 0.91, green: 0.40, blue: 0.38)
    static let cardFill = Color.white.opacity(0.74)
    static let stroke = Color.white.opacity(0.58)
}

enum LabFont {
    /// Display titles — Iceberg (fallback to rounded system if missing)
    static func display(_ size: CGFloat) -> Font {
        customOrSystem("Iceberg-Regular", size: size, weight: .bold, design: .rounded)
    }

    static func title(_ size: CGFloat = 22) -> Font {
        customOrSystem("Comfortaa-Bold", size: size, weight: .bold, design: .rounded)
    }

    static func body(_ size: CGFloat = 16) -> Font {
        customOrSystem("Comfortaa-Medium", size: size, weight: .medium, design: .rounded)
    }

    static func caption(_ size: CGFloat = 13) -> Font {
        customOrSystem("Comfortaa-Regular", size: size, weight: .regular, design: .rounded)
    }

    static func mono(_ size: CGFloat = 28) -> Font {
        customOrSystem("Comfortaa-Bold", size: size, weight: .bold, design: .rounded)
    }

    static func button(_ size: CGFloat = 16) -> Font {
        customOrSystem("Comfortaa-SemiBold", size: size, weight: .semibold, design: .rounded)
    }

    private static func customOrSystem(
        _ name: String,
        size: CGFloat,
        weight: Font.Weight,
        design: Font.Design
    ) -> Font {
        if UIFont(name: name, size: size) != nil {
            return .custom(name, size: size)
        }
        return .system(size: size, weight: weight, design: design)
    }
}
