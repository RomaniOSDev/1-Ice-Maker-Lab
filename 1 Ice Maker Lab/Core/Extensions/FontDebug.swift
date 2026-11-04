//
//  FontDebug.swift
//  1 Ice Maker Lab
//
//  Created by Roman on 10/28/26.
//

import UIKit

enum LabFontBootstrap {
    /// Ensures custom fonts resolve; call once at launch if needed.
    static func warmUp() {
        _ = UIFont(name: "Iceberg-Regular", size: 20)
        _ = UIFont(name: "Comfortaa-Regular", size: 16)
        _ = UIFont(name: "Comfortaa-Medium", size: 16)
        _ = UIFont(name: "Comfortaa-SemiBold", size: 16)
        _ = UIFont(name: "Comfortaa-Bold", size: 16)
    }
}
