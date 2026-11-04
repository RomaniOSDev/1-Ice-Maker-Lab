//
//  HarvestRitualView.swift
//  1 Ice Maker Lab
//
//  Created by Roman on 10/28/26.
//

import SwiftUI

struct HarvestRitualView: View {
    @StateObject private var viewModel = HarvestRitualViewModel()
    @ObservedObject private var store = HarvestBatchStore.shared
    @State private var intro = false

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 22) {
                heroIntro

                if let banner = viewModel.banner {
                    Text(banner)
                        .font(LabFont.caption())
                        .foregroundStyle(LabColor.deepTeal)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(LabColor.cyanIce.opacity(0.28))
                        )
                        .transition(.opacity.combined(with: .move(edge: .top)))
                }

                if let active = store.activeBatch {
                    ActiveHarvestStage(
                        batch: active,
                        now: viewModel.now,
                        onHarvest: { viewModel.showCompleteSheet = true },
                        onCancel: { viewModel.cancelRitual() },
                        onChecklist: { viewModel.updateChecklist($0) }
                    )
                    .transition(.asymmetric(
                        insertion: .scale(scale: 0.96).combined(with: .opacity),
                        removal: .opacity
                    ))
                } else {
                    setupStage
                }

                windowOrchestraCard

                if !store.history.isEmpty {
                    historyRail
                }
            }
            .padding(.horizontal, LabTheme.Spacing.md)
            .padding(.top, 4)
            .padding(.bottom, 120)
            .opacity(intro ? 1 : 0)
            .offset(y: intro ? 0 : 18)
        }
        .scrollContentBackground(.hidden)
        .background(Color.clear)
        .animation(LabTheme.Motion.soft, value: store.activeBatch?.id)
        .onAppear {
            withAnimation(LabTheme.Motion.soft) { intro = true }
        }
        .sheet(isPresented: $viewModel.showCompleteSheet) {
            HarvestCompleteSheet(viewModel: viewModel)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
    }

    // MARK: Hero

    private var heroIntro: some View {
        ZStack(alignment: .bottomLeading) {
            Image("frost_macro")
                .resizable()
                .scaledToFill()
                .frame(height: 168)
                .overlay {
                    LinearGradient(
                        colors: [
                            LabColor.deepTeal.opacity(0.75),
                            LabColor.glacier.opacity(0.35),
                            .clear
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                }
                .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))

            VStack(alignment: .leading, spacing: 6) {
                Text("NIGHT RITUAL")
                    .font(LabFont.caption(11))
                    .tracking(2)
                    .foregroundStyle(LabColor.cyanIce)
                Text("Cut before the fog locks")
                    .font(LabFont.display(24))
                    .foregroundStyle(.white)
                Text("Directional freeze · harvest band · clear cocktail ice")
                    .font(LabFont.caption(12))
                    .foregroundStyle(.white.opacity(0.78))
            }
            .padding(20)
        }
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(Color.white.opacity(0.4), lineWidth: 1)
        )
        .shadow(color: LabColor.deepTeal.opacity(0.2), radius: 20, y: 12)
    }

    // MARK: Setup

    private var setupStage: some View {
        HarvestPanel {
            VStack(alignment: .leading, spacing: 18) {
                HStack(alignment: .firstTextBaseline) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Compose the batch")
                            .font(LabFont.title(20))
                            .foregroundStyle(LabColor.ink)
                        Text("Set start time, mold, and freeze method")
                            .font(LabFont.caption())
                            .foregroundStyle(LabColor.inkSoft)
                    }
                    Spacer()
                    Image(systemName: "moon.haze.fill")
                        .font(.system(size: 22))
                        .foregroundStyle(LabColor.glacier)
                        .padding(10)
                        .background(Circle().fill(LabColor.glacier.opacity(0.12)))
                }

                DatePicker(
                    "Freeze starts",
                    selection: $viewModel.startAt,
                    displayedComponents: [.date, .hourAndMinute]
                )
                .datePickerStyle(.compact)
                .tint(LabColor.glacier)
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color.white.opacity(0.55))
                )

                Text("Mold")
                    .font(LabFont.caption(12))
                    .foregroundStyle(LabColor.inkSoft)
                    .tracking(0.6)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(IceShape.allCases) { shape in
                            HarvestMoldTile(
                                shape: shape,
                                selected: viewModel.shape == shape
                            ) {
                                withAnimation(LabTheme.Motion.quick) {
                                    viewModel.shape = shape
                                }
                            }
                        }
                    }
                    .padding(.vertical, 2)
                }

                Text("Method")
                    .font(LabFont.caption(12))
                    .foregroundStyle(LabColor.inkSoft)
                    .tracking(0.6)

                HarvestMethodRail(method: $viewModel.method)

                HStack(spacing: 10) {
                    volumeSlider(
                        title: "Water",
                        valueText: viewModel.hardness.title,
                        content: {
                            Picker("", selection: $viewModel.hardness) {
                                ForEach(WaterHardness.allCases) { item in
                                    Text(item.title).tag(item)
                                }
                            }
                            .pickerStyle(.segmented)
                        }
                    )
                }

                IceLabeledSlider(
                    title: "Freezer",
                    valueText: "\(Int(viewModel.freezerCelsius))°C",
                    value: $viewModel.freezerCelsius,
                    range: -30...(-5)
                )

                if viewModel.method != .standard {
                    IceLabeledSlider(
                        title: "Boil",
                        valueText: "\(Int(viewModel.boiledMinutes)) min",
                        value: $viewModel.boiledMinutes,
                        range: 0...15
                    )
                }

                HarvestCTAButton(title: "Begin harvest ritual") {
                    Task { await viewModel.beginRitual() }
                }
            }
        }
    }

    // MARK: Timeline orchestra

    private var windowOrchestraCard: some View {
        let plan = viewModel.plan
        let openAt = store.activeBatch?.harvestOpenAt ?? viewModel.previewOpenAt
        let closeAt = store.activeBatch?.harvestCloseAt ?? viewModel.previewCloseAt

        return HarvestPanel(accent: LabColor.amber) {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(store.activeBatch == nil ? "Projected window" : "Live timeline")
                            .font(LabFont.title(18))
                            .foregroundStyle(LabColor.ink)
                        Text(plan.tip)
                            .font(LabFont.caption(12))
                            .foregroundStyle(LabColor.inkSoft)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    Spacer(minLength: 8)
                    Image("freeze_vector")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 64, height: 64)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .stroke(Color.white.opacity(0.6), lineWidth: 1)
                        )
                }

                HarvestBandTimeline(
                    progress: store.activeBatch?.progress(at: viewModel.now) ?? 0,
                    band: store.activeBatch?.harvestBandProgress()
                        ?? (
                            Double(plan.harvestOpenOffset) / Double(max(plan.totalFreezeSeconds, 1)),
                            Double(plan.harvestCloseOffset) / Double(max(plan.totalFreezeSeconds, 1))
                        ),
                    animated: store.activeBatch != nil
                )

                HStack(spacing: 10) {
                    deepMetric(
                        label: "Freeze",
                        value: FreezeEstimate(totalSeconds: plan.totalFreezeSeconds, phases: []).formattedDuration,
                        color: LabColor.glacier
                    )
                    deepMetric(
                        label: "Window",
                        value: plan.windowLabel,
                        color: LabColor.amber
                    )
                }

                HStack(spacing: 12) {
                    clockPill(title: "Opens", date: openAt)
                    clockPill(title: "Closes", date: closeAt)
                }
            }
        }
    }

    // MARK: History

    private var historyRail: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Past rituals")
                .font(LabFont.title(18))
                .foregroundStyle(LabColor.ink)
                .padding(.horizontal, 4)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(store.history.prefix(8)) { batch in
                        HarvestHistoryCard(batch: batch)
                    }
                }
                .padding(.vertical, 4)
            }
        }
    }

    // MARK: Helpers

    private func volumeSlider<Content: View>(
        title: String,
        valueText: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(LabFont.body(14))
                    .foregroundStyle(LabColor.ink)
                Spacer()
                Text(valueText)
                    .font(LabFont.body(14))
                    .foregroundStyle(LabColor.glacier)
            }
            content()
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.white.opacity(0.5))
        )
    }

    private func deepMetric(label: String, value: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label.uppercased())
                .font(LabFont.caption(10))
                .tracking(0.8)
                .foregroundStyle(LabColor.inkSoft)
            Text(value)
                .font(LabFont.title(17))
                .foregroundStyle(color)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(color.opacity(0.10))
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(color.opacity(0.22), lineWidth: 1)
                )
        )
    }

    private func clockPill(title: String, date: Date) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(LabFont.caption(11))
                .foregroundStyle(LabColor.inkSoft)
            Text(HarvestWindowCalculator.formatDayTime(date))
                .font(LabFont.body(13))
                .foregroundStyle(LabColor.ink)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color.white.opacity(0.55))
        )
    }
}

// MARK: - Active stage

private struct ActiveHarvestStage: View {
    let batch: HarvestBatch
    let now: Date
    let onHarvest: () -> Void
    let onCancel: () -> Void
    let onChecklist: (HarvestChecklist) -> Void

    @State private var checklist: HarvestChecklist

    init(
        batch: HarvestBatch,
        now: Date,
        onHarvest: @escaping () -> Void,
        onCancel: @escaping () -> Void,
        onChecklist: @escaping (HarvestChecklist) -> Void
    ) {
        self.batch = batch
        self.now = now
        self.onHarvest = onHarvest
        self.onCancel = onCancel
        self.onChecklist = onChecklist
        _checklist = State(initialValue: batch.checklist)
    }

    private var liveStatus: HarvestBatchStatus {
        batch.refreshedStatus(at: now)
    }

    var body: some View {
        VStack(spacing: 16) {
            HarvestHeroStage(
                progress: batch.progress(at: now),
                statusTitle: liveStatus.title,
                statusColor: statusColor,
                subtitle: "\(batch.shape.title) · \(batch.method.title)",
                countdownLabel: countdownLabel,
                countdownValue: countdownValue
            )

            if liveStatus == .harvestReady {
                HarvestPanel(accent: LabColor.amber) {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Cut checklist")
                                .font(LabFont.title(18))
                                .foregroundStyle(LabColor.ink)
                            Spacer()
                            Text("\(checklist.completedCount)/5")
                                .font(LabFont.mono(18))
                                .foregroundStyle(LabColor.amber)
                        }

                        ForEach(Array(HarvestChecklist.steps.enumerated()), id: \.offset) { index, step in
                            let keyPath = step.0
                            HarvestChecklistRow(
                                title: step.1,
                                detail: step.2,
                                index: index + 1,
                                isOn: Binding(
                                    get: { checklist[keyPath: keyPath] },
                                    set: { newValue in
                                        checklist[keyPath: keyPath] = newValue
                                        onChecklist(checklist)
                                    }
                                )
                            )
                        }

                        HarvestCTAButton(title: "Complete harvest", systemImage: "scissors") {
                            onHarvest()
                        }
                    }
                }
            } else if liveStatus == .freezing {
                HarvestPanel {
                    HStack(spacing: 14) {
                        AnimatedIceSphere(size: 76, progress: batch.progress(at: now))
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Freezing quietly")
                                .font(LabFont.title(17))
                                .foregroundStyle(LabColor.ink)
                            Text("Alerts fire when the harvest band opens. Keep the open face clear.")
                                .font(LabFont.caption())
                                .foregroundStyle(LabColor.inkSoft)
                        }
                    }
                }
            } else if liveStatus == .missed {
                HarvestPanel(accent: LabColor.coral) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Window closed")
                            .font(LabFont.title(18))
                            .foregroundStyle(LabColor.coral)
                        Text("The cloudy tip may have sealed. Log the result or start a fresh ritual.")
                            .font(LabFont.caption())
                            .foregroundStyle(LabColor.inkSoft)
                        HarvestCTAButton(title: "Log late harvest", systemImage: "pencil.and.list.clipboard") {
                            onHarvest()
                        }
                    }
                }
            }

            Button(role: .destructive, action: onCancel) {
                Text("Cancel ritual")
                    .font(LabFont.caption())
                    .foregroundStyle(LabColor.coral)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
            }
            .buttonStyle(.plain)
        }
        .onChange(of: batch.checklist) { _, newValue in
            checklist = newValue
        }
    }

    private var statusColor: Color {
        switch liveStatus {
        case .harvestReady: return LabColor.amber
        case .missed: return LabColor.coral
        default: return LabColor.cyanIce
        }
    }

    private var countdownLabel: String? {
        switch liveStatus {
        case .freezing: return "Opens in"
        case .harvestReady: return "Closes in"
        default: return nil
        }
    }

    private var countdownValue: String? {
        switch liveStatus {
        case .freezing:
            return HarvestWindowCalculator.formatCountdown(to: batch.harvestOpenAt, from: now)
        case .harvestReady:
            return HarvestWindowCalculator.formatCountdown(to: batch.harvestCloseAt, from: now)
        default:
            return nil
        }
    }
}

// MARK: - Complete sheet

private struct HarvestCompleteSheet: View {
    @ObservedObject var viewModel: HarvestRitualViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                FrostBackground()
                ScrollView {
                    VStack(spacing: LabTheme.Spacing.md) {
                        HarvestPanel {
                            VStack(alignment: .leading, spacing: 14) {
                                Text("How clear was the ice?")
                                    .font(LabFont.title(18))
                                    .foregroundStyle(LabColor.ink)

                                HStack {
                                    Text("Clarity")
                                    Spacer()
                                    Text("\(Int(viewModel.clarityAfter))")
                                        .font(LabFont.mono(28))
                                        .foregroundStyle(LabColor.glacier)
                                        .contentTransition(.numericText())
                                }
                                .font(LabFont.body(14))

                                IceSlider(value: $viewModel.clarityAfter, range: 20...99)

                                Toggle("Save to experiment journal", isOn: $viewModel.logToJournal)
                                    .tint(LabColor.glacier)

                                TextField("Harvest notes", text: $viewModel.harvestNotes, axis: .vertical)
                                    .font(LabFont.body(14))
                                    .lineLimit(3...5)
                                    .padding(12)
                                    .background(
                                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                                            .fill(Color.white.opacity(0.55))
                                    )
                            }
                        }

                        HarvestCTAButton(title: "Save harvest", systemImage: "checkmark.seal.fill") {
                            viewModel.completeHarvest()
                            dismiss()
                        }
                    }
                    .padding(LabTheme.Spacing.md)
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Complete harvest")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }
}
