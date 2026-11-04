//
//  LabExperiment.swift
//  1 Ice Maker Lab
//
//  Created by Roman on 10/28/26.
//

import Foundation

struct LabExperiment: Identifiable, Codable, Equatable {
    var id: UUID
    var date: Date
    var shape: IceShape
    var freezerCelsius: Double
    var hardness: WaterHardness
    var method: FreezeMethod
    var boiledMinutes: Int
    var clarityScore: Int
    var notes: String
    var ringScore: Int?

    init(
        id: UUID = UUID(),
        date: Date = Date(),
        shape: IceShape,
        freezerCelsius: Double,
        hardness: WaterHardness,
        method: FreezeMethod,
        boiledMinutes: Int = 0,
        clarityScore: Int,
        notes: String = "",
        ringScore: Int? = nil
    ) {
        self.id = id
        self.date = date
        self.shape = shape
        self.freezerCelsius = freezerCelsius
        self.hardness = hardness
        self.method = method
        self.boiledMinutes = boiledMinutes
        self.clarityScore = clarityScore
        self.notes = notes
        self.ringScore = ringScore
    }

    var clarityLabel: String {
        switch clarityScore {
        case 90...100: return "Optical"
        case 75..<90: return "Bar Clear"
        case 55..<75: return "Cloudy Core"
        default: return "Foggy"
        }
    }
}

struct FreezeEstimate: Equatable {
    let totalSeconds: Int
    let phases: [FreezePhase]

    var formattedDuration: String {
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        }
        return "\(minutes)m"
    }
}

struct FreezePhase: Identifiable, Equatable {
    let id = UUID()
    let title: String
    let detail: String
    let seconds: Int
}

struct ClarityResult: Equatable {
    let score: Int
    let label: String
    let tips: [String]
    let impurityRisk: Double
}

struct DilutionForecast: Equatable {
    let chillPoints: Double
    let dilutionPercent: Double
    let sipWindowMinutes: Int
    let verdict: String
}
