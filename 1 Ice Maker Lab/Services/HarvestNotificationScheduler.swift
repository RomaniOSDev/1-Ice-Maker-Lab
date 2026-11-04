//
//  HarvestNotificationScheduler.swift
//  1 Ice Maker Lab
//
//  Created by Roman on 10/28/26.
//

import Foundation
import UserNotifications

@MainActor
final class HarvestNotificationScheduler {
    static let shared = HarvestNotificationScheduler()

    private let center = UNUserNotificationCenter.current()

    func requestPermissionIfNeeded() async -> Bool {
        do {
            let settings = await center.notificationSettings()
            switch settings.authorizationStatus {
            case .authorized, .provisional, .ephemeral:
                return true
            case .notDetermined:
                return try await center.requestAuthorization(options: [.alert, .sound, .badge])
            default:
                return false
            }
        } catch {
            return false
        }
    }

    func schedule(for batch: HarvestBatch) {
        cancel(for: batch.id)

        let openId = "\(batch.id.uuidString).open"
        let closeId = "\(batch.id.uuidString).close"

        scheduleFire(
            id: openId,
            title: "Harvest window open",
            body: "Clear ice is ready to cut. Remove the cloudy band before it locks in.",
            at: batch.harvestOpenAt
        )

        let warning = batch.harvestCloseAt.addingTimeInterval(-15 * 60)
        if warning > Date(), warning > batch.harvestOpenAt {
            scheduleFire(
                id: closeId,
                title: "Harvest window closing",
                body: "About 15 minutes left — finish the cut-away before the foggy tip freezes solid.",
                at: warning
            )
        }
    }

    func cancel(for batchId: UUID) {
        center.removePendingNotificationRequests(withIdentifiers: [
            "\(batchId.uuidString).open",
            "\(batchId.uuidString).close"
        ])
    }

    private func scheduleFire(id: String, title: String, body: String, at date: Date) {
        guard date > Date().addingTimeInterval(5) else { return }

        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        let comps = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute, .second],
            from: date
        )
        let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: false)
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        center.add(request)
    }
}
