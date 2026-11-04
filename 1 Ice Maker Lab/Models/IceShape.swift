//
//  IceShape.swift
//  1 Ice Maker Lab
//
//  Created by Roman on 10/28/26.
//

import Foundation

enum IceShape: String, CaseIterable, Identifiable, Codable {
    case sphere
    case cube
    case spear
    case diamond

    var id: String { rawValue }

    var title: String {
        switch self {
        case .sphere: return "Sphere"
        case .cube: return "Cube"
        case .spear: return "Spear"
        case .diamond: return "Diamond"
        }
    }

    var volumeMl: Double {
        switch self {
        case .sphere: return 55
        case .cube: return 40
        case .spear: return 28
        case .diamond: return 35
        }
    }

    var surfaceFactor: Double {
        switch self {
        case .sphere: return 0.82
        case .cube: return 1.00
        case .spear: return 1.18
        case .diamond: return 1.10
        }
    }

    var symbolName: String {
        switch self {
        case .sphere: return "circle.fill"
        case .cube: return "cube.fill"
        case .spear: return "line.diagonal"
        case .diamond: return "diamond.fill"
        }
    }
}

enum WaterHardness: String, CaseIterable, Identifiable, Codable {
    case soft
    case medium
    case hard

    var id: String { rawValue }

    var title: String {
        switch self {
        case .soft: return "Soft"
        case .medium: return "Medium"
        case .hard: return "Hard"
        }
    }

    var clarityPenalty: Double {
        switch self {
        case .soft: return 0
        case .medium: return 8
        case .hard: return 16
        }
    }

    var freezeMultiplier: Double {
        switch self {
        case .soft: return 1.00
        case .medium: return 1.04
        case .hard: return 1.09
        }
    }
}

enum FreezeMethod: String, CaseIterable, Identifiable, Codable {
    case standard
    case directional
    case boiledDirectional

    var id: String { rawValue }

    var title: String {
        switch self {
        case .standard: return "Standard"
        case .directional: return "Directional"
        case .boiledDirectional: return "Boiled + Directional"
        }
    }

    var clarityBoost: Double {
        switch self {
        case .standard: return 0
        case .directional: return 28
        case .boiledDirectional: return 42
        }
    }
}
