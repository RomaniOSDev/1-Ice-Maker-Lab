//
//  SettingsView.swift
//  1 Ice Maker Lab
//
//  Created by Roman on 10/28/26.
//

import SwiftUI
import StoreKit

struct SettingsView: View {
    @Environment(\.openURL) private var openURL
    @ObservedObject private var onboarding = OnboardingStore.shared
    @State private var heroPulse = false

    private var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "Version \(version) (\(build))"
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: LabTheme.Spacing.lg) {
                SectionHeader(
                    title: "Settings",
                    subtitle: "Support, legal, and preferences"
                )

                LabCard {
                    HStack(spacing: 14) {
                        Image("sphere_in_glass")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 88, height: 88)
                            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 18, style: .continuous)
                                    .stroke(LabColor.stroke, lineWidth: 1)
                            )
                            .scaleEffect(heroPulse ? 1.03 : 0.98)
                            .animation(LabTheme.Motion.pulse, value: heroPulse)

                        VStack(alignment: .leading, spacing: 6) {
                            Text("Craft clearer ice")
                                .font(LabFont.title(18))
                                .foregroundStyle(LabColor.ink)
                            Text("Tools for freeze timing, clarity, and lab notes.")
                                .font(LabFont.caption())
                                .foregroundStyle(LabColor.inkSoft)
                            Text(appVersion)
                                .font(LabFont.caption(11))
                                .foregroundStyle(LabColor.glacier)
                        }
                        Spacer(minLength: 0)
                    }
                }
                .onAppear { heroPulse = true }

                LabCard(padding: 0) {
                    VStack(spacing: 0) {
                        Button {
                            rateApp()
                        } label: {
                            rowLabel(
                                icon: "star.fill",
                                title: "Rate the App",
                                subtitle: "Share feedback on the App Store"
                            )
                        }
                        .buttonStyle(.plain)

                        Divider().padding(.leading, 56)

                        settingsLinkRow(
                            icon: "hand.raised.fill",
                            title: "Privacy Policy",
                            subtitle: "How your data is handled",
                            url: AppLinks.privacyPolicyURL
                        )

                        Divider().padding(.leading, 56)

                        settingsLinkRow(
                            icon: "doc.text.fill",
                            title: "Terms of Use",
                            subtitle: "Rules for using these tools",
                            url: AppLinks.termsOfUseURL
                        )

                        Divider().padding(.leading, 56)

                        Button {
                            onboarding.hasCompleted = false
                        } label: {
                            rowLabel(
                                icon: "sparkles",
                                title: "Replay intro",
                                subtitle: "Show the 3 welcome screens again"
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }

                gallery

                LabCard {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("About these tools")
                            .font(LabFont.title(18))
                            .foregroundStyle(LabColor.ink)
                        Text("Timers, clarity scores, and ring tests are lab estimates for cocktail ice craft — not laboratory instruments. Always follow safe kitchen and freezer practices.")
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

    private var gallery: some View {
        LabCard {
            VStack(alignment: .leading, spacing: 12) {
                Text("Ice gallery")
                    .font(LabFont.title(18))
                    .foregroundStyle(LabColor.ink)

                LazyVGrid(
                    columns: [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)],
                    spacing: 10
                ) {
                    galleryTile("ice_cubes_clear")
                    galleryTile("ice_diamond")
                    galleryTile("frost_macro")
                    galleryTile("ice_spear")
                    galleryTile("directional_cooler")
                    galleryTile("sphere_in_glass")
                }
            }
        }
    }

    private func galleryTile(_ name: String) -> some View {
        Color.clear
            .aspectRatio(1, contentMode: .fit)
            .overlay(
                Image(name)
                    .resizable()
                    .scaledToFill()
            )
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(LabColor.stroke, lineWidth: 1)
            )
    }

    private func rateApp() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            SKStoreReviewController.requestReview(in: windowScene)
        }
    }

    private func settingsLinkRow(
        icon: String,
        title: String,
        subtitle: String,
        url: URL
    ) -> some View {
        Button {
            openURL(url)
        } label: {
            rowLabel(icon: icon, title: title, subtitle: subtitle)
        }
        .buttonStyle(.plain)
    }

    private func rowLabel(icon: String, title: String, subtitle: String) -> some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [LabColor.glacier, LabColor.deepTeal],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 40, height: 40)
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(LabFont.body(15))
                    .foregroundStyle(LabColor.ink)
                Text(subtitle)
                    .font(LabFont.caption(12))
                    .foregroundStyle(LabColor.inkSoft)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(LabColor.inkSoft.opacity(0.7))
        }
        .padding(.horizontal, LabTheme.Spacing.md)
        .padding(.vertical, 14)
        .contentShape(Rectangle())
    }
}
