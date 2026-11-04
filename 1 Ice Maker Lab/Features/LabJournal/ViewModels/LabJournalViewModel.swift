//
//  LabJournalViewModel.swift
//  1 Ice Maker Lab
//
//  Created by Roman on 10/28/26.
//

import Foundation
import Combine

@MainActor
final class LabJournalViewModel: ObservableObject {
    @Published var showComposer = false
    @Published var draftShape: IceShape = .sphere
    @Published var draftFreezer: Double = -18
    @Published var draftHardness: WaterHardness = .soft
    @Published var draftMethod: FreezeMethod = .directional
    @Published var draftBoil: Double = 5
    @Published var draftClarity: Double = 80
    @Published var draftNotes: String = ""
    @Published var draftRing: Double = 70
    @Published var includeRing = false

    private let store: ExperimentStore

    init(store: ExperimentStore? = nil) {
        self.store = store ?? ExperimentStore.shared
    }

    func saveDraft() {
        let experiment = LabExperiment(
            shape: draftShape,
            freezerCelsius: draftFreezer,
            hardness: draftHardness,
            method: draftMethod,
            boiledMinutes: Int(draftBoil.rounded()),
            clarityScore: Int(draftClarity.rounded()),
            notes: draftNotes.trimmingCharacters(in: .whitespacesAndNewlines),
            ringScore: includeRing ? Int(draftRing.rounded()) : nil
        )
        store.add(experiment)
        resetDraft()
        showComposer = false
    }

    func delete(_ experiment: LabExperiment) {
        store.delete(experiment)
    }

    private func resetDraft() {
        draftShape = .sphere
        draftFreezer = -18
        draftHardness = .soft
        draftMethod = .directional
        draftBoil = 5
        draftClarity = 80
        draftNotes = ""
        draftRing = 70
        includeRing = false
    }
}
