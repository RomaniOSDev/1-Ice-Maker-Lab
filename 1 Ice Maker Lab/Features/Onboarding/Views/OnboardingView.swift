//
//  OnboardingView.swift
//  1 Ice Maker Lab
//
//  Created by Roman on 10/28/26.
//

import SwiftUI

struct OnboardingView: View {
    var onFinished: () -> Void

    @State private var page = 0
    @State private var appeared = false
    @State private var drift = false

    private let pages = OnboardingPage.pages

    var body: some View {
        ZStack {
            FrostBackground()

            // Soft floating orb accents
            Circle()
                .fill(LabColor.cyanIce.opacity(0.28))
                .frame(width: 220, height: 220)
                .blur(radius: 40)
                .offset(x: drift ? 90 : 50, y: drift ? -180 : -140)

            VStack(spacing: 0) {
                HStack {
                    Spacer()
                    if page < pages.count - 1 {
                        Button("Skip") {
                            finish()
                        }
                        .font(LabFont.button(14))
                        .foregroundStyle(LabColor.inkSoft)
                        .padding(.trailing, 4)
                    }
                }
                .padding(.horizontal, LabTheme.Spacing.md)
                .padding(.top, 8)
                .opacity(appeared ? 1 : 0)

                TabView(selection: $page) {
                    ForEach(pages) { item in
                        OnboardingPageCard(page: item, isActive: page == item.id)
                            .tag(item.id)
                            .padding(.horizontal, LabTheme.Spacing.md)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(LabTheme.Motion.soft, value: page)

                VStack(spacing: 18) {
                    IcePageIndicator(count: pages.count, index: page)

                    if page < pages.count - 1 {
                        IceButton(title: "Continue", systemImage: "arrow.right") {
                            withAnimation(LabTheme.Motion.soft) {
                                page += 1
                            }
                        }
                    } else {
                        IceButton(title: "Start crafting", systemImage: "sparkles") {
                            finish()
                        }
                    }
                }
                .padding(.horizontal, LabTheme.Spacing.lg)
                .padding(.bottom, 28)
                .opacity(appeared ? 1 : 0)
            }
        }
        .preferredColorScheme(.light)
        .onAppear {
            withAnimation(LabTheme.Motion.soft) { appeared = true }
            withAnimation(LabTheme.Motion.float) { drift = true }
        }
    }

    private func finish() {
        withAnimation(LabTheme.Motion.soft) {
            onFinished()
        }
    }
}

private struct OnboardingPageCard: View {
    let page: OnboardingPage
    let isActive: Bool
    @State private var lift = false

    var body: some View {
        VStack(spacing: 22) {
            ZStack {
                RoundedRectangle(cornerRadius: 32, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.55),
                                LabColor.frost.opacity(0.4)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(height: 360)
                    .shadow(color: LabColor.glacier.opacity(0.2), radius: 24, y: 14)

                Image(page.imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity)
                    .frame(height: 360)
                    .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 32, style: .continuous)
                            .stroke(
                                LinearGradient(
                                    colors: [.white, LabColor.cyanIce.opacity(0.6)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1.5
                            )
                    )
                    .overlay(alignment: .bottom) {
                        LinearGradient(
                            colors: [.clear, LabColor.deepTeal.opacity(0.45)],
                            startPoint: .center,
                            endPoint: .bottom
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
                    }
                    .scaleEffect(lift && isActive ? 1.02 : 0.98)
            }

            VStack(alignment: .leading, spacing: 10) {
                Text(page.eyebrow.uppercased())
                    .font(LabFont.caption(11))
                    .tracking(1.6)
                    .foregroundStyle(LabColor.glacier)

                Text(page.title)
                    .font(LabFont.display(30))
                    .foregroundStyle(LabColor.ink)
                    .fixedSize(horizontal: false, vertical: true)

                Text(page.body)
                    .font(LabFont.body(15))
                    .foregroundStyle(LabColor.inkSoft)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 4)

            Spacer(minLength: 0)
        }
        .onChange(of: isActive) { _, active in
            withAnimation(LabTheme.Motion.pulse) { lift = active }
        }
        .onAppear {
            if isActive {
                withAnimation(LabTheme.Motion.pulse) { lift = true }
            }
        }
    }
}

private struct IcePageIndicator: View {
    let count: Int
    let index: Int

    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<count, id: \.self) { i in
                Capsule()
                    .fill(
                        i == index
                            ? LinearGradient(
                                colors: [Color.white, LabColor.cyanIce, LabColor.glacier],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                            : LinearGradient(
                                colors: [LabColor.frost, LabColor.frost],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                    )
                    .frame(width: i == index ? 28 : 10, height: 8)
                    .overlay(
                        Capsule().stroke(Color.white.opacity(0.7), lineWidth: 0.8)
                    )
                    .shadow(color: i == index ? LabColor.glacier.opacity(0.35) : .clear, radius: 6, y: 2)
                    .animation(LabTheme.Motion.quick, value: index)
            }
        }
    }
}

#Preview {
    OnboardingView(onFinished: {})
}
