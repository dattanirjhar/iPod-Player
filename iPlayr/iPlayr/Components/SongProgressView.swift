import SwiftUI

struct SongProgressView: View {
    @State var progress: Double = 0
    @EnvironmentObject private var playerManager: AppleMusicManager
    @State private var visualProgress: Double = 0
    @State private var timer: Timer?

    private var currentDuration: TimeInterval {
        playerManager.currentTrack?.duration ?? 0
    }

    var body: some View {
        HStack(spacing: 0) {
            Text(formattedTime(from: Int(visualProgress * currentDuration)))
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(.black)
                .frame(width: 50)
                .multilineTextAlignment(.trailing)
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color(.white).gradient.shadow(.inner(color: .black.opacity(0.1), radius: 10, x: 0, y: -2)))
                        .frame(height: 18)
                    Rectangle()
                        .fill(Color(.white).gradient.shadow(.inner(color: .black.opacity(0.2), radius: 10, x: 0, y: 2)))
                        .frame(height: 18)
                    Rectangle()
                        .fill(Color(.systemBlue).gradient.shadow(.inner(color: .white.opacity(0.2), radius: 8, x: 0, y: -4)))
                        .frame(width: geo.size.width * CGFloat(visualProgress), height: 18)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: 18)
            .padding(8)

            Text("-\(formattedTime(from: Int(currentDuration - (visualProgress * currentDuration))))")
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(.black)
                .frame(width: 50)
                .multilineTextAlignment(.leading)
        }
        .frame(maxWidth: .infinity)
        .onAppear(perform: startVisualTimer)
        .onDisappear {
            timer?.invalidate()
            timer = nil
        }
        .onChange(of: currentDuration) { oldValue, newValue in
            if abs(oldValue - newValue) > 1 {
                progress = 0
                visualProgress = 0
                startVisualTimer()
            }
        }
        .onChange(of: playerManager.isPlaying) { _, isPlaying in
            if isPlaying {
                startVisualTimer()
            } else {
                timer?.invalidate()
                timer = nil
            }
        }
        .onChange(of: playerManager.currentTrack?.title) { _, _ in
            progress = 0
            visualProgress = 0
            timer?.invalidate()
            timer = nil
            if playerManager.isPlaying {
                startVisualTimer()
            }
        }
    }

    @MainActor private func startVisualTimer() {
        timer?.invalidate()
        timer = nil

        guard currentDuration > 0 else { return }

        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            Task { @MainActor in
                if playerManager.isPlaying {
                    let currentTime = playerManager.currentPlaybackTime
                    visualProgress = min(1.0, currentTime / currentDuration)
                }
            }
        }
    }

    private func formattedTime(from seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%02d:%02d", minutes, remainingSeconds)
    }
}
