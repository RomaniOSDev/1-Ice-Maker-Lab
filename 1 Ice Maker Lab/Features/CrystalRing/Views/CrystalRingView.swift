//
//  CrystalRingView.swift
//  1 Ice Maker Lab
//
//  Created by Roman on 10/28/26.
//

import SwiftUI

struct CrystalRingView: View {
    @StateObject private var viewModel = CrystalRingViewModel()
    @State private var pulse = false

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: LabTheme.Spacing.lg) {
                SectionHeader(
                    title: "Crystal Ring Test",
                    subtitle: "Tap like a bartender — dense clear ice rings bright"
                )

                LabCard {
                    VStack(spacing: LabTheme.Spacing.md) {
                        ZStack {
                            Image("crystal_facet")
                                .resizable()
                                .scaledToFill()
                                .frame(width: 220, height: 220)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(LabColor.stroke, lineWidth: 2))
                                .shadow(color: LabColor.glacier.opacity(0.35), radius: 24, y: 10)
                                .scaleEffect(pulse ? 1.03 : 0.98)

                            ForEach(0..<3, id: \.self) { ring in
                                Circle()
                                    .stroke(LabColor.cyanIce.opacity(0.45 - Double(ring) * 0.12), lineWidth: 2)
                                    .frame(width: 180 + CGFloat(ring) * 36, height: 180 + CGFloat(ring) * 36)
                                    .scaleEffect(viewModel.isListening ? 1.15 + CGFloat(ring) * 0.08 : 0.85)
                                    .opacity(viewModel.isListening ? 0 : 0.7)
                                    .animation(
                                        .easeOut(duration: 0.7).delay(Double(ring) * 0.08),
                                        value: viewModel.rippleToken
                                    )
                            }

                            Text("TAP")
                                .font(LabFont.caption(12))
                                .tracking(3)
                                .foregroundStyle(.white.opacity(0.9))
                                .padding(.horizontal, 14)
                                .padding(.vertical, 6)
                                .background(Capsule().fill(LabColor.deepTeal.opacity(0.55)))
                        }
                        .onTapGesture {
                            viewModel.strike()
                            withAnimation(LabTheme.Motion.quick) { pulse.toggle() }
                        }
                        .onAppear {
                            withAnimation(LabTheme.Motion.pulse) { pulse = true }
                        }

                        Text(viewModel.densityLabel)
                            .font(LabFont.title(18))
                            .foregroundStyle(LabColor.ink)
                            .multilineTextAlignment(.center)
                            .animation(LabTheme.Motion.soft, value: viewModel.lastScore)

                        if let score = viewModel.lastScore {
                            Text("\(score)")
                                .font(LabFont.mono(44))
                                .foregroundStyle(LabColor.glacier)
                                .contentTransition(.numericText())
                        }

                        Text("Strike the ice gently with a spoon or knuckle. A long bright ring usually means low air and high density — the signature of cocktail-grade clarity.")
                            .font(LabFont.caption())
                            .foregroundStyle(LabColor.inkSoft)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                }

                if let average = viewModel.averageScore {
                    LabCard {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Session average")
                                    .font(LabFont.caption())
                                    .foregroundStyle(LabColor.inkSoft)
                                Text("\(average)")
                                    .font(LabFont.mono(28))
                                    .foregroundStyle(LabColor.ink)
                            }
                            Spacer()
                            Button("Clear") {
                                withAnimation { viewModel.clearHistory() }
                            }
                            .font(LabFont.caption())
                            .foregroundStyle(LabColor.coral)
                        }
                    }
                }

                if !viewModel.taps.isEmpty {
                    LabCard {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Recent strikes")
                                .font(LabFont.title(18))
                                .foregroundStyle(LabColor.ink)
                            ForEach(viewModel.taps.prefix(6)) { tap in
                                HStack {
                                    Image(systemName: "waveform")
                                        .foregroundStyle(LabColor.glacier)
                                    Text("Score \(tap.score)")
                                        .font(LabFont.body(14))
                                        .foregroundStyle(LabColor.ink)
                                    Spacer()
                                    Text(tap.date.formatted(date: .omitted, time: .shortened))
                                        .font(LabFont.caption(11))
                                        .foregroundStyle(LabColor.inkSoft)
                                }
                            }
                        }
                    }
                }

                HStack(spacing: 10) {
                    Image("ice_spear")
                        .resizable()
                        .scaledToFill()
                        .frame(height: 140)
                        .clipShape(RoundedRectangle(cornerRadius: LabTheme.Radius.md, style: .continuous))
                    Image("sphere_in_glass")
                        .resizable()
                        .scaledToFill()
                        .frame(height: 140)
                        .clipShape(RoundedRectangle(cornerRadius: LabTheme.Radius.md, style: .continuous))
                }

                LabCard {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Why this matters")
                            .font(LabFont.title(18))
                            .foregroundStyle(LabColor.ink)
                        Text("Bartenders often “ring” a sphere before service. Foggy ice absorbs vibration — clear dense ice sings. Pair this with your journal clarity score to calibrate molds and water.")
                            .font(LabFont.body(14))
                            .foregroundStyle(LabColor.inkSoft)
                    }
                }
            }
            .padding(.horizontal, LabTheme.Spacing.md)
            .padding(.top, LabTheme.Spacing.sm)
            .padding(.bottom, 110)
        }
    }
}
