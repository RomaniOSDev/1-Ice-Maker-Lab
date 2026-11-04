//
//  LabCard.swift
//  1 Ice Maker Lab
//
//  Created by Roman on 10/28/26.
//

import SwiftUI

struct LabCard<Content: View>: View {
    var padding: CGFloat = LabTheme.Spacing.md
    @ViewBuilder var content: Content

    var body: some View {
        content
            .padding(padding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: LabTheme.Radius.md, style: .continuous)
                    .fill(LabColor.cardFill)
                    .background(
                        RoundedRectangle(cornerRadius: LabTheme.Radius.md, style: .continuous)
                            .fill(.ultraThinMaterial)
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: LabTheme.Radius.md, style: .continuous)
                    .stroke(LabColor.stroke, lineWidth: 1)
            )
            .shadow(color: LabColor.deepTeal.opacity(0.08), radius: 16, y: 8)
    }
}

struct SectionHeader: View {
    let title: String
    var subtitle: String? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(LabFont.title(24))
                .foregroundStyle(LabColor.ink)
            if let subtitle {
                Text(subtitle)
                    .font(LabFont.caption())
                    .foregroundStyle(LabColor.inkSoft)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct MetricChip: View {
    let label: String
    let value: String
    var accent: Color = LabColor.glacier

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label.uppercased())
                .font(LabFont.caption(11))
                .foregroundStyle(LabColor.inkSoft)
                .tracking(0.6)
            Text(value)
                .font(LabFont.title(18))
                .foregroundStyle(accent)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: LabTheme.Radius.sm, style: .continuous)
                .fill(Color.white.opacity(0.55))
        )
    }
}

struct LabPrimaryButton: View {
    let title: String
    var enabled: Bool = true
    var systemImage: String? = nil
    let action: () -> Void

    var body: some View {
        IceButton(title: title, systemImage: systemImage, enabled: enabled, action: action)
    }
}
