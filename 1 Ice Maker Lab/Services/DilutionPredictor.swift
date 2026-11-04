//
//  DilutionPredictor.swift
//  1 Ice Maker Lab
//
//  Created by Roman on 10/28/26.
//

import Foundation

enum DilutionPredictor {
    /// Unique lab tool: forecasts chill vs dilution for cocktail ice.
    static func forecast(
        shape: IceShape,
        drinkVolumeMl: Double,
        ambientCelsius: Double,
        clarityScore: Int
    ) -> DilutionForecast {
        let surface = shape.surfaceFactor
        let volume = shape.volumeMl
        let chill = min(98, (volume / max(drinkVolumeMl, 40)) * 110 / surface)
        let meltRate = surface * (0.55 + max(0, ambientCelsius - 4) * 0.04)
        let clarityHold = 1.0 - Double(100 - clarityScore) / 220.0
        let dilution = min(42, meltRate * 9.5 * (2.1 - clarityHold))
        let window = Int(max(4, (volume / (meltRate * 4.2)).rounded()))

        let verdict: String
        if chill >= 70 && dilution <= 16 {
            verdict = "Slow melt, strong chill — ideal for spirit-forward serves"
        } else if chill >= 55 && dilution <= 22 {
            verdict = "Balanced cooling for stirred classics"
        } else if dilution > 26 {
            verdict = "Fast dilution — better for highballs or short sips"
        } else {
            verdict = "Moderate chill; consider a larger sphere"
        }

        return DilutionForecast(
            chillPoints: (chill * 10).rounded() / 10,
            dilutionPercent: (dilution * 10).rounded() / 10,
            sipWindowMinutes: window,
            verdict: verdict
        )
    }
}
