//
//  LabJournalView.swift
//  1 Ice Maker Lab
//
//  Created by Roman on 10/28/26.
//

import SwiftUI

struct LabJournalView: View {
    @StateObject private var viewModel = LabJournalViewModel()
    @ObservedObject private var store = ExperimentStore.shared

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: LabTheme.Spacing.lg) {
                SectionHeader(
                    title: "Experiment Log",
                    subtitle: "Track which parameters yield the clearest ice"
                )

                if let best = store.bestClarity {
                    LabCard {
                        HStack(spacing: 14) {
                            Image("ice_sphere_hero")
                                .resizable()
                                .scaledToFill()
                                .frame(width: 72, height: 72)
                                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

                            VStack(alignment: .leading, spacing: 4) {
                                Text("Best clarity so far")
                                    .font(LabFont.caption())
                                    .foregroundStyle(LabColor.inkSoft)
                                Text("\(best.clarityScore) · \(best.clarityLabel)")
                                    .font(LabFont.title(20))
                                    .foregroundStyle(LabColor.ink)
                                Text("\(best.shape.title) · \(best.method.title)")
                                    .font(LabFont.caption())
                                    .foregroundStyle(LabColor.glacier)
                            }
                            Spacer(minLength: 0)
                        }
                    }
                }

                LabPrimaryButton(title: "Log new experiment") {
                    viewModel.showComposer = true
                }

                LazyVStack(spacing: 12) {
                    ForEach(store.experiments) { experiment in
                        ExperimentRow(experiment: experiment) {
                            withAnimation(LabTheme.Motion.quick) {
                                viewModel.delete(experiment)
                            }
                        }
                        .transition(.asymmetric(
                            insertion: .move(edge: .top).combined(with: .opacity),
                            removal: .opacity
                        ))
                    }
                }
            }
            .padding(.horizontal, LabTheme.Spacing.md)
            .padding(.top, LabTheme.Spacing.sm)
            .padding(.bottom, 110)
        }
        .sheet(isPresented: $viewModel.showComposer) {
            ExperimentComposerView(viewModel: viewModel)
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
    }
}

private struct ExperimentRow: View {
    let experiment: LabExperiment
    let onDelete: () -> Void

    var body: some View {
        LabCard {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text(experiment.shape.title)
                        .font(LabFont.title(17))
                        .foregroundStyle(LabColor.ink)
                    Spacer()
                    Text("\(experiment.clarityScore)")
                        .font(LabFont.mono(22))
                        .foregroundStyle(scoreColor)
                }

                HStack(spacing: 8) {
                    tag(experiment.method.title)
                    tag("\(Int(experiment.freezerCelsius))°C")
                    tag(experiment.hardness.title)
                    if let ring = experiment.ringScore {
                        tag("Ring \(ring)")
                    }
                }

                if !experiment.notes.isEmpty {
                    Text(experiment.notes)
                        .font(LabFont.caption())
                        .foregroundStyle(LabColor.inkSoft)
                        .lineLimit(3)
                }

                HStack {
                    Text(experiment.date.formatted(date: .abbreviated, time: .omitted))
                        .font(LabFont.caption(11))
                        .foregroundStyle(LabColor.inkSoft.opacity(0.8))
                    Spacer()
                    Button("Remove", action: onDelete)
                        .font(LabFont.caption(12))
                        .foregroundStyle(LabColor.coral)
                }
            }
        }
    }

    private var scoreColor: Color {
        switch experiment.clarityScore {
        case 85...: return LabColor.glacier
        case 65..<85: return LabColor.amber
        default: return LabColor.coral
        }
    }

    private func tag(_ text: String) -> some View {
        Text(text)
            .font(LabFont.caption(11))
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Capsule().fill(Color.white.opacity(0.6)))
            .foregroundStyle(LabColor.inkSoft)
    }
}

struct ExperimentComposerView: View {
    @ObservedObject var viewModel: LabJournalViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                FrostBackground()
                ScrollView {
                    VStack(spacing: LabTheme.Spacing.md) {
                        LabCard {
                            VStack(alignment: .leading, spacing: 12) {
                                pickerRow("Mold", selection: $viewModel.draftShape, options: IceShape.allCases) { $0.title }
                                pickerRow("Hardness", selection: $viewModel.draftHardness, options: WaterHardness.allCases) { $0.title }
                                pickerRow("Method", selection: $viewModel.draftMethod, options: FreezeMethod.allCases) { $0.title }

                                slider("Freezer", "\(Int(viewModel.draftFreezer))°C", $viewModel.draftFreezer, -30...(-5))
                                slider("Boil", "\(Int(viewModel.draftBoil)) min", $viewModel.draftBoil, 0...15)
                                slider("Clarity", "\(Int(viewModel.draftClarity))", $viewModel.draftClarity, 10...99)

                                Toggle("Include crystal ring score", isOn: $viewModel.includeRing)
                                    .tint(LabColor.glacier)
                                if viewModel.includeRing {
                                    slider("Ring", "\(Int(viewModel.draftRing))", $viewModel.draftRing, 20...99)
                                }

                                TextField("Notes (technique, harvest tip…)", text: $viewModel.draftNotes, axis: .vertical)
                                    .font(LabFont.body(14))
                                    .lineLimit(3...5)
                            }
                        }

                        LabPrimaryButton(title: "Save experiment") {
                            viewModel.saveDraft()
                        }
                    }
                    .padding(LabTheme.Spacing.md)
                }
            }
            .navigationTitle("New entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }

    private func pickerRow<T: Hashable & Identifiable>(
        _ title: String,
        selection: Binding<T>,
        options: [T],
        label: @escaping (T) -> String
    ) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(LabFont.caption())
                .foregroundStyle(LabColor.inkSoft)
            Picker(title, selection: selection) {
                ForEach(options) { option in
                    Text(label(option)).tag(option)
                }
            }
            .pickerStyle(.segmented)
        }
    }

    private func slider(
        _ title: String,
        _ valueText: String,
        _ value: Binding<Double>,
        _ range: ClosedRange<Double>
    ) -> some View {
        IceLabeledSlider(title: title, valueText: valueText, value: value, range: range)
    }
}
