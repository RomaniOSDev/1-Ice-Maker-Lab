//
//  FreezeTimeCalculator.swift
//  1 Ice Maker Lab
//
//  Created by Roman on 10/28/26.
//

import Foundation

enum FreezeTimeCalculator {
    /// Estimates freeze time from freezer temp (°C), mold volume, and water hardness.
    static func estimate(
        freezerCelsius: Double,
        shape: IceShape,
        hardness: WaterHardness,
        directional: Bool
    ) -> FreezeEstimate {
        let clampedTemp = min(max(freezerCelsius, -30), -5)
        let coldFactor = abs(clampedTemp) / 18.0
        let baseHours = (shape.volumeMl / 18.0) / max(coldFactor, 0.35)
        let hardnessAdj = baseHours * hardness.freezeMultiplier
        let methodAdj = directional ? hardnessAdj * 1.12 : hardnessAdj
        let totalSeconds = Int((methodAdj * 3600).rounded())

        let nucleate = Int(Double(totalSeconds) * 0.18)
        let shell = Int(Double(totalSeconds) * 0.42)
        let core = totalSeconds - nucleate - shell

        let phases = [
            FreezePhase(
                title: "Nucleation",
                detail: "First crystals lock at the mold wall",
                seconds: nucleate
            ),
            FreezePhase(
                title: "Shell Build",
                detail: directional
                    ? "Freeze front advances from the open face"
                    : "Shell thickens from all sides",
                seconds: shell
            ),
            FreezePhase(
                title: "Core Seal",
                detail: "Impurities concentrate; wait for full set",
                seconds: core
            )
        ]

        return FreezeEstimate(totalSeconds: totalSeconds, phases: phases)
    }
}
