import SwiftUI
import MusicKit

struct iPlayrView: View {
    @StateObject private var iPlayrController: iPlayrButtonController = .init()
    @StateObject private var navigationManager: NavigationManager = .init()
    @EnvironmentObject private var theme: ThemeManager
    @EnvironmentObject private var playerManager: AppleMusicManager

    var body: some View {
        GeometryReader { mainGeo in
            let width = mainGeo.size.width
            let screenMargin = width * 0.08
            let screenWidth = width - (screenMargin * 2)
            // 4:3 Aspect Ratio for the screen
            let screenHeight: CGFloat = 300
            let wheelSize = width * 0.79
            
            // Calculate a comfortable gap. It should optically balance the top/side margins.
            let verticalGap = screenMargin * 1.5

            VStack(spacing: 0) {
                Spacer() // Pushes everything down to visually center in the faceplate
                
                iPlayrScreen(width: screenWidth, height: screenHeight)
                    .environmentObject(iPlayrController)
                    .environmentObject(navigationManager)
                    .environmentObject(theme)
                
                Spacer()
                    .frame(height: verticalGap)
                
                iPlayrButtons()
                    .environmentObject(iPlayrController)
                    .environmentObject(theme)
                    // We don't frame the buttons here because iPodButtons has its own GeometryReader 
                    // which uses width, but since it's in a VStack, it will expand to the width 
                    // of its container. We can constrain it to the same width as the screen or chassis.
                    // iPodButtons uses geometry.size.width natively.
                    .frame(width: width, height: wheelSize * 1.1)
                
                Spacer()
            }
            .background(
                ChassisBackgroundView(theme: theme.currentTheme)
            )
            .onAppear {
                iPlayrController.setGlobalPlaybackHandler { action in
                    Task {
                        switch action {
                        case .playPause: try? await playerManager.togglePlayPause()
                        case .forwardEndAlt: try? await playerManager.skipToNextTrack()
                        case .backwardEndAlt: try? await playerManager.skipToPreviousTrack()
                        default: break
                        }
                    }
                }
            }
        }
    }
}

struct ChassisBackgroundView: View {
    let theme: PodTheme
    
    var body: some View {
        ZStack {
            // Chassis rendering
            ZStack {
                // 1. Linear gradient
                LinearGradient(
                    gradient: Gradient(colors: [theme.chassisTop, theme.chassisMid, theme.chassisBottom]),
                    startPoint: .top,
                    endPoint: .bottom
                )
            
                // 2. Radial highlight bloom near top edge
                GeometryReader { geo in
                    RadialGradient(
                        gradient: Gradient(colors: [theme.chassisHighlight.opacity(theme.sheen * 0.8), .clear]),
                        center: .top,
                        startRadius: 10,
                        endRadius: geo.size.width * 0.8
                    )
                }
                
                // 3. Diagonal glossy streak
                GeometryReader { geo in
                    Path { path in
                        path.move(to: CGPoint(x: 0, y: geo.size.height * 0.1))
                        path.addLine(to: CGPoint(x: geo.size.width, y: geo.size.height * 0.6))
                        path.addLine(to: CGPoint(x: geo.size.width, y: geo.size.height * 0.7))
                        path.addLine(to: CGPoint(x: 0, y: geo.size.height * 0.2))
                        path.closeSubpath()
                    }
                    .fill(LinearGradient(
                        gradient: Gradient(colors: [.clear, theme.chassisHighlight.opacity(theme.sheen * 0.2), .clear]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 40, style: .continuous))
            .overlay(
                // 4. 1px light rim
                RoundedRectangle(cornerRadius: 40, style: .continuous)
                    .stroke(theme.chassisHighlight.opacity(0.5), lineWidth: 1)
            )
            // 5. Drop shadow
            .shadow(color: .black.opacity(0.5), radius: 20, x: 0, y: 10)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            // Background behind the chassis shadow
            .background(Color.black.ignoresSafeArea())
        }
    }
}
