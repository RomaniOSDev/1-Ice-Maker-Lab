//
//  FreezeTimersViewModel.swift
//  1 Ice Maker Lab
//
//  Created by Roman on 10/28/26.
//

import Foundation
import Combine

@MainActor
final class FreezeTimersViewModel: ObservableObject {
    @Published var freezerCelsius: Double = -18
    @Published var shape: IceShape = .sphere
    @Published var hardness: WaterHardness = .soft
    @Published var directional: Bool = true

    @Published var isRunning = false
    @Published var elapsedSeconds = 0
    @Published var estimate: FreezeEstimate = FreezeTimeCalculator.estimate(
        freezerCelsius: -18,
        shape: .sphere,
        hardness: .soft,
        directional: true
    )

    private var timer: Timer?

    var progress: Double {
        guard estimate.totalSeconds > 0 else { return 0 }
        return min(1, Double(elapsedSeconds) / Double(estimate.totalSeconds))
    }

    var remainingText: String {
        let left = max(0, estimate.totalSeconds - elapsedSeconds)
        let h = left / 3600
        let m = (left % 3600) / 60
        let s = left % 60
        if h > 0 {
            return String(format: "%d:%02d:%02d", h, m, s)
        }
        return String(format: "%02d:%02d", m, s)
    }

    func recalculate() {
        estimate = FreezeTimeCalculator.estimate(
            freezerCelsius: freezerCelsius,
            shape: shape,
            hardness: hardness,
            directional: directional
        )
        if !isRunning {
            elapsedSeconds = 0
        }
    }

    func toggle() {
        if isRunning {
            pause()
        } else {
            start()
        }
    }

    func start() {
        isRunning = true
        timer?.invalidate()
        let timer = Timer(timeInterval: 1, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.tick()
            }
        }
        RunLoop.main.add(timer, forMode: .common)
        self.timer = timer
    }

    func pause() {
        isRunning = false
        timer?.invalidate()
        timer = nil
    }

    func reset() {
        pause()
        elapsedSeconds = 0
        recalculate()
    }

    private func tick() {
        guard elapsedSeconds < estimate.totalSeconds else {
            pause()
            return
        }
        elapsedSeconds += 1
    }

    deinit {
        timer?.invalidate()
    }
}
