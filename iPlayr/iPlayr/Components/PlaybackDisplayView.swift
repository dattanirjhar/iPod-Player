import SwiftUI
import MusicKit
import MediaPlayer

/// Shared playback display component used by both PlayerView and NowPlayingView.
/// Contains artwork, track info, progress bar, and volume scroll control.
/// Does NOT start or manage playback — callers are responsible for that.
struct PlaybackDisplayView: View {
    let isFromCoverFlow: Bool
    let showStatusBar: Bool
    var initialArtwork: Artwork? = nil

    @State private var activeArtwork: Artwork?
    @EnvironmentObject private var iPlayrController: iPlayrButtonController
    @EnvironmentObject private var playerManager: AppleMusicManager
    @State private var currentDegree: Double = 80
    @State private var currentOpacity: Double = 0
    @State private var isScaleAnimation: Bool = true
    @State private var seekTimer: Timer?
    @State private var isSeekingForward: Bool = false
    @State private var isSeekingBackward: Bool = false
    @State private var seekStartTime: Date?
    @State private var currentSeekSpeed: Double = 1.0
    @State private var volumeSlider: UISlider?

    private let initialRotation: Double = 80
    private let finalRotation: Double = 5
    private let flipDuration: Double = 0.6
    private let fadeDelay: Double = 0.3
    private let fadeDuration: Double = 0.4

    var body: some View {
        VStack(spacing: 0) {
            if showStatusBar {
                StatusBar(title: "Now Playing")
            }
            Spacer()
            VStack {
                HStack(spacing: 24) {
                    ZStack {
                        if let image = activeArtwork {
                            ArtworkImage(image, width: 150)
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 150, height: 150)
                                .reflection()
                                .rotation3DEffect(.degrees(currentDegree), axis: (x: 0, y: 1, z: 0))
                                .scaleEffect(isScaleAnimation ? 1.2 : 1)
                                .id(playerManager.currentTrack?.title ?? "")
                                .onAppear {
                                    guard isFromCoverFlow else { return }
                                    isScaleAnimation = true
                                    currentDegree = initialRotation
                                    currentOpacity = 0
                                    DispatchQueue.main.async {
                                        withAnimation(.snappy(duration: flipDuration)) {
                                            isScaleAnimation = false
                                            currentDegree = finalRotation
                                        }
                                    }
                                    DispatchQueue.main.asyncAfter(deadline: .now() + fadeDelay) {
                                        withAnimation(.easeInOut(duration: fadeDuration)) {
                                            currentOpacity = 1
                                        }
                                    }
                                }
                        } else {
                            ProgressView()
                        }
                    }
                    .frame(width: 150, height: 150)
                    .onChange(of: playerManager.currentTrack) { _, newValue in
                        if let newArtwork = newValue?.artwork {
                            activeArtwork = newArtwork
                        }
                    }

                    VStack(alignment: .leading, spacing: 0) {
                        Text(playerManager.currentTrack?.title ?? "")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.black)
                            .id(playerManager.currentTrack?.title ?? "")
                        Text(playerManager.currentTrack?.artistName ?? "")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.gray)
                            .id(playerManager.currentTrack?.artistName ?? "")
                        Text(playerManager.currentTrack?.albumTitle ?? "")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.gray)
                            .id(playerManager.currentTrack?.albumTitle ?? "")
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .opacity(currentOpacity)
                }
                .frame(height: 180)
                Spacer()
                    .frame(height: 8)
                SongProgressView()
                    .environmentObject(playerManager)
                    .opacity(currentOpacity)
                    .id(playerManager.currentTrack?.title ?? "")
                    .padding(.horizontal, -4)
            }
            .padding(.horizontal, 24)
            Spacer()
        }
        .background(Color.white)
        .frame(maxHeight: .infinity)
        .onAppear {
            if let artwork = initialArtwork {
                activeArtwork = artwork
            } else {
                activeArtwork = playerManager.currentTrack?.artwork
            }
            if !isFromCoverFlow {
                currentDegree = finalRotation
                currentOpacity = 1
                isScaleAnimation = false
            }
            setupVolumeControl()
        }
        .onDisappear {
            stopSeeking()
            iPlayrController.releaseScrollHandler()
        }
    }

    // MARK: - Volume Control

    private func setupVolumeControl() {
        let volumeView = MPVolumeView(frame: .zero)
        volumeSlider = volumeView.subviews.compactMap { $0 as? UISlider }.first

        iPlayrController.setScrollHandler { direction in
            guard let slider = volumeSlider else { return }
            let step: Float = 0.0625
            let newValue: Float
            switch direction {
            case .up:
                newValue = min(slider.value + step, 1.0)
            case .down:
                newValue = max(slider.value - step, 0.0)
            }
            slider.value = newValue
            slider.sendActions(for: .valueChanged)
        }
    }

    // MARK: - Seeking

    func startSeekingForward() {
        guard !isSeekingForward && !isSeekingBackward else { return }
        isSeekingForward = true
        seekStartTime = Date()
        currentSeekSpeed = 1.0

        seekTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            Task {
                await updateSeekSpeed()
                await playerManager.seekForward(seconds: currentSeekSpeed)
            }
        }
    }

    func startSeekingBackward() {
        guard !isSeekingForward && !isSeekingBackward else { return }
        isSeekingBackward = true
        seekStartTime = Date()
        currentSeekSpeed = 1.0

        seekTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            Task {
                await updateSeekSpeed()
                await playerManager.seekBackward(seconds: currentSeekSpeed)
            }
        }
    }

    func stopSeeking() {
        seekTimer?.invalidate()
        seekTimer = nil
        isSeekingForward = false
        isSeekingBackward = false
        seekStartTime = nil
        currentSeekSpeed = 1.0
    }

    @MainActor
    private func updateSeekSpeed() {
        guard let startTime = seekStartTime else { return }

        let elapsedTime = Date().timeIntervalSince(startTime)
        switch elapsedTime {
        case 0..<1:
            currentSeekSpeed = 1.0
        case 1..<3:
            currentSeekSpeed = 2.0
        case 3..<5:
            currentSeekSpeed = 5.0
        case 5..<10:
            currentSeekSpeed = 10.0
        default:
            currentSeekSpeed = 20.0
        }
    }
}
