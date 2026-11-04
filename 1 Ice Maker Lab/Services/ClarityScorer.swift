//
//  ClarityScorer.swift
//  1 Ice Maker Lab
//
//  Created by Roman on 10/28/26.
//

import Foundation

enum ClarityScorer {
    static func score(
        method: FreezeMethod,
        hardness: WaterHardness,
        boiledMinutes: Int,
        freezerCelsius: Double,
        shape: IceShape
    ) -> ClarityResult {
        var value = 48.0
        value += method.clarityBoost
        value -= hardness.clarityPenalty

        let boilBoost = min(Double(boiledMinutes), 12) * 1.4
        value += boilBoost

        if freezerCelsius > -12 {
            value -= 10
        } else if freezerCelsius < -22 {
            value += 4
        }

        // Larger surface molds trap more air unless directional.
        if method == .standard {
            value -= (shape.surfaceFactor - 0.82) * 12
        }

        let clamped = Int(min(max(value.rounded(), 8), 99))
        let impurity = max(0, 1 - Double(clamped) / 100.0)

        let label: String
        switch clamped {
        case 90...: label = "Optical clarity"
        case 75..<90: label = "Bar-ready clear"
        case 55..<75: label = "Soft haze risk"
        default: label = "Cloudy outcome likely"
        }

        var tips: [String] = []
        if method == .standard {
            tips.append("Switch to directional freeze to push minerals one way.")
        }
        if boiledMinutes < 5 {
            tips.append("Boil 5–10 minutes to drive off dissolved gases.")
        }
        if hardness != .soft {
            tips.append("Filter or use low-mineral water for glass-like cores.")
        }
        if freezerCelsius > -15 {
            tips.append("Colder freezer (−18°C or below) slows impurity trapping.")
        }
        if tips.isEmpty {
            tips.append("Keep the open face insulated; harvest before the cloudy band freezes in.")
        }

        return ClarityResult(
            score: clamped,
            label: label,
            tips: tips,
            impurityRisk: impurity
        )
    }
}
