import SwiftUI

struct ContentView: View {
    @State private var count = 0
    @State private var pulse = false

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(red: 0.05, green: 0.06, blue: 0.10),
                         Color(red: 0.10, green: 0.05, blue: 0.16)],
                startPoint: .topLeading, endPoint: .bottomTrailing
            ).ignoresSafeArea()

            VStack(spacing: 28) {
                Text("SUPERPANDORA")
                    .font(.system(size: 30, weight: .heavy, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(colors: [.cyan, .purple],
                                       startPoint: .leading, endPoint: .trailing)
                    )

                Text("built on GitHub Actions macOS runner")
                    .font(.footnote)
                    .foregroundStyle(.white.opacity(0.55))

                ZStack {
                    Circle()
                        .fill(Color.cyan.opacity(pulse ? 0.28 : 0.12))
                        .frame(width: 200, height: 200)
                        .scaleEffect(pulse ? 1.08 : 0.95)
                    Circle()
                        .strokeBorder(Color.cyan.opacity(0.5), lineWidth: 1)
                        .frame(width: 200, height: 200)
                    Text("\(count)")
                        .font(.system(size: 64, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .contentTransition(.numericText())
                }
                .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: pulse)
                .onAppear { pulse = true }

                Button {
                    withAnimation(.snappy) { count += 1 }
                } label: {
                    Text("TAP")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.cyan)
                        .foregroundStyle(.black)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .padding(.horizontal, 48)

                Spacer().frame(height: 8)

                Text("unsigned build \u{00B7} no Apple account needed")
                    .font(.caption2)
                    .foregroundStyle(.white.opacity(0.35))
            }
            .padding()
        }
    }
}

#Preview { ContentView() }
