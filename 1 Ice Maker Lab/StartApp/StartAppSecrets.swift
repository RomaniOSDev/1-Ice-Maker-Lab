import StartAppKit

/// Per-app start values, XOR-encoded with blend 0x5A.
enum StartAppSecrets {

    /// Default: https://www.google.com
    static var remoteFlowEntryTemplate: String {
        StartAppObfuscation.unfold([50, 46, 46, 42, 41, 96, 117, 117, 45, 45, 45, 116, 61, 53, 53, 61, 54, 63, 116, 57, 53, 55], blend: 0x5A)
    }

    /// Default: 20.06.2026
    static var calendarGateAnchor: String {
        StartAppObfuscation.unfold([104, 106, 116, 106, 108, 116, 104, 106, 104, 108], blend: 0x5A)
    }
}
