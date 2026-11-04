//
//  AnimatedIceSphere.swift
//  1 Ice Maker Lab
//
//  Created by Roman on 10/28/26.
//

import SwiftUI

struct AnimatedIceSphere: View {
    var size: CGFloat = 160
    var progress: Double = 1
    @State private var shimmer = false
    @State private var breathe = false

    var body: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color.white.opacity(0.95),
                            LabColor.cyanIce.opacity(0.55),
                            LabColor.glacier.opacity(0.35)
                        ],
                        center: .topLeading,
                        startRadius: 8,
                        endRadius: size * 0.7
                    )
                )
                .frame(width: size, height: size)
                .overlay(
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [.white, LabColor.cyanIce.opacity(0.4)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 2
                        )
                )
                .shadow(color: LabColor.glacier.opacity(0.35), radius: 24, y: 10)
                .scaleEffect(breathe ? 1.04 : 0.98)

            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    AngularGradient(
                        colors: [LabColor.cyanIce, LabColor.glacier, LabColor.cyanIce],
                        center: .center
                    ),
                    style: StrokeStyle(lineWidth: 4, lineCap: .round)
                )
                .frame(width: size + 14, height: size + 14)
                .rotationEffect(.degrees(shimmer ? 360 : 0))

            Ellipse()
                .fill(Color.white.opacity(0.55))
                .frame(width: size * 0.35, height: size * 0.18)
                .offset(x: -size * 0.18, y: -size * 0.22)
                .blur(radius: 1)
        }
        .onAppear {
            withAnimation(LabTheme.Motion.pulse) { breathe = true }
            withAnimation(.linear(duration: 8).repeatForever(autoreverses: false)) {
                shimmer = true
            }
        }
    }
}

struct ClarityGauge: View {
    let score: Int
    @State private var animated = 0.0

    var body: some View {
        ZStack {
            Circle()
                .stroke(LabColor.frost, lineWidth: 14)
            Circle()
                .trim(from: 0, to: animated)
                .stroke(
                    AngularGradient(
                        colors: [LabColor.coral, LabColor.amber, LabColor.glacier, LabColor.cyanIce],
                        center: .center
                    ),
                    style: StrokeStyle(lineWidth: 14, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
            VStack(spacing: 2) {
                Text("\(score)")
                    .font(LabFont.mono(36))
                    .foregroundStyle(LabColor.ink)
                    .contentTransition(.numericText())
                Text("CLARITY")
                    .font(LabFont.caption(10))
                    .foregroundStyle(LabColor.inkSoft)
                    .tracking(1.2)
            }
        }
        .frame(width: 140, height: 140)
        .onAppear {
            withAnimation(.spring(response: 0.9, dampingFraction: 0.75)) {
                animated = Double(score) / 100.0
            }
        }
        .onChange(of: score) { _, newValue in
            withAnimation(LabTheme.Motion.soft) {
                animated = Double(newValue) / 100.0
            }
        }
    }
}

struct PhaseTimeline: View {
    let phases: [FreezePhase]
    let elapsed: Int
    let total: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(Array(phases.enumerated()), id: \.element.id) { index, phase in
                let start = phases.prefix(index).reduce(0) { $0 + $1.seconds }
                let end = start + phase.seconds
                let active = elapsed >= start && elapsed < end
                let done = elapsed >= end

                HStack(alignment: .top, spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(done || active ? LabColor.glacier : LabColor.frost)
                            .frame(width: 12, height: 12)
                        if active {
                            Circle()
                                .stroke(LabColor.cyanIce, lineWidth: 2)
                                .frame(width: 20, height: 20)
                                .scaleEffect(active ? 1.1 : 1)
                        }
                    }
                    .padding(.top, 4)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(phase.title)
                            .font(LabFont.body(15))
                            .foregroundStyle(LabColor.ink)
                        Text(phase.detail)
                            .font(LabFont.caption(12))
                            .foregroundStyle(LabColor.inkSoft)
                        Text(format(phase.seconds))
                            .font(LabFont.caption(11))
                            .foregroundStyle(LabColor.glacier)
                    }
                    Spacer(minLength: 0)
                }
                .opacity(done ? 0.55 : 1)
                .animation(LabTheme.Motion.quick, value: elapsed)
            }
        }
    }

    private func format(_ seconds: Int) -> String {
        let m = seconds / 60
        if m >= 60 {
            return String(format: "%dh %dm", m / 60, m % 60)
        }
        return "\(m) min"
    }
}
