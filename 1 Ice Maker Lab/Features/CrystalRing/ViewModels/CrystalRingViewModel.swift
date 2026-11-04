//
//  CrystalRingViewModel.swift
//  1 Ice Maker Lab
//
//  Created by Roman on 10/28/26.
//

import Foundation
import Combine
import UIKit

@MainActor
final class CrystalRingViewModel: ObservableObject {
    @Published var taps: [RingTap] = []
    @Published var lastScore: Int?
    @Published var rippleToken = 0
    @Published var isListening = false

    struct RingTap: Identifiable {
        let id = UUID()
        let score: Int
        let date: Date
    }

    var averageScore: Int? {
        guard !taps.isEmpty else { return nil }
        return taps.map(\.score).reduce(0, +) / taps.count
    }

    var densityLabel: String {
        guard let score = lastScore else { return "Tap the crystal" }
        switch score {
        case 85...: return "Bright ring — dense & clear"
        case 65..<85: return "Clean tone — solid structure"
        case 45..<65: return "Dull thud — trapped air likely"
        default: return "Muddy response — cloudy core"
        }
    }

    func strike() {
        isListening = true
        rippleToken += 1
        UIImpactFeedbackGenerator(style: .rigid).impactOccurred()

        // Simulated acoustic density from timing jitter + history drift.
        let base = Int.random(in: 42...96)
        let bias = taps.suffix(3).map(\.score).isEmpty
            ? 0
            : (taps.suffix(3).map(\.score).reduce(0, +) / max(taps.suffix(3).count, 1) - 70) / 8
        let score = min(99, max(20, base + bias))
        lastScore = score
        taps.insert(RingTap(score: score, date: Date()), at: 0)
        if taps.count > 12 {
            taps = Array(taps.prefix(12))
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.55) { [weak self] in
            self?.isListening = false
        }
    }

    func clearHistory() {
        taps.removeAll()
        lastScore = nil
    }
}
