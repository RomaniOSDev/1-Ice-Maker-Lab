//
//  LabTabBar.swift
//  1 Ice Maker Lab
//
//  Created by Roman on 10/28/26.
//

import SwiftUI

enum LabTab: Int, CaseIterable, Identifiable {
    case harvest
    case clarity
    case journal
    case ring
    case settings

    var id: Int { rawValue }

    var title: String {
        switch self {
        case .harvest: return "Harvest"
        case .clarity: return "Clarity"
        case .journal: return "Journal"
        case .ring: return "Ring"
        case .settings: return "Settings"
        }
    }

    var symbol: String {
        switch self {
        case .harvest: return "moon.stars.fill"
        case .clarity: return "drop.fill"
        case .journal: return "book.closed.fill"
        case .ring: return "waveform.circle.fill"
        case .settings: return "gearshape.fill"
        }
    }
}

struct LabTabBar: View {
    @Binding var selection: LabTab
    @Namespace private var iceGlow
    @State private var shimmer = false

    var body: some View {
        HStack(spacing: 2) {
            ForEach(LabTab.allCases) { tab in
                iceTab(tab)
            }
        }
        .padding(.horizontal, 8)
        .padding(.top, 10)
        .padding(.bottom, 10)
        .background {
            ZStack {
                // Ice shelf base
                RoundedRectangle(cornerRadius: 30, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.88),
                                LabColor.frost.opacity(0.92),
                                Color(red: 0.78, green: 0.90, blue: 1.0).opacity(0.95)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )

                RoundedRectangle(cornerRadius: 30, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.white,
                                LabColor.cyanIce.opacity(0.7),
                                LabColor.glacier.opacity(0.35)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.5
                    )

                // Top frost highlight
                RoundedRectangle(cornerRadius: 30, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [Color.white.opacity(0.55), Color.clear],
                            startPoint: .top,
                            endPoint: .center
                        )
                    )
                    .padding(1)
                    .opacity(shimmer ? 1 : 0.7)
            }
            .shadow(color: LabColor.glacier.opacity(0.22), radius: 22, y: 10)
            .shadow(color: LabColor.deepTeal.opacity(0.10), radius: 6, y: 2)
        }
        .padding(.horizontal, LabTheme.Spacing.md)
        .padding(.bottom, 8)
        .onAppear {
            withAnimation(LabTheme.Motion.pulse) { shimmer = true }
        }
    }

    private func iceTab(_ tab: LabTab) -> some View {
        let selected = selection == tab
        return Button {
            withAnimation(LabTheme.Motion.quick) {
                selection = tab
            }
        } label: {
            VStack(spacing: 5) {
                ZStack {
                    if selected {
                        IceShardShape()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.white,
                                        LabColor.cyanIce,
                                        LabColor.glacier.opacity(0.85)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 46, height: 36)
                            .overlay(
                                IceShardShape()
                                    .stroke(Color.white.opacity(0.95), lineWidth: 1.2)
                            )
                            .shadow(color: LabColor.glacier.opacity(0.4), radius: 10, y: 4)
                            .matchedGeometryEffect(id: "iceTabPedestal", in: iceGlow)
                    }

                    Image(systemName: tab.symbol)
                        .font(.system(size: selected ? 17 : 16, weight: .bold))
                        .foregroundStyle(selected ? LabColor.deepTeal : LabColor.inkSoft)
                        .symbolEffect(.bounce, value: selected)
                        .frame(height: 28)
                }
                .frame(height: 36)

                Text(tab.title)
                    .font(LabFont.caption(10))
                    .foregroundStyle(selected ? LabColor.deepTeal : LabColor.inkSoft)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 4)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
