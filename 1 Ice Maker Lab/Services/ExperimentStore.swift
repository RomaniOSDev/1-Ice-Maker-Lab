//
//  ExperimentStore.swift
//  1 Ice Maker Lab
//
//  Created by Roman on 10/28/26.
//

import Foundation
import Combine

@MainActor
final class ExperimentStore: ObservableObject {
    static let shared = ExperimentStore()

    @Published private(set) var experiments: [LabExperiment] = []

    private let key = "lab.experiments.v1"
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        load()
        if experiments.isEmpty {
            seedIfNeeded()
        }
    }

    var bestClarity: LabExperiment? {
        experiments.max(by: { $0.clarityScore < $1.clarityScore })
    }

    func add(_ experiment: LabExperiment) {
        experiments.insert(experiment, at: 0)
        persist()
    }

    func update(_ experiment: LabExperiment) {
        guard let index = experiments.firstIndex(where: { $0.id == experiment.id }) else { return }
        experiments[index] = experiment
        persist()
    }

    func delete(_ experiment: LabExperiment) {
        experiments.removeAll { $0.id == experiment.id }
        persist()
    }

    private func persist() {
        guard let data = try? JSONEncoder().encode(experiments) else { return }
        defaults.set(data, forKey: key)
    }

    private func load() {
        guard let data = defaults.data(forKey: key),
              let decoded = try? JSONDecoder().decode([LabExperiment].self, from: data) else {
            experiments = []
            return
        }
        experiments = decoded.sorted { $0.date > $1.date }
    }

    private func seedIfNeeded() {
        let samples = [
            LabExperiment(
                date: Calendar.current.date(byAdding: .day, value: -3, to: Date()) ?? Date(),
                shape: .sphere,
                freezerCelsius: -18,
                hardness: .soft,
                method: .boiledDirectional,
                boiledMinutes: 8,
                clarityScore: 94,
                notes: "Insulated cooler method. Cloudy band stayed at the top.",
                ringScore: 91
            ),
            LabExperiment(
                date: Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date(),
                shape: .cube,
                freezerCelsius: -14,
                hardness: .medium,
                method: .standard,
                boiledMinutes: 0,
                clarityScore: 52,
                notes: "Tap water, tray freeze. Dense white core.",
                ringScore: 48
            )
        ]
        experiments = samples
        persist()
    }
}
