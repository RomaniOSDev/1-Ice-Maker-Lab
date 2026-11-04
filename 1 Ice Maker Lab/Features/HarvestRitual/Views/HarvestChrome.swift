//
//  HarvestChrome.swift
//  1 Ice Maker Lab
//
//  Created by Roman on 10/28/26.
//

import SwiftUI

/// Volumetric panel used only on the Harvest ritual screen.
struct HarvestPanel<Content: View>: View {
    var padding: CGFloat = 18
    var accent: Color = LabColor.glacier
    @ViewBuilder var content: Content

    var body: some View {
        content
            .padding(padding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background {
                ZStack {
                    RoundedRectangle(cornerRadius: 26, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.92),
                                    Color(red: 0.86, green: 0.93, blue: 1.0).opacity(0.88)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )

                    RoundedRectangle(cornerRadius: 26, style: .continuous)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.95),
                                    accent.opacity(0.35),
                                    Color.white.opacity(0.2)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.4
                        )

                    // Soft inner highlight for glass volume
                    RoundedRectangle(cornerRadius: 26, style: .continuous)
                        .stroke(Color.white.opacity(0.55), lineWidth: 1)
                        .padding(1)
                        .blur(radius: 0.5)
                        .opacity(0.6)
                }
            }
            .shadow(color: LabColor.deepTeal.opacity(0.10), radius: 4, y: 2)
            .shadow(color: LabColor.glacier.opacity(0.18), radius: 22, y: 14)
    }
}

struct HarvestHeroStage: View {
    var progress: Double
    var statusTitle: String
    var statusColor: Color
    var subtitle: String
    var countdownLabel: String?
    var countdownValue: String?
    @State private var drift = false
    @State private var shimmer = false

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            Image("directional_cooler")
                .resizable()
                .scaledToFill()
                .frame(maxWidth: .infinity)
                .frame(height: 240)
                .overlay {
                    LinearGradient(
                        colors: [
                            LabColor.deepTeal.opacity(0.55),
                            LabColor.glacier.opacity(0.25),
                            Color.white.opacity(0.05)
                        ],
                        startPoint: .bottomLeading,
                        endPoint: .topTrailing
                    )
                }
                .overlay(alignment: .topTrailing) {
                    Image("ice_sphere_hero")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 118, height: 118)
                        .clipShape(Circle())
                        .overlay(
                            Circle().stroke(
                                LinearGradient(
                                    colors: [.white, LabColor.cyanIce],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 2
                            )
                        )
                        .shadow(color: LabColor.cyanIce.opacity(0.55), radius: 18, y: 8)
                        .offset(x: -18, y: drift ? 16 : 28)
                        .rotationEffect(.degrees(drift ? -4 : 4))
                }
                .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))

            VStack(alignment: .leading, spacing: 10) {
                Text(statusTitle.uppercased())
                    .font(LabFont.caption(11))
                    .tracking(1.4)
                    .foregroundStyle(statusColor)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Capsule().fill(Color.white.opacity(0.88)))

                Text(subtitle)
                    .font(LabFont.display(26))
                    .foregroundStyle(.white)
                    .shadow(color: .black.opacity(0.25), radius: 8, y: 2)

                if let countdownLabel, let countdownValue {
                    HStack(alignment: .lastTextBaseline, spacing: 8) {
                        Text(countdownLabel)
                            .font(LabFont.caption(12))
                            .foregroundStyle(.white.opacity(0.8))
                        Text(countdownValue)
                            .font(LabFont.mono(28))
                            .foregroundStyle(.white)
                            .contentTransition(.numericText())
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(.ultraThinMaterial)
                    )
                }

                HarvestArcProgress(progress: progress)
                    .frame(height: 10)
                    .padding(.top, 4)
            }
            .padding(20)
        }
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(Color.white.opacity(0.45), lineWidth: 1)
        )
        .shadow(color: LabColor.deepTeal.opacity(0.22), radius: 24, y: 16)
        .onAppear {
            withAnimation(LabTheme.Motion.float) { drift = true }
            withAnimation(.linear(duration: 6).repeatForever(autoreverses: false)) {
                shimmer = true
            }
        }
    }
}

struct HarvestArcProgress: View {
    let progress: Double

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.white.opacity(0.25))
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [LabColor.cyanIce, .white, LabColor.amber],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: max(8, geo.size.width * progress))
                    .shadow(color: LabColor.cyanIce.opacity(0.6), radius: 6, y: 0)
            }
        }
    }
}

struct HarvestMoldTile: View {
    let shape: IceShape
    let selected: Bool
    let action: () -> Void

    private var artName: String {
        switch shape {
        case .sphere: return "ice_sphere_hero"
        case .cube: return "ice_cubes_clear"
        case .spear: return "ice_spear"
        case .diamond: return "ice_diamond"
        }
    }

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(artName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 64, height: 64)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(selected ? LabColor.glacier : Color.white.opacity(0.5), lineWidth: selected ? 2.5 : 1)
                    )
                    .shadow(color: selected ? LabColor.glacier.opacity(0.35) : .clear, radius: 10, y: 4)

                Text(shape.title)
                    .font(LabFont.caption(12))
                    .foregroundStyle(selected ? LabColor.glacier : LabColor.inkSoft)
            }
            .padding(10)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(selected ? LabColor.glacier.opacity(0.12) : Color.white.opacity(0.45))
            )
            .scaleEffect(selected ? 1.04 : 1)
        }
        .buttonStyle(.plain)
    }
}

struct HarvestMethodRail: View {
    @Binding var method: FreezeMethod

    var body: some View {
        VStack(spacing: 8) {
            ForEach(FreezeMethod.allCases) { item in
                let selected = method == item
                Button {
                    withAnimation(LabTheme.Motion.quick) { method = item }
                } label: {
                    HStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(selected ? LabColor.glacier : LabColor.frost)
                                .frame(width: 36, height: 36)
                            Image(systemName: icon(for: item))
                                .font(.system(size: 14, weight: .bold))
                                .foregroundStyle(selected ? .white : LabColor.inkSoft)
                        }

                        VStack(alignment: .leading, spacing: 2) {
                            Text(item.title)
                                .font(LabFont.body(14))
                                .foregroundStyle(LabColor.ink)
                            Text(blurb(for: item))
                                .font(LabFont.caption(11))
                                .foregroundStyle(LabColor.inkSoft)
                                .lineLimit(1)
                        }
                        Spacer()
                        if selected {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(LabColor.glacier)
                        }
                    }
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(selected ? Color.white.opacity(0.95) : Color.white.opacity(0.4))
                            .shadow(color: selected ? LabColor.glacier.opacity(0.16) : .clear, radius: 12, y: 6)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(selected ? LabColor.glacier.opacity(0.45) : Color.clear, lineWidth: 1.2)
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func icon(for method: FreezeMethod) -> String {
        switch method {
        case .standard: return "square.grid.2x2"
        case .directional: return "arrow.down.to.line"
        case .boiledDirectional: return "flame.fill"
        }
    }

    private func blurb(for method: FreezeMethod) -> String {
        switch method {
        case .standard: return "Tray freeze · narrow harvest window"
        case .directional: return "Open-face cooler · clearer cores"
        case .boiledDirectional: return "Gas-off + directional · widest window"
        }
    }
}

struct HarvestCTAButton: View {
    let title: String
    var systemImage: String = "moon.stars.fill"
    let action: () -> Void

    var body: some View {
        IceButton(title: title, systemImage: systemImage, action: action)
    }
}

struct HarvestChecklistRow: View {
    let title: String
    let detail: String
    let index: Int
    @Binding var isOn: Bool

    var body: some View {
        Button {
            withAnimation(LabTheme.Motion.quick) { isOn.toggle() }
        } label: {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(isOn ? LabColor.glacier : Color.white.opacity(0.65))
                        .frame(width: 44, height: 44)
                        .shadow(color: isOn ? LabColor.glacier.opacity(0.3) : .clear, radius: 8, y: 4)
                    Text(isOn ? "✓" : "\(index)")
                        .font(LabFont.body(15))
                        .foregroundStyle(isOn ? .white : LabColor.inkSoft)
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(LabFont.body(15))
                        .foregroundStyle(LabColor.ink)
                        .strikethrough(isOn, color: LabColor.inkSoft)
                    Text(detail)
                        .font(LabFont.caption(11))
                        .foregroundStyle(LabColor.inkSoft)
                }
                Spacer()
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(isOn ? LabColor.glacier.opacity(0.10) : Color.white.opacity(0.55))
            )
        }
        .buttonStyle(.plain)
    }
}

struct HarvestHistoryCard: View {
    let batch: HarvestBatch

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(batch.shape == .sphere ? "sphere_in_glass" : art(for: batch.shape))
                .resizable()
                .scaledToFill()
                .frame(width: 148, height: 92)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

            Text(batch.shape.title)
                .font(LabFont.body(14))
                .foregroundStyle(LabColor.ink)
            Text(batch.status.title)
                .font(LabFont.caption(11))
                .foregroundStyle(LabColor.inkSoft)

            if let score = batch.clarityAfter {
                Text("\(score)")
                    .font(LabFont.mono(22))
                    .foregroundStyle(LabColor.glacier)
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Color.white.opacity(0.72))
                .shadow(color: LabColor.deepTeal.opacity(0.12), radius: 14, y: 8)
        )
    }

    private func art(for shape: IceShape) -> String {
        switch shape {
        case .sphere: return "ice_sphere_hero"
        case .cube: return "ice_cubes_clear"
        case .spear: return "ice_spear"
        case .diamond: return "ice_diamond"
        }
    }
}

struct HarvestBandTimeline: View {
    let progress: Double
    let band: (start: Double, end: Double)
    var animated: Bool = false
    @State private var glow = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            GeometryReader { geo in
                let width = geo.size.width
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [LabColor.frost, Color.white.opacity(0.7)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(height: 22)
                        .overlay(
                            Capsule().stroke(Color.white.opacity(0.7), lineWidth: 1)
                        )

                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [
                                    LabColor.amber.opacity(glow ? 0.85 : 0.55),
                                    LabColor.cyanIce.opacity(0.9)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: max(10, width * (band.end - band.start)), height: 22)
                        .offset(x: width * band.start)
                        .shadow(color: LabColor.amber.opacity(0.45), radius: glow ? 10 : 4, y: 0)

                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [LabColor.glacier, LabColor.deepTeal],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: max(6, width * progress), height: 22)
                        .opacity(0.55)

                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [.white, LabColor.cyanIce],
                                center: .center,
                                startRadius: 1,
                                endRadius: 14
                            )
                        )
                        .frame(width: 28, height: 28)
                        .overlay(Circle().stroke(Color.white, lineWidth: 2))
                        .shadow(color: LabColor.glacier.opacity(0.45), radius: 8, y: 2)
                        .offset(x: max(0, min(width - 28, width * progress - 14)))
                }
            }
            .frame(height: 28)

            HStack {
                Label("Freeze", systemImage: "snowflake")
                Spacer()
                Label("Harvest band", systemImage: "scissors")
                    .foregroundStyle(LabColor.amber)
            }
            .font(LabFont.caption(11))
            .foregroundStyle(LabColor.inkSoft)
        }
        .onAppear {
            guard animated else { return }
            withAnimation(LabTheme.Motion.pulse) { glow = true }
        }
    }
}
