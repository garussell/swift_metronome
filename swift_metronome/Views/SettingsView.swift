import SwiftUI

struct SettingsView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        VStack(spacing: 24) {

            // Title
            Text("Settings")
                .font(.largeTitle)
                .padding(.top, 40)

            // Accent Pattern Section
            VStack(alignment: .leading, spacing: 16) {
                Text("Accent Pattern")
                    .font(.headline)

                accentRow(title: "4 beats", pattern: .four)
                accentRow(title: "5 beats", pattern: .five)
                accentRow(title: "6 beats", pattern: .six)
                accentRow(title: "7 beats", pattern: .seven)
            }
            .padding()
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .padding(.horizontal)

            Spacer()
        }
    }

    // MARK: - Accent Row
    @ViewBuilder
    private func accentRow(
        title: String,
        pattern: AppState.AccentPattern
    ) -> some View {
        Button {
            appState.selectedAccentPattern = pattern
        } label: {
            HStack {
                Image(systemName:
                    appState.selectedAccentPattern == pattern
                    ? "checkmark.circle.fill"
                    : "circle"
                )
                .foregroundStyle(
                    appState.selectedAccentPattern == pattern
                    ? .blue
                    : .secondary
                )

                Text(title)

                Spacer()

                let preview = appState.pattern(for: pattern)
                HStack(spacing: 4) {
                    ForEach(preview.indices, id: \.self) { index in
                        Circle()
                            .fill(preview[index] ? Color.blue : Color.gray.opacity(0.3))
                            .frame(width: 8, height: 8)
                    }
                }
            }
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    SettingsView()
        .environment(AppState())
}
