//
//  HarvestBatchStore.swift
//  1 Ice Maker Lab
//
//  Created by Roman on 10/28/26.
//

import Foundation
import Combine

@MainActor
final class HarvestBatchStore: ObservableObject {
    static let shared = HarvestBatchStore()

    @Published private(set) var batches: [HarvestBatch] = []
    @Published private(set) var activeBatch: HarvestBatch?

    private let key = "lab.harvest.batches.v1"
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        load()
        refreshStatuses()
    }

    var history: [HarvestBatch] {
        batches
            .filter { $0.status == .harvested || $0.status == .missed || $0.status == .cancelled }
            .sorted { $0.createdAt > $1.createdAt }
    }

    func refreshStatuses(at date: Date = Date()) {
        var changed = false
        for index in batches.indices {
            let next = batches[index].refreshedStatus(at: date)
            if batches[index].status != next,
               batches[index].status != .harvested,
               batches[index].status != .cancelled {
                batches[index].status = next
                changed = true
            }
        }
        if changed { persist() }
        activeBatch = batches.first {
            $0.status == .freezing || $0.status == .harvestReady || $0.status == .planned
        }
    }

    func start(_ batch: HarvestBatch) {
        // Only one live ritual at a time.
        for index in batches.indices {
            if batches[index].status == .freezing || batches[index].status == .harvestReady || batches[index].status == .planned {
                batches[index].status = .cancelled
            }
        }
        var live = batch
        live.status = .freezing
        batches.insert(live, at: 0)
        persist()
        refreshStatuses()
        HarvestNotificationScheduler.shared.schedule(for: live)
    }

    func updateChecklist(_ checklist: HarvestChecklist, for id: UUID) {
        guard let index = batches.firstIndex(where: { $0.id == id }) else { return }
        batches[index].checklist = checklist
        persist()
        refreshStatuses()
    }

    func completeHarvest(
        id: UUID,
        clarityAfter: Int,
        notes: String,
        logToJournal: Bool
    ) {
        guard let index = batches.firstIndex(where: { $0.id == id }) else { return }
        batches[index].status = .harvested
        batches[index].clarityAfter = clarityAfter
        batches[index].notes = notes
        let finished = batches[index]
        persist()
        HarvestNotificationScheduler.shared.cancel(for: id)
        refreshStatuses()

        if logToJournal {
            let experiment = LabExperiment(
                shape: finished.shape,
                freezerCelsius: finished.freezerCelsius,
                hardness: finished.hardness,
                method: finished.method,
                boiledMinutes: finished.boiledMinutes,
                clarityScore: clarityAfter,
                notes: notes.isEmpty
                    ? "Harvest ritual · window \(HarvestWindowCalculator.formatClock(finished.harvestOpenAt))–\(HarvestWindowCalculator.formatClock(finished.harvestCloseAt))"
                    : notes
            )
            ExperimentStore.shared.add(experiment)
        }
    }

    func markMissedIfNeeded(_ id: UUID) {
        guard let index = batches.firstIndex(where: { $0.id == id }) else { return }
        if batches[index].refreshedStatus() == .missed {
            batches[index].status = .missed
            persist()
            HarvestNotificationScheduler.shared.cancel(for: id)
            refreshStatuses()
        }
    }

    func cancelActive() {
        guard let active = activeBatch,
              let index = batches.firstIndex(where: { $0.id == active.id }) else { return }
        batches[index].status = .cancelled
        persist()
        HarvestNotificationScheduler.shared.cancel(for: active.id)
        refreshStatuses()
    }

    private func persist() {
        guard let data = try? JSONEncoder().encode(batches) else { return }
        defaults.set(data, forKey: key)
    }

    private func load() {
        guard let data = defaults.data(forKey: key),
              let decoded = try? JSONDecoder().decode([HarvestBatch].self, from: data) else {
            batches = []
            return
        }
        batches = decoded
    }
}
