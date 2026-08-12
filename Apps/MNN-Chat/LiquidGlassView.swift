import SwiftUI
import UIKit

struct VisualEffectBlur: UIViewRepresentable {
    let effect: UIBlurEffect.Style
    func makeUIView(context: Context) -> UIVisualEffectView {
        UIVisualEffectView(effect: UIBlurEffect(style: effect))
    }
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {}
}

struct GlassCard<Content: View>: View {
    var content: Content
    init(@ViewBuilder _ content: () -> Content) { self.content = content() }
    var body: some View {
        ZStack {
            VisualEffectBlur(effect: .systemUltraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.06), lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.18), radius: 8, x: 0, y: 6)
            content
                .padding(8)
        }
    }
}

struct LiquidGlassView: View {
    @State private var phase: Double = 0
    @Environment(\._colorScheme) private var colorScheme

    var body: some View {
        TimelineView(.animation) { timeline in
            Canvas { context, size in
                let t = timeline.date.timeIntervalSinceReferenceDate
                // draw simple moving blobs
                let colors = [Color.white.opacity(colorScheme == .dark ? 0.06 : 0.12), Color.blue.opacity(0.08)]
                for i in 0..<6 {
                    let progress = t * (0.2 + Double(i) * 0.03)
                    let x = size.width * (0.2 + 0.6 * sin(progress + Double(i)))
                    let y = size.height * (0.3 + 0.4 * cos(progress * 0.8 + Double(i)))
                    let r = 60 + CGFloat(30 * sin(progress + Double(i)))
                    var circle = Path()
                    circle.addEllipse(in: CGRect(x: x - r/2, y: y - r/2, width: r, height: r))
                    context.fill(circle, with: .color(colors[i % colors.count]))
                }
                // apply blur by drawing into a layer and blurring - Canvas has filters in iOS 17+, keep simple
            }
            .compositingGroup()
            .blur(radius: 18)
            .background(VisualEffectBlur(effect: .systemUltraThinMaterial))
        }
    }
}
