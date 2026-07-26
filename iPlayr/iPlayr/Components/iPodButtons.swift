import SwiftUI

struct iPlayrButtons: View {
    @State private var lastAngle: CGFloat? = nil
    @State private var counter: CGFloat = 0
    @EnvironmentObject private var buttonController: iPlayrButtonController
    @EnvironmentObject private var theme: ThemeManager
    @State private var isCenterPressed: Bool = false
    
    var body: some View {
        GeometryReader { geometry in
            let size = geometry.size.width
            let buttonOffset = size * 0.32
            
            ZStack {
                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                gradient: Gradient(colors: [theme.currentTheme.wheelLight, theme.currentTheme.wheelDark]),
                                center: UnitPoint(x: 0.5, y: 0.3),
                                startRadius: 0,
                                endRadius: size * 0.4
                            )
                        )
                }
                .overlay(
                    Circle()
                        .fill(Color.clear.shadow(.inner(color: .black.opacity(0.4), radius: 6, x: 0, y: 4)).shadow(.inner(color: theme.currentTheme.wheelHighlight.opacity(theme.currentTheme.sheen * 0.8), radius: 4, x: 0, y: -4)))
                )
                .overlay(
                    Circle().stroke(theme.currentTheme.wheelHighlight.opacity(theme.currentTheme.sheen * 0.5), lineWidth: 0.5)
                )
                    .frame(width: size * 0.79, height: size * 0.79)
                    .gesture(dragGesture(in: size))

                // Center button — tap: select, long press (0.7s): selectLongPress
                Circle()
                    .fill(
                        RadialGradient(
                            gradient: Gradient(colors: [theme.currentTheme.centerLight, theme.currentTheme.centerDark]),
                            center: isCenterPressed ? UnitPoint(x: 0.5, y: 0.7) : UnitPoint(x: 0.5, y: 0.3),
                            startRadius: 0,
                            endRadius: size * 0.15
                        )
                    )
                    .shadow(color: .black.opacity(0.4), radius: 2, x: 0, y: isCenterPressed ? 0 : 3)
                    .frame(width: size * 0.29, height: size * 0.29)
                    .contentShape(Circle())
                    .onTapGesture { buttonController.selectButtonPressed() }
                    .onLongPressGesture(minimumDuration: 0.7, maximumDistance: 50,
                                        pressing: { pressing in
                                            withAnimation(.easeInOut(duration: 0.1)) {
                                                isCenterPressed = pressing
                                            }
                                        },
                                        perform: { buttonController.selectLongPressed() })

                // Menu button — tap: menu, long press (0.8s): menuLongPress
                iPlayrMenuButton(theme: theme) {
                    buttonController.menuButtonPressed()
                } onLongPress: {
                    buttonController.menuLongPressed()
                }
                .offset(y: -buttonOffset)

                makeIconButton(imageName: ImageNames.System.playPause, offsetY: buttonOffset) {
                    buttonController.playPauseButtonPressed()
                } onLongPress: {
                    buttonController.playPauseLongPressed()
                }

                makeSeekButton(imageName: ImageNames.System.forwardEndAlt, offsetX: buttonOffset,
                             onTap: { buttonController.forwardEndAltButtonPressed() },
                             onLongPressStart: { buttonController.forwardLongPressStarted() },
                             onLongPressEnd: { buttonController.forwardLongPressEnded() })
                makeSeekButton(imageName: ImageNames.System.backwardEndAlt, offsetX: -buttonOffset,
                             onTap: { buttonController.backwardEndAltButtonPressed() },
                             onLongPressStart: { buttonController.backwardLongPressStarted() },
                             onLongPressEnd: { buttonController.backwardLongPressEnded() })
            }
            .frame(width: size, height: size * 0.9)
        }
    }
    
    private func dragGesture(in size: CGFloat) -> some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { v in
                let center = size * 0.395
                var angle = atan2(v.location.x - center, center - v.location.y) * 180 / .pi
                if angle < 0 { angle += 360 }
                
                guard let last = lastAngle else {
                    lastAngle = angle
                    buttonController.prepareHaptics()
                    return
                }
                
                var theta = last - angle
                if theta > 180 { theta -= 360 }
                if theta < -180 { theta += 360 }
                
                lastAngle = angle
                counter += theta
                
                let sensitivity: CGFloat = 13
                
                if counter > sensitivity {
                    if buttonController.hasScrollHandler || buttonController.selectedIndex > 0 {
                        buttonController.scrollUp()
                    }
                    counter = 0
                } else if counter < -sensitivity {
                    if buttonController.hasScrollHandler || buttonController.selectedIndex < buttonController.menuCount - 1 {
                        buttonController.scrollDown()
                    }
                    counter = 0
                }
            }
            .onEnded { _ in 
                lastAngle = nil
                counter = 0 
            }
    }
    
    @ViewBuilder
    private func makeIconButton(imageName: String, offsetX: CGFloat = 0, offsetY: CGFloat = 0,
                                action: @escaping () -> Void,
                                onLongPress: @escaping () -> Void = {}) -> some View {
        iPlayrIconButton(imageName: imageName, onTapAction: action, onLongPressAction: onLongPress)
            .offset(x: offsetX, y: offsetY)
            .environmentObject(theme)
    }

    @ViewBuilder
    private func makeSeekButton(imageName: String, offsetX: CGFloat = 0, offsetY: CGFloat = 0,
                               onTap: @escaping () -> Void,
                               onLongPressStart: @escaping () -> Void,
                               onLongPressEnd: @escaping () -> Void) -> some View {
        iPlayrSeekButton(imageName: imageName,
                        onTapAction: onTap,
                        onLongPressStart: onLongPressStart,
                        onLongPressEnd: onLongPressEnd)
            .offset(x: offsetX, y: offsetY)
            .environmentObject(theme)
    }
}

// MARK: - Menu Button (tap + long press)

struct iPlayrMenuButton: View {
    let theme: ThemeManager
    let onTap: () -> Void
    let onLongPress: () -> Void

    var body: some View {
        Text("MENU")
            .font(.system(size: 16, weight: .bold))
            .foregroundColor(theme.currentTheme.glyphTint)
            .shadow(color: theme.currentTheme.wheelHighlight.opacity(theme.currentTheme.sheen * 0.8), radius: 0.5, x: 0, y: 1)
            .padding(20)
            .contentShape(Rectangle())
            .onTapGesture(perform: onTap)
            .onLongPressGesture(minimumDuration: 0.8, maximumDistance: 50) {
                onLongPress()
            }
    }
}

// MARK: - Icon Button (tap + optional long press)

struct iPlayrIconButton: View {
    let imageName: String
    let onTapAction: () -> Void
    var onLongPressAction: () -> Void = {}
    @EnvironmentObject private var theme: ThemeManager

    var body: some View {
        Image(systemName: imageName)
            .resizable()
            .frame(width: 24, height: 12)
            .foregroundColor(theme.currentTheme.glyphTint)
            .shadow(color: theme.currentTheme.wheelHighlight.opacity(theme.currentTheme.sheen * 0.8), radius: 0.5, x: 0, y: 1)
            .padding(20)
            .contentShape(Rectangle())
            .onTapGesture(perform: onTapAction)
            .onLongPressGesture(minimumDuration: 0.8, maximumDistance: 50) {
                onLongPressAction()
            }
    }
}

struct iPlayrSeekButton: View {
    let imageName: String
    let onTapAction: () -> Void
    let onLongPressStart: () -> Void
    let onLongPressEnd: () -> Void
    @EnvironmentObject private var theme: ThemeManager
    @State private var isPressed: Bool = false

    var body: some View {
        Image(systemName: imageName)
            .resizable()
            .frame(width: 24, height: 12)
            .foregroundColor(theme.currentTheme.glyphTint)
            .shadow(color: theme.currentTheme.wheelHighlight.opacity(theme.currentTheme.sheen * 0.8), radius: 0.5, x: 0, y: 1)
            .padding(20)
            .contentShape(Rectangle())
            .scaleEffect(isPressed ? 0.9 : 1.0)
            .onTapGesture(perform: onTapAction)
            .onLongPressGesture(minimumDuration: 0.5, maximumDistance: 50,
                               pressing: { pressing in
                                   withAnimation(.easeInOut(duration: 0.1)) {
                                       isPressed = pressing
                                   }
                                   if pressing {
                                       onLongPressStart()
                                   } else {
                                       onLongPressEnd()
                                   }
                               },
                               perform: {})
    }
}
