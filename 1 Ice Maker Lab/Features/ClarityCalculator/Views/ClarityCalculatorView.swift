//
//  ClarityCalculatorView.swift
//  1 Ice Maker Lab
//
//  Created by Roman on 10/28/26.
//

import SwiftUI

struct ClarityCalculatorView: View {
    @StateObject private var viewModel = ClarityCalculatorViewModel()

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: LabTheme.Spacing.lg) {
                SectionHeader(
                    title: "Clarity Lab",
                    subtitle: "Predict optical clarity from method, boil, and water"
                )

                LabCard {
                    HStack(spacing: LabTheme.Spacing.lg) {
                        ClarityGauge(score: viewModel.result.score)
                        VStack(alignment: .leading, spacing: 10) {
                            Text(viewModel.result.label)
                                .font(LabFont.title(18))
                                .foregroundStyle(LabColor.ink)
                            Text("Impurity risk \(Int(viewModel.result.impurityRisk * 100))%")
                                .font(LabFont.caption())
                                .foregroundStyle(LabColor.inkSoft)

                            Image("freeze_vector")
                                .resizable()
                                .scaledToFill()
                                .frame(height: 72)
                                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        }
                    }
                }
                .animation(LabTheme.Motion.soft, value: viewModel.result.score)

                HStack(spacing: 10) {
                    Image("ice_diamond")
                        .resizable()
                        .scaledToFill()
                        .frame(height: 110)
                        .clipShape(RoundedRectangle(cornerRadius: LabTheme.Radius.md, style: .continuous))
                    Image("frost_macro")
                        .resizable()
                        .scaledToFill()
                        .frame(height: 110)
                        .clipShape(RoundedRectangle(cornerRadius: LabTheme.Radius.md, style: .continuous))
                }

                HarvestPanel {
                    VStack(alignment: .leading, spacing: LabTheme.Spacing.md) {
                        recipeHeader

                        HarvestMethodRail(method: $viewModel.method)

                        hardnessRail

                        IceLabeledSlider(
                            title: "Boil time",
                            valueText: "\(Int(viewModel.boiledMinutes)) min",
                            value: $viewModel.boiledMinutes,
                            range: 0...15
                        )

                        IceLabeledSlider(
                            title: "Freezer",
                            valueText: "\(Int(viewModel.freezerCelsius))°C",
                            value: $viewModel.freezerCelsius,
                            range: -30...(-5)
                        )

                        moldRow
                    }
                }

                LabCard {
                    VStack(alignment: .leading, spacing: LabTheme.Spacing.sm) {
                        Text("Guidance")
                            .font(LabFont.title(18))
                            .foregroundStyle(LabColor.ink)
                        ForEach(viewModel.result.tips, id: \.self) { tip in
                            HStack(alignment: .top, spacing: 8) {
                                Image(systemName: "sparkle")
                                    .foregroundStyle(LabColor.glacier)
                                    .padding(.top, 2)
                                Text(tip)
                                    .font(LabFont.body(14))
                                    .foregroundStyle(LabColor.inkSoft)
                            }
                        }
                    }
                }

                LabCard {
                    VStack(alignment: .leading, spacing: LabTheme.Spacing.md) {
                        Text("Chill Dilution Index")
                            .font(LabFont.title(18))
                            .foregroundStyle(LabColor.ink)
                        Text("Unique forecast: how the ice cools vs waters the drink")
                            .font(LabFont.caption())
                            .foregroundStyle(LabColor.inkSoft)

                        IceLabeledSlider(
                            title: "Drink volume",
                            valueText: "\(Int(viewModel.drinkVolumeMl)) ml",
                            value: $viewModel.drinkVolumeMl,
                            range: 40...200
                        )
                        IceLabeledSlider(
                            title: "Room temp",
                            valueText: "\(Int(viewModel.ambientCelsius))°C",
                            value: $viewModel.ambientCelsius,
                            range: 10...32,
                            accent: LabColor.amber
                        )

                        HStack(spacing: 10) {
                            MetricChip(label: "Chill", value: "\(viewModel.dilution.chillPoints)")
                            MetricChip(
                                label: "Dilution",
                                value: "\(viewModel.dilution.dilutionPercent)%",
                                accent: LabColor.amber
                            )
                            MetricChip(
                                label: "Window",
                                value: "\(viewModel.dilution.sipWindowMinutes)m",
                                accent: LabColor.cyanIce
                            )
                        }

                        Text(viewModel.dilution.verdict)
                            .font(LabFont.body(14))
                            .foregroundStyle(LabColor.ink)
                            .padding(.top, 4)
                    }
                }
            }
            .padding(.horizontal, LabTheme.Spacing.md)
            .padding(.top, LabTheme.Spacing.sm)
            .padding(.bottom, 110)
        }
        .scrollContentBackground(.hidden)
        .background(Color.clear)
    }

    private var recipeHeader: some View {
        HStack(alignment: .center, spacing: 12) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [LabColor.cyanIce, LabColor.glacier],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 42, height: 42)
                Image(systemName: "drop.fill")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.white)
            }
            .shadow(color: LabColor.glacier.opacity(0.35), radius: 8, y: 4)

            VStack(alignment: .leading, spacing: 2) {
                Text("RECIPE INPUTS")
                    .font(LabFont.caption(11))
                    .tracking(1.4)
                    .foregroundStyle(LabColor.glacier)
                Text("How this batch is made")
                    .font(LabFont.title(18))
                    .foregroundStyle(LabColor.ink)
            }
            Spacer(minLength: 0)
        }
    }

    private var hardnessRail: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Water")
                .font(LabFont.body(14))
                .foregroundStyle(LabColor.ink)
            HStack(spacing: 8) {
                ForEach(WaterHardness.allCases) { item in
                    let selected = viewModel.hardness == item
                    Button {
                        withAnimation(LabTheme.Motion.quick) { viewModel.hardness = item }
                    } label: {
                        VStack(spacing: 6) {
                            Image(systemName: hardnessIcon(item))
                                .font(.system(size: 16, weight: .semibold))
                            Text(item.title)
                                .font(LabFont.caption(12))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .foregroundStyle(selected ? LabColor.glacier : LabColor.inkSoft)
                        .background(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .fill(selected ? LabColor.glacier.opacity(0.14) : Color.white.opacity(0.45))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .stroke(selected ? LabColor.glacier.opacity(0.55) : Color.white.opacity(0.5), lineWidth: selected ? 1.4 : 1)
                        )
                        .shadow(color: selected ? LabColor.glacier.opacity(0.18) : .clear, radius: 8, y: 4)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private func hardnessIcon(_ hardness: WaterHardness) -> String {
        switch hardness {
        case .soft: return "drop"
        case .medium: return "drop.halffull"
        case .hard: return "drop.fill"
        }
    }

    private var moldRow: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Mold")
                .font(LabFont.body(14))
                .foregroundStyle(LabColor.ink)
            HStack(spacing: 8) {
                ForEach(IceShape.allCases) { shape in
                    HarvestMoldTile(shape: shape, selected: viewModel.shape == shape) {
                        withAnimation(LabTheme.Motion.quick) { viewModel.shape = shape }
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
    }

}
