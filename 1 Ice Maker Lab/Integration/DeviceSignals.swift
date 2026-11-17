import Foundation
import UIKit
import CoreMotion
import Darwin

enum DeviceSignals {

    static func captureIfNeeded(into storage: IntegrationStorage) {
        guard !storage.deviceSignalsCaptured else { return }
        storage.storeDeviceSignals(
            sub12: batterySignal(),
            sub13: accelerometerSignal(),
            sub14: environmentSignal()
        )
    }

    private static func batterySignal() -> String {
        let device = UIDevice.current
        let level: Float
        let state: UIDevice.BatteryState
        if Thread.isMainThread {
            device.isBatteryMonitoringEnabled = true
            level = device.batteryLevel
            state = device.batteryState
        } else {
            var capturedLevel: Float = -1
            var capturedState: UIDevice.BatteryState = .unknown
            DispatchQueue.main.sync {
                device.isBatteryMonitoringEnabled = true
                capturedLevel = device.batteryLevel
                capturedState = device.batteryState
            }
            level = capturedLevel
            state = capturedState
        }

        let stateText: String
        switch state {
        case .unknown: stateText = "unknown"
        case .unplugged: stateText = "unplugged"
        case .charging: stateText = "charging"
        case .full: stateText = "full"
        @unknown default: stateText = "unknown"
        }
        let levelText: String
        if level < 0 {
            levelText = "-1"
        } else {
            levelText = String(format: "%.2f", locale: Locale(identifier: "en_US_POSIX"), level)
        }
        return "\(levelText)_\(stateText)"
    }

    private static func accelerometerSignal() -> String {
        let manager = CMMotionManager()
        guard manager.isAccelerometerAvailable else {
            return "0_0_0|0_0_0"
        }
        manager.accelerometerUpdateInterval = 0.02
        let posix = Locale(identifier: "en_US_POSIX")
        let queue = OperationQueue()
        queue.name = "integration.device-signals.accelerometer"
        queue.maxConcurrentOperationCount = 1

        var samples: [String] = []
        let lock = NSLock()
        let sem = DispatchSemaphore(value: 0)

        manager.startAccelerometerUpdates(to: queue) { data, _ in
            guard let data else { return }
            let formatted = String(
                format: "%.3f_%.3f_%.3f",
                locale: posix,
                data.acceleration.x,
                data.acceleration.y,
                data.acceleration.z
            )
            lock.lock()
            defer { lock.unlock() }
            guard samples.count < 2 else { return }
            samples.append(formatted)
            if samples.count == 2 {
                manager.stopAccelerometerUpdates()
                sem.signal()
            }
        }

        _ = sem.wait(timeout: .now() + 0.5)
        manager.stopAccelerometerUpdates()

        lock.lock()
        let a = samples.count > 0 ? samples[0] : "0_0_0"
        let b = samples.count > 1 ? samples[1] : "0_0_0"
        lock.unlock()
        return "\(a)|\(b)"
    }

    private static func environmentSignal() -> String {
        var flags: [String] = []
        #if targetEnvironment(simulator)
        flags.append("simulator")
        #endif
        if isDebuggerAttached() {
            flags.append("debugger")
        }
        if Bundle.main.appStoreReceiptURL?.lastPathComponent == "sandboxReceipt" {
            flags.append("testflight")
        }
        return flags.isEmpty ? "prod" : flags.joined(separator: ",")
    }

    private static func isDebuggerAttached() -> Bool {
        var info = kinfo_proc()
        var size = MemoryLayout<kinfo_proc>.stride
        var mib: [Int32] = [CTL_KERN, KERN_PROC, KERN_PROC_PID, getpid()]
        let result = sysctl(&mib, u_int(mib.count), &info, &size, nil, 0)
        guard result == 0 else { return false }
        return (info.kp_proc.p_flag & P_TRACED) != 0
    }
}
