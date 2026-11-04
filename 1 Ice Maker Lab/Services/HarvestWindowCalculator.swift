//
//  HarvestWindowCalculator.swift
//  1 Ice Maker Lab
//
//  Created by Roman on 10/28/26.
//

import Foundation

enum HarvestWindowCalculator {
    /// Builds an overnight freeze plan with a harvest window before the cloudy band locks in.
    static func plan(
        freezerCelsius: Double,
        shape: IceShape,
        hardness: WaterHardness,
        method: FreezeMethod
    ) -> HarvestWindowPlan {
        let directional = method != .standard
        let estimate = FreezeTimeCalculator.estimate(
            freezerCelsius: freezerCelsius,
            shape: shape,
            hardness: hardness,
            directional: directional
        )

        let total = max(estimate.totalSeconds, 60 * 45)

        // Directional / boiled: earlier, wider window. Standard tray: late, narrow.
        let openRatio: Double
        let closeRatio: Double
        let tip: String

        switch method {
        case .boiledDirectional:
            openRatio = 0.70
            closeRatio = 0.86
            tip = "Boiled + directional: harvest when the top pocket is still liquid — cut the cloudy tip free."
        case .directional:
            openRatio = 0.74
            closeRatio = 0.88
            tip = "Directional freeze: impurities rise. Open the cooler and remove the white band before it seals."
        case .standard:
            openRatio = 0.82
            closeRatio = 0.93
            tip = "Tray freeze seals fast. Check often near the end — the clear shell forms first, then the foggy core."
        }

        // Softer water + colder freezer slightly widens the usable window.
        var widen = 0.0
        if hardness == .soft { widen += 0.02 }
        if freezerCelsius <= -18 { widen += 0.015 }
        widen -= (shape.surfaceFactor - 0.82) * 0.02

        let open = Int(Double(total) * openRatio)
        let close = Int(Double(total) * min(0.96, closeRatio + widen))

        return HarvestWindowPlan(
            totalFreezeSeconds: total,
            harvestOpenOffset: open,
            harvestCloseOffset: max(open + 20 * 60, close),
            phases: estimate.phases,
            tip: tip
        )
    }

    static func formatCountdown(to date: Date, from now: Date = Date()) -> String {
        let seconds = Int(date.timeIntervalSince(now))
        if seconds <= 0 { return "now" }
        let h = seconds / 3600
        let m = (seconds % 3600) / 60
        let s = seconds % 60
        if h > 0 { return String(format: "%d:%02d:%02d", h, m, s) }
        return String(format: "%02d:%02d", m, s)
    }

    static func formatClock(_ date: Date) -> String {
        date.formatted(date: .omitted, time: .shortened)
    }

    static func formatDayTime(_ date: Date) -> String {
        date.formatted(date: .abbreviated, time: .shortened)
    }
}
