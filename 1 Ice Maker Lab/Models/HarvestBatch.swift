//
//  HarvestBatch.swift
//  1 Ice Maker Lab
//
//  Created by Roman on 10/28/26.
//

import Foundation

enum HarvestBatchStatus: String, Codable, CaseIterable {
    case planned
    case freezing
    case harvestReady
    case harvested
    case missed
    case cancelled

    var title: String {
        switch self {
        case .planned: return "Planned"
        case .freezing: return "Freezing"
        case .harvestReady: return "Harvest window"
        case .harvested: return "Harvested"
        case .missed: return "Missed window"
        case .cancelled: return "Cancelled"
        }
    }
}

struct HarvestChecklist: Codable, Equatable {
    var coolerLidReady: Bool = false
    var openFaceClear: Bool = false
    var cloudyBandVisible: Bool = false
    var cutAwayDone: Bool = false
    var temperDone: Bool = false

    var completedCount: Int {
        [coolerLidReady, openFaceClear, cloudyBandVisible, cutAwayDone, temperDone]
            .filter { $0 }.count
    }

    var isComplete: Bool { completedCount == 5 }

    static let steps: [(WritableKeyPath<HarvestChecklist, Bool>, String, String)] = [
        (\.coolerLidReady, "Stage the cooler", "Lid off, insulated sides ready"),
        (\.openFaceClear, "Keep the open face clear", "Impurities must stay at the top"),
        (\.cloudyBandVisible, "Spot the cloudy band", "White line near the last unfrozen pocket"),
        (\.cutAwayDone, "Cut / pour off the band", "Remove the cloudy tip before it freezes in"),
        (\.temperDone, "Temper before serving", "Rest 1–2 min so the surface won't crack")
    ]
}

struct HarvestWindowPlan: Equatable {
    let totalFreezeSeconds: Int
    let harvestOpenOffset: Int
    let harvestCloseOffset: Int
    let phases: [FreezePhase]
    let tip: String

    var windowSeconds: Int { max(0, harvestCloseOffset - harvestOpenOffset) }

    var windowLabel: String {
        let minutes = windowSeconds / 60
        if minutes >= 60 {
            return String(format: "%dh %dm window", minutes / 60, minutes % 60)
        }
        return "\(minutes) min window"
    }
}

struct HarvestBatch: Identifiable, Codable, Equatable {
    var id: UUID
    var createdAt: Date
    var startAt: Date
    var shape: IceShape
    var freezerCelsius: Double
    var hardness: WaterHardness
    var method: FreezeMethod
    var boiledMinutes: Int
    var totalFreezeSeconds: Int
    var harvestOpenAt: Date
    var harvestCloseAt: Date
    var status: HarvestBatchStatus
    var checklist: HarvestChecklist
    var clarityAfter: Int?
    var notes: String

    init(
        id: UUID = UUID(),
        createdAt: Date = Date(),
        startAt: Date,
        shape: IceShape,
        freezerCelsius: Double,
        hardness: WaterHardness,
        method: FreezeMethod,
        boiledMinutes: Int,
        plan: HarvestWindowPlan,
        status: HarvestBatchStatus = .freezing,
        checklist: HarvestChecklist = HarvestChecklist(),
        clarityAfter: Int? = nil,
        notes: String = ""
    ) {
        self.id = id
        self.createdAt = createdAt
        self.startAt = startAt
        self.shape = shape
        self.freezerCelsius = freezerCelsius
        self.hardness = hardness
        self.method = method
        self.boiledMinutes = boiledMinutes
        self.totalFreezeSeconds = plan.totalFreezeSeconds
        self.harvestOpenAt = startAt.addingTimeInterval(TimeInterval(plan.harvestOpenOffset))
        self.harvestCloseAt = startAt.addingTimeInterval(TimeInterval(plan.harvestCloseOffset))
        self.status = status
        self.checklist = checklist
        self.clarityAfter = clarityAfter
        self.notes = notes
    }

    var endAt: Date {
        startAt.addingTimeInterval(TimeInterval(totalFreezeSeconds))
    }

    func refreshedStatus(at date: Date = Date()) -> HarvestBatchStatus {
        switch status {
        case .harvested, .cancelled:
            return status
        case .planned, .freezing, .harvestReady, .missed:
            if date < harvestOpenAt { return .freezing }
            if date <= harvestCloseAt { return .harvestReady }
            return .missed
        }
    }

    func progress(at date: Date = Date()) -> Double {
        let elapsed = date.timeIntervalSince(startAt)
        guard totalFreezeSeconds > 0 else { return 0 }
        return min(1, max(0, elapsed / Double(totalFreezeSeconds)))
    }

    func harvestBandProgress() -> (start: Double, end: Double) {
        guard totalFreezeSeconds > 0 else { return (0.7, 0.85) }
        let open = startAt.distance(to: harvestOpenAt) / Double(totalFreezeSeconds)
        let close = startAt.distance(to: harvestCloseAt) / Double(totalFreezeSeconds)
        return (min(1, max(0, open)), min(1, max(0, close)))
    }
}
