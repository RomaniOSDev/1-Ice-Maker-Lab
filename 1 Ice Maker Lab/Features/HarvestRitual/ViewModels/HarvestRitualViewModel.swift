//
//  HarvestRitualViewModel.swift
//  1 Ice Maker Lab
//
//  Created by Roman on 10/28/26.
//

import Foundation
import Combine

@MainActor
final class HarvestRitualViewModel: ObservableObject {
    @Published var shape: IceShape = .sphere
    @Published var freezerCelsius: Double = -18
    @Published var hardness: WaterHardness = .soft
    @Published var method: FreezeMethod = .boiledDirectional
    @Published var boiledMinutes: Double = 8
    @Published var startAt: Date = Date()
    @Published var now: Date = Date()

    @Published var clarityAfter: Double = 88
    @Published var harvestNotes: String = ""
    @Published var logToJournal = true
    @Published var showCompleteSheet = false
    @Published var notificationsAllowed = false
    @Published var banner: String?

    private let store: HarvestBatchStore
    private var ticker: Timer?

    init(store: HarvestBatchStore? = nil) {
        self.store = store ?? .shared
        refreshClock()
        startTicker()
    }

    var plan: HarvestWindowPlan {
        HarvestWindowCalculator.plan(
            freezerCelsius: freezerCelsius,
            shape: shape,
            hardness: hardness,
            method: method
        )
    }

    var active: HarvestBatch? { store.activeBatch }

    var history: [HarvestBatch] { store.history }

    var previewOpenAt: Date {
        startAt.addingTimeInterval(TimeInterval(plan.harvestOpenOffset))
    }

    var previewCloseAt: Date {
        startAt.addingTimeInterval(TimeInterval(plan.harvestCloseOffset))
    }

    func refreshClock() {
        now = Date()
        store.refreshStatuses(at: now)
        if let active, active.refreshedStatus(at: now) == .missed {
            store.markMissedIfNeeded(active.id)
        }
    }

    func beginRitual() async {
        notificationsAllowed = await HarvestNotificationScheduler.shared.requestPermissionIfNeeded()
        let batch = HarvestBatch(
            startAt: startAt,
            shape: shape,
            freezerCelsius: freezerCelsius,
            hardness: hardness,
            method: method,
            boiledMinutes: Int(boiledMinutes.rounded()),
            plan: plan
        )
        store.start(batch)
        banner = notificationsAllowed
            ? "Ritual started — harvest alerts are scheduled."
            : "Ritual started — enable notifications for harvest alerts."
        refreshClock()
    }

    func updateChecklist(_ checklist: HarvestChecklist) {
        guard let id = active?.id else { return }
        store.updateChecklist(checklist, for: id)
    }

    func cancelRitual() {
        store.cancelActive()
        banner = "Ritual cancelled."
        refreshClock()
    }

    func completeHarvest() {
        guard let id = active?.id else { return }
        store.completeHarvest(
            id: id,
            clarityAfter: Int(clarityAfter.rounded()),
            notes: harvestNotes.trimmingCharacters(in: .whitespacesAndNewlines),
            logToJournal: logToJournal
        )
        showCompleteSheet = false
        harvestNotes = ""
        clarityAfter = 88
        banner = logToJournal ? "Harvest logged to journal." : "Harvest marked complete."
        refreshClock()
    }

    private func startTicker() {
        ticker?.invalidate()
        let timer = Timer(timeInterval: 1, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.refreshClock()
            }
        }
        RunLoop.main.add(timer, forMode: .common)
        ticker = timer
    }

    deinit {
        ticker?.invalidate()
    }
}
