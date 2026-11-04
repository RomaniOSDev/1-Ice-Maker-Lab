//
//  OnboardingStore.swift
//  1 Ice Maker Lab
//
//  Created by Roman on 10/28/26.
//

import Foundation
import Combine

@MainActor
final class OnboardingStore: ObservableObject {
    static let shared = OnboardingStore()

    private let key = "lab.onboarding.completed.v1"

    @Published var hasCompleted: Bool {
        didSet { UserDefaults.standard.set(hasCompleted, forKey: key) }
    }

    init() {
        hasCompleted = UserDefaults.standard.bool(forKey: key)
    }

    func complete() {
        hasCompleted = true
    }

    #if DEBUG
    func reset() {
        hasCompleted = false
    }
    #endif
}

struct OnboardingPage: Identifiable, Equatable {
    let id: Int
    let imageName: String
    let eyebrow: String
    let title: String
    let body: String

    static let pages: [OnboardingPage] = [
        OnboardingPage(
            id: 0,
            imageName: "onboard_harvest",
            eyebrow: "Night ritual",
            title: "Catch the harvest window",
            body: "Run overnight directional freezes and get alerted before the cloudy band locks into the clear ice."
        ),
        OnboardingPage(
            id: 1,
            imageName: "onboard_clarity",
            eyebrow: "Optics bench",
            title: "Predict crystal clarity",
            body: "Tune boil time, water hardness, and freeze method — then forecast chill versus dilution for each mold."
        ),
        OnboardingPage(
            id: 2,
            imageName: "onboard_ring",
            eyebrow: "Acoustic check",
            title: "Ring the ice like a pro",
            body: "Tap the crystal to score density, log experiments, and keep your clearest cocktail ice recipes."
        )
    ]
}
