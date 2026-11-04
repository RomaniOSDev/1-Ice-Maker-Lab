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

                LabCard {
                    VStack(alignment: .leading, spacing: LabTheme.Spacing.md) {
                        Text("Recipe inputs")
                            .font(LabFont.title(18))
                            .foregroundStyle(LabColor.ink)

                        Picker("Method", selection: $viewModel.method) {
                            ForEach(FreezeMethod.allCases) { method in
                                Text(method.title).tag(method)
                            }
                        }
                        .pickerStyle(.segmented)

                        Picker("Hardness", selection: $viewModel.hardness) {
                            ForEach(WaterHardness.allCases) { item in
                                Text(item.title).tag(item)
                            }
                        }
                        .pickerStyle(.segmented)

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
    }

    private var moldRow: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Mold")
                .font(LabFont.body(14))
            HStack(spacing: 8) {
                ForEach(IceShape.allCases) { shape in
                    let selected = viewModel.shape == shape
                    Button {
                        withAnimation(LabTheme.Motion.quick) { viewModel.shape = shape }
                    } label: {
                        Text(shape.title)
                            .font(LabFont.caption(12))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .fill(selected ? LabColor.glacier : Color.white.opacity(0.55))
                            )
                            .foregroundStyle(selected ? .white : LabColor.ink)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

}
