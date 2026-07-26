import SwiftUI
import Combine

struct iPlayrScreen: View {
    @EnvironmentObject var iPlayrController: iPlayrButtonController
    @EnvironmentObject var navigationManager: NavigationManager
    @EnvironmentObject var theme: ThemeManager
    
    var width: CGFloat
    var height: CGFloat

    private var hasRightView: Bool {
        switch navigationManager.routes.last {
        case .none, .music, .settings, .theme, .signIn:
            return true
        default:
            return false
        }
    }

    var body: some View {
        let cornerRadius: CGFloat = 12
        let bezelWidth: CGFloat = 6
        
        ZStack {
            // 1. The Screen Content (List, Now Playing, etc.)
            // The content itself should not be darkened by the outer seam.
            contentView()
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius - bezelWidth/2))
                // Glass gloss streak inside the glass only
                .overlay(
                    GeometryReader { geo in
                        Path { path in
                            path.move(to: CGPoint(x: 0, y: geo.size.height * 0.1))
                            path.addLine(to: CGPoint(x: geo.size.width, y: geo.size.height * 0.5))
                            path.addLine(to: CGPoint(x: geo.size.width, y: geo.size.height * 0.6))
                            path.addLine(to: CGPoint(x: 0, y: geo.size.height * 0.2))
                            path.closeSubpath()
                        }
                        .fill(LinearGradient(
                            gradient: Gradient(colors: [.clear, .white.opacity(theme.currentTheme.sheen * 0.15), .clear]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                    }
                )

            // 2. The Bezel (channel between metal and glass)
            RoundedRectangle(cornerRadius: cornerRadius)
                .strokeBorder(
                    LinearGradient(
                        gradient: Gradient(colors: [theme.currentTheme.bezel.opacity(1.0), theme.currentTheme.bezel.opacity(0.4)]),
                        startPoint: .top,
                        endPoint: .bottom
                    ),
                    lineWidth: bezelWidth
                )
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .strokeBorder(Color.clear.shadow(.inner(color: .black.opacity(0.6), radius: 3, x: 0, y: 3)), lineWidth: bezelWidth)
                )

            // 3. Bottom Hairline Highlight (light bounce on bottom edge)
            RoundedRectangle(cornerRadius: cornerRadius)
                .stroke(theme.currentTheme.chassisHighlight.opacity(theme.currentTheme.sheen * 0.6), lineWidth: 1)
                // Mask it so it only appears at the bottom
                .mask(
                    LinearGradient(
                        gradient: Gradient(colors: [.clear, .clear, .black]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .offset(y: 1)
        }
        .frame(width: width, height: height)
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
    }

    @ViewBuilder
    private func contentView() -> some View {
        HStack(spacing: 0) {
            createNavigationStack()
                .zIndex(1)

            if hasRightView {
                RightImageView()
                    .frame(width: width / 2, alignment: .bottomLeading)
                    .zIndex(0)
                    .transition(.identity)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: hasRightView)
    }

    private func createNavigationStack() -> some View {
        NavigationStack(path: $navigationManager.routes) {
            HomeListView()
                .environmentObject(iPlayrController)
                .frame(width: hasRightView ? width / 2 : width)
                .animation(.easeInOut(duration: 0.2), value: hasRightView)
                .navigationDestination(for: Route.self) { route in
                    route.destination
                        .environmentObject(iPlayrController)
                        .environmentObject(navigationManager)
                }
        }
        .onNavigate { navType in
            switch navType {
            case .push(let route):
                Task { @MainActor in
                    navigationManager.push(route)
                }
            }
        }
    }
}

extension View {
    func onNavigate(_ action: @escaping NavigateAction.Action) -> some View {
        environment(\.navigate, NavigateAction(action: action))
    }
}
