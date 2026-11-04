//
//  ClarityCalculatorViewModel.swift
//  1 Ice Maker Lab
//
//  Created by Roman on 10/28/26.
//

import Foundation
import Combine

@MainActor
final class ClarityCalculatorViewModel: ObservableObject {
    @Published var method: FreezeMethod = .directional
    @Published var hardness: WaterHardness = .soft
    @Published var boiledMinutes: Double = 5
    @Published var freezerCelsius: Double = -18
    @Published var shape: IceShape = .sphere
    @Published var drinkVolumeMl: Double = 75
    @Published var ambientCelsius: Double = 21

    var result: ClarityResult {
        ClarityScorer.score(
            method: method,
            hardness: hardness,
            boiledMinutes: Int(boiledMinutes.rounded()),
            freezerCelsius: freezerCelsius,
            shape: shape
        )
    }

    var dilution: DilutionForecast {
        DilutionPredictor.forecast(
            shape: shape,
            drinkVolumeMl: drinkVolumeMl,
            ambientCelsius: ambientCelsius,
            clarityScore: result.score
        )
    }
}
