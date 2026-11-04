//
//  FrostBackground.swift
//  1 Ice Maker Lab
//
//  Created by Roman on 10/28/26.
//

import SwiftUI

struct FrostBackground: View {
    @State private var drift = false

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    LabColor.mist,
                    Color(red: 0.78, green: 0.88, blue: 0.98),
                    LabColor.frost
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            Circle()
                .fill(LabColor.cyanIce.opacity(0.35))
                .frame(width: 280, height: 280)
                .blur(radius: 55)
                .offset(x: drift ? 40 : -30, y: drift ? -120 : -80)

            Circle()
                .fill(LabColor.glacier.opacity(0.18))
                .frame(width: 220, height: 220)
                .blur(radius: 45)
                .offset(x: drift ? -50 : 60, y: drift ? 220 : 180)

            FloatingShards()
        }
        .ignoresSafeArea()
        .onAppear {
            withAnimation(LabTheme.Motion.float) {
                drift = true
            }
        }
    }
}

private struct FloatingShards: View {
    var body: some View {
        GeometryReader { geo in
            ForEach(0..<7, id: \.self) { index in
                ShardDot(index: index, size: geo.size)
            }
        }
        .allowsHitTesting(false)
    }
}

private struct ShardDot: View {
    let index: Int
    let size: CGSize
    @State private var rising = false

    var body: some View {
        let x = CGFloat((index * 47) % 100) / 100 * size.width
        let baseY = CGFloat((index * 73) % 100) / 100 * size.height
        Circle()
            .fill(Color.white.opacity(0.45))
            .frame(width: CGFloat(6 + index % 4), height: CGFloat(6 + index % 4))
            .offset(x: x - size.width / 2, y: rising ? baseY - 30 : baseY)
            .animation(
                .easeInOut(duration: 2.2 + Double(index) * 0.25)
                .repeatForever(autoreverses: true)
                .delay(Double(index) * 0.15),
                value: rising
            )
            .onAppear { rising = true }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
