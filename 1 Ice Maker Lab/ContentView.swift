//
//  ContentView.swift
//  1 Ice Maker Lab
//
//  Created by Roman on 10/28/26.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var onboarding = OnboardingStore.shared
    @State private var tab: LabTab = .harvest
    @State private var appeared = false

    var body: some View {
        ZStack {
            if onboarding.hasCompleted {
                mainShell
                    .transition(.opacity.combined(with: .scale(scale: 0.98)))
            } else {
                OnboardingView {
                    onboarding.complete()
                }
                .transition(.opacity)
            }
        }
        .animation(LabTheme.Motion.soft, value: onboarding.hasCompleted)
        .preferredColorScheme(.light)
    }

    private var mainShell: some View {
        ZStack {
            FrostBackground()

            VStack(spacing: 0) {
                header
                    .padding(.horizontal, LabTheme.Spacing.md)
                    .padding(.top, 8)
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : -12)

                TabContent(tab: tab)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .opacity(appeared ? 1 : 0)
            }

            VStack {
                Spacer()
                LabTabBar(selection: $tab)
            }
        }
        .onAppear {
            withAnimation(LabTheme.Motion.soft) {
                appeared = true
            }
        }
    }

    private var header: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 2) {
                Text(tabHeadline)
                    .font(LabFont.display(28))
                    .foregroundStyle(LabColor.ink)
                    .contentTransition(.opacity)
                Text("Cocktail ice craft tools")
                    .font(LabFont.caption())
                    .foregroundStyle(LabColor.inkSoft)
            }
            Spacer()
            Image("ice_sphere_hero")
                .resizable()
                .scaledToFill()
                .frame(width: 48, height: 48)
                .clipShape(Circle())
                .overlay(Circle().stroke(LabColor.stroke, lineWidth: 1.5))
                .shadow(color: LabColor.glacier.opacity(0.25), radius: 8, y: 4)
        }
        .animation(LabTheme.Motion.quick, value: tab)
    }

    private var tabHeadline: String {
        switch tab {
        case .harvest: return "Night Ritual"
        case .clarity: return "Optics Bench"
        case .journal: return "Lab Notes"
        case .ring: return "Acoustic Check"
        case .settings: return "Workbench"
        }
    }
}

private struct TabContent: View {
    let tab: LabTab

    var body: some View {
        Group {
            switch tab {
            case .harvest:
                HarvestRitualView()
            case .clarity:
                ClarityCalculatorView()
            case .journal:
                LabJournalView()
            case .ring:
                CrystalRingView()
            case .settings:
                SettingsView()
            }
        }
        .id(tab)
        .transition(.asymmetric(
            insertion: .move(edge: .trailing).combined(with: .opacity),
            removal: .opacity
        ))
        .animation(LabTheme.Motion.soft, value: tab)
    }
}

#Preview {
    ContentView()
}
