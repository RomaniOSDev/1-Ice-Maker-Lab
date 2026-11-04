//
//  IceButton.swift
//  1 Ice Maker Lab
//
//  Created by Roman on 10/28/26.
//

import SwiftUI

/// Faceted ice-chunk silhouette for primary actions.
struct IceChunkShape: Shape {
    func path(in rect: CGRect) -> Path {
        let w = rect.width
        let h = rect.height
        var path = Path()
        path.move(to: CGPoint(x: w * 0.08, y: h * 0.28))
        path.addLine(to: CGPoint(x: w * 0.18, y: h * 0.08))
        path.addLine(to: CGPoint(x: w * 0.72, y: h * 0.05))
        path.addLine(to: CGPoint(x: w * 0.94, y: h * 0.22))
        path.addLine(to: CGPoint(x: w * 0.98, y: h * 0.58))
        path.addLine(to: CGPoint(x: w * 0.88, y: h * 0.90))
        path.addLine(to: CGPoint(x: w * 0.42, y: h * 0.96))
        path.addLine(to: CGPoint(x: w * 0.10, y: h * 0.82))
        path.addLine(to: CGPoint(x: w * 0.02, y: h * 0.52))
        path.closeSubpath()
        return path
    }
}

/// Smaller chip / secondary ice shard.
struct IceShardShape: Shape {
    func path(in rect: CGRect) -> Path {
        let w = rect.width
        let h = rect.height
        var path = Path()
        path.move(to: CGPoint(x: w * 0.12, y: h * 0.22))
        path.addLine(to: CGPoint(x: w * 0.28, y: h * 0.06))
        path.addLine(to: CGPoint(x: w * 0.82, y: h * 0.10))
        path.addLine(to: CGPoint(x: w * 0.96, y: h * 0.38))
        path.addLine(to: CGPoint(x: w * 0.90, y: h * 0.82))
        path.addLine(to: CGPoint(x: w * 0.48, y: h * 0.96))
        path.addLine(to: CGPoint(x: w * 0.08, y: h * 0.78))
        path.addLine(to: CGPoint(x: w * 0.04, y: h * 0.42))
        path.closeSubpath()
        return path
    }
}

struct IceFacetOverlay: View {
    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            Path { path in
                path.move(to: CGPoint(x: w * 0.18, y: h * 0.08))
                path.addLine(to: CGPoint(x: w * 0.42, y: h * 0.55))
                path.addLine(to: CGPoint(x: w * 0.10, y: h * 0.82))

                path.move(to: CGPoint(x: w * 0.72, y: h * 0.05))
                path.addLine(to: CGPoint(x: w * 0.42, y: h * 0.55))
                path.addLine(to: CGPoint(x: w * 0.88, y: h * 0.90))

                path.move(to: CGPoint(x: w * 0.42, y: h * 0.55))
                path.addLine(to: CGPoint(x: w * 0.98, y: h * 0.58))
            }
            .stroke(Color.white.opacity(0.28), lineWidth: 1)

            // Specular highlight
            Ellipse()
                .fill(Color.white.opacity(0.45))
                .frame(width: w * 0.34, height: h * 0.22)
                .blur(radius: 1)
                .offset(x: -w * 0.18, y: -h * 0.22)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .padding(.top, h * 0.12)
                .padding(.leading, w * 0.16)
        }
        .allowsHitTesting(false)
    }
}

struct IceButton: View {
    let title: String
    var systemImage: String? = nil
    var enabled: Bool = true
    var compact: Bool = false
    let action: () -> Void

    @State private var pressed = false
    @State private var sparkle = false

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                if let systemImage {
                    Image(systemName: systemImage)
                        .font(.system(size: compact ? 13 : 15, weight: .bold))
                }
                Text(title)
                    .font(LabFont.button(compact ? 14 : 16))
                    .multilineTextAlignment(.center)
            }
            .foregroundStyle(enabled ? LabColor.deepTeal : LabColor.inkSoft.opacity(0.5))
            .padding(.horizontal, compact ? 22 : 28)
            .padding(.vertical, compact ? 14 : 18)
            .frame(maxWidth: compact ? nil : .infinity)
            .background {
                ZStack {
                    IceChunkShape()
                        .fill(
                            LinearGradient(
                                colors: enabled
                                    ? [
                                        Color.white.opacity(0.95),
                                        LabColor.cyanIce.opacity(0.85),
                                        LabColor.glacier.opacity(0.75)
                                    ]
                                    : [
                                        Color.white.opacity(0.5),
                                        Color.gray.opacity(0.25)
                                    ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )

                    IceChunkShape()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.55),
                                    Color.clear,
                                    LabColor.deepTeal.opacity(0.12)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )

                    IceChunkShape()
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.white,
                                    LabColor.cyanIce,
                                    LabColor.glacier.opacity(0.6)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.6
                        )

                    IceFacetOverlay()
                        .clipShape(IceChunkShape())
                        .opacity(sparkle ? 1 : 0.75)
                }
            }
            .shadow(color: LabColor.glacier.opacity(enabled ? 0.35 : 0.08), radius: pressed ? 6 : 16, y: pressed ? 3 : 10)
            .shadow(color: Color.white.opacity(0.7), radius: 1, y: -1)
            .scaleEffect(pressed ? 0.97 : 1)
        }
        .buttonStyle(.plain)
        .disabled(!enabled)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    withAnimation(.easeOut(duration: 0.12)) { pressed = true }
                }
                .onEnded { _ in
                    withAnimation(.easeOut(duration: 0.12)) { pressed = false }
                }
        )
        .onAppear {
            withAnimation(LabTheme.Motion.pulse) { sparkle = true }
        }
    }
}

struct IceChipButton: View {
    let title: String
    var filled: Bool = true
    let action: () -> Void
    @State private var pressed = false

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(LabFont.button(13))
                .foregroundStyle(filled ? LabColor.deepTeal : LabColor.ink)
                .padding(.horizontal, 18)
                .padding(.vertical, 10)
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
                                        colors: [Color.white.opacity(0.75), LabColor.frost.opacity(0.6)],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                            )
                        IceShardShape()
                            .stroke(Color.white.opacity(0.85), lineWidth: 1.2)
                    }
                }
                .shadow(color: LabColor.glacier.opacity(filled ? 0.28 : 0.1), radius: pressed ? 4 : 10, y: pressed ? 2 : 5)
                .scaleEffect(pressed ? 0.96 : 1)
        }
        .buttonStyle(.plain)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in withAnimation(.easeOut(duration: 0.1)) { pressed = true } }
                .onEnded { _ in withAnimation(.easeOut(duration: 0.1)) { pressed = false } }
        )
    }
}

struct IceButtonStyle: ButtonStyle {
    var compact: Bool = false

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(LabFont.button(compact ? 13 : 15))
            .foregroundStyle(LabColor.deepTeal)
            .padding(.horizontal, compact ? 16 : 22)
            .padding(.vertical, compact ? 10 : 14)
            .background {
                ZStack {
                    IceShardShape()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.95),
                                    LabColor.cyanIce.opacity(0.8),
                                    LabColor.glacier.opacity(0.65)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    IceShardShape()
                        .stroke(Color.white.opacity(0.9), lineWidth: 1.2)
                }
            }
            .shadow(color: LabColor.glacier.opacity(0.25), radius: configuration.isPressed ? 4 : 12, y: configuration.isPressed ? 2 : 6)
            .scaleEffect(configuration.isPressed ? 0.96 : 1)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}
