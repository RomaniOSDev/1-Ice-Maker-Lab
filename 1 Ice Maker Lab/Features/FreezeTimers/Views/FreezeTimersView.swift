//
//  FreezeTimersView.swift
//  1 Ice Maker Lab
//
//  Created by Roman on 10/28/26.
//

import SwiftUI

struct FreezeTimersView: View {
    @StateObject private var viewModel = FreezeTimersViewModel()

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: LabTheme.Spacing.lg) {
                SectionHeader(
                    title: "Freeze Timeline",
                    subtitle: "Phased timers tuned to freezer, mold, and water"
                )

                LabCard {
                    HStack(spacing: LabTheme.Spacing.md) {
                        AnimatedIceSphere(size: 120, progress: viewModel.progress)
                        VStack(alignment: .leading, spacing: 8) {
                            Text(viewModel.remainingText)
                                .font(LabFont.mono(28))
                                .foregroundStyle(LabColor.ink)
                                .contentTransition(.numericText())
                            Text(viewModel.estimate.formattedDuration + " total")
                                .font(LabFont.caption())
                                .foregroundStyle(LabColor.inkSoft)
                            HStack(spacing: 8) {
                                Button(viewModel.isRunning ? "Pause" : "Start") {
                                    viewModel.toggle()
                                }
                                .buttonStyle(ChipButtonStyle(filled: true))

                                Button("Reset") {
                                    viewModel.reset()
                                }
                                .buttonStyle(ChipButtonStyle(filled: false))
                            }
                        }
                        Spacer(minLength: 0)
                    }
                }

                LabCard {
                    VStack(alignment: .leading, spacing: LabTheme.Spacing.md) {
                        Text("Parameters")
                            .font(LabFont.title(18))
                            .foregroundStyle(LabColor.ink)

                        IceLabeledSlider(
                            title: "Freezer",
                            valueText: "\(Int(viewModel.freezerCelsius))°C",
                            value: $viewModel.freezerCelsius,
                            range: -30...(-5)
                        )

                        shapePicker
                        hardnessPicker

                        Toggle(isOn: $viewModel.directional) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Directional freeze")
                                    .font(LabFont.body(14))
                                Text("Open-face cooler / insulated method")
                                    .font(LabFont.caption(12))
                                    .foregroundStyle(LabColor.inkSoft)
                            }
                        }
                        .tint(LabColor.glacier)
                    }
                }
                .onChange(of: viewModel.freezerCelsius) { _, _ in viewModel.recalculate() }
                .onChange(of: viewModel.shape) { _, _ in viewModel.recalculate() }
                .onChange(of: viewModel.hardness) { _, _ in viewModel.recalculate() }
                .onChange(of: viewModel.directional) { _, _ in viewModel.recalculate() }

                LabCard {
                    VStack(alignment: .leading, spacing: LabTheme.Spacing.sm) {
                        Text("Phases")
                            .font(LabFont.title(18))
                            .foregroundStyle(LabColor.ink)
                        PhaseTimeline(
                            phases: viewModel.estimate.phases,
                            elapsed: viewModel.elapsedSeconds,
                            total: viewModel.estimate.totalSeconds
                        )
                    }
                }

                HStack(spacing: 10) {
                    Image("mold_shapes")
                        .resizable()
                        .scaledToFill()
                        .frame(height: 120)
                        .clipShape(RoundedRectangle(cornerRadius: LabTheme.Radius.md, style: .continuous))
                    Image("directional_cooler")
                        .resizable()
                        .scaledToFill()
                        .frame(height: 120)
                        .clipShape(RoundedRectangle(cornerRadius: LabTheme.Radius.md, style: .continuous))
                }

                Image("ice_cubes_clear")
                    .resizable()
                    .scaledToFill()
                    .frame(height: 150)
                    .clipShape(RoundedRectangle(cornerRadius: LabTheme.Radius.md, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: LabTheme.Radius.md, style: .continuous)
                            .stroke(LabColor.stroke, lineWidth: 1)
                    )
            }
            .padding(.horizontal, LabTheme.Spacing.md)
            .padding(.top, LabTheme.Spacing.sm)
            .padding(.bottom, 110)
        }
    }

    private var shapePicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Mold")
                .font(LabFont.body(14))
                .foregroundStyle(LabColor.ink)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(IceShape.allCases) { shape in
                        let selected = viewModel.shape == shape
                        Button {
                            withAnimation(LabTheme.Motion.quick) { viewModel.shape = shape }
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: shape.symbolName)
                                Text(shape.title)
                            }
                            .font(LabFont.caption(13))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(
                                Capsule().fill(selected ? LabColor.glacier : Color.white.opacity(0.55))
                            )
                            .foregroundStyle(selected ? .white : LabColor.ink)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    private var hardnessPicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Water hardness")
                .font(LabFont.body(14))
                .foregroundStyle(LabColor.ink)
            Picker("Hardness", selection: $viewModel.hardness) {
                ForEach(WaterHardness.allCases) { item in
                    Text(item.title).tag(item)
                }
            }
            .pickerStyle(.segmented)
        }
    }
}

struct ChipButtonStyle: ButtonStyle {
    var filled: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(LabFont.button(13))
            .padding(.horizontal, 18)
            .padding(.vertical, 10)
            .foregroundStyle(filled ? LabColor.deepTeal : LabColor.ink)
            .background {
                ZStack {
                    IceShardShape()
                        .fill(
                            filled
                                ? LinearGradient(
                                    colors: [Color.white, LabColor.cyanIce.opacity(0.9), LabColor.glacier.opacity(0.7)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                                : LinearGradient(
                                    colors: [Color.white.opacity(0.8), LabColor.frost.opacity(0.55)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                        )
                    IceShardShape()
                        .stroke(Color.white.opacity(0.9), lineWidth: 1.2)
                }
            }
            .shadow(color: LabColor.glacier.opacity(0.22), radius: configuration.isPressed ? 4 : 10, y: configuration.isPressed ? 2 : 5)
            .scaleEffect(configuration.isPressed ? 0.96 : 1)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}
