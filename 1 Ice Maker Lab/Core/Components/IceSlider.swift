//
//  IceSlider.swift
//  1 Ice Maker Lab
//
//  Created by Roman on 10/28/26.
//

import SwiftUI

struct IceSlider: View {
    @Binding var value: Double
    var range: ClosedRange<Double>
    var step: Double = 1
    var accent: Color = LabColor.glacier

    @State private var isDragging = false

    private var progress: Double {
        let span = range.upperBound - range.lowerBound
        guard span > 0 else { return 0 }
        return (value - range.lowerBound) / span
    }

    var body: some View {
        GeometryReader { geo in
            let width = geo.size.width
            let thumbX = thumbOffset(in: width)

            ZStack(alignment: .leading) {
                // Frost track well
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.55),
                                LabColor.frost.opacity(0.85)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(height: 14)
                    .overlay(
                        Capsule()
                            .stroke(Color.white.opacity(0.7), lineWidth: 1)
                    )
                    .shadow(color: LabColor.deepTeal.opacity(0.08), radius: 4, y: 2)

                // Filled ice channel
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.95),
                                LabColor.cyanIce,
                                accent
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: max(14, thumbX + 14), height: 14)
                    .overlay(
                        Capsule()
                            .stroke(Color.white.opacity(0.55), lineWidth: 1)
                    )
                    .shadow(color: accent.opacity(0.35), radius: isDragging ? 8 : 4, y: 0)

                // Crystal facet ticks
                HStack(spacing: 0) {
                    ForEach(0..<5, id: \.self) { i in
                        Rectangle()
                            .fill(Color.white.opacity(0.35))
                            .frame(width: 1, height: 6)
                        if i < 4 { Spacer() }
                    }
                }
                .padding(.horizontal, 10)
                .frame(height: 14)
                .allowsHitTesting(false)

                // Ice chunk thumb
                IceShardShape()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white,
                                LabColor.cyanIce.opacity(0.95),
                                accent.opacity(0.85)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 34, height: 28)
                    .overlay(
                        IceShardShape()
                            .stroke(Color.white.opacity(0.95), lineWidth: 1.4)
                    )
                    .overlay {
                        // Inner highlight
                        Ellipse()
                            .fill(Color.white.opacity(0.55))
                            .frame(width: 12, height: 7)
                            .offset(x: -4, y: -5)
                    }
                    .shadow(color: accent.opacity(0.45), radius: isDragging ? 12 : 7, y: 3)
                    .scaleEffect(isDragging ? 1.08 : 1)
                    .offset(x: thumbX)
            }
            .frame(maxHeight: .infinity)
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { drag in
                        isDragging = true
                        update(from: drag.location.x, width: width)
                    }
                    .onEnded { _ in
                        withAnimation(LabTheme.Motion.quick) { isDragging = false }
                    }
            )
        }
        .frame(height: 36)
        .animation(LabTheme.Motion.quick, value: value)
    }

    private func thumbOffset(in width: CGFloat) -> CGFloat {
        let usable = max(width - 34, 1)
        return CGFloat(progress) * usable
    }

    private func update(from x: CGFloat, width: CGFloat) {
        let usable = max(width - 34, 1)
        let clampedX = min(max(x - 17, 0), usable)
        let ratio = Double(clampedX / usable)
        let raw = range.lowerBound + ratio * (range.upperBound - range.lowerBound)
        let stepped = (raw / step).rounded() * step
        value = min(max(stepped, range.lowerBound), range.upperBound)
    }
}

struct IceLabeledSlider: View {
    let title: String
    let valueText: String
    @Binding var value: Double
    var range: ClosedRange<Double>
    var step: Double = 1
    var accent: Color = LabColor.glacier

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(LabFont.body(14))
                    .foregroundStyle(LabColor.ink)
                Spacer()
                Text(valueText)
                    .font(LabFont.button(14))
                    .foregroundStyle(accent)
                    .contentTransition(.numericText())
            }
            IceSlider(value: $value, range: range, step: step, accent: accent)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.white.opacity(0.5))
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(Color.white.opacity(0.55), lineWidth: 1)
                )
        )
    }
}
