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

                accentRow(title: "1/4", pattern: .none)
                accentRow(title: "2/4", pattern: .two)
                accentRow(title: "3/4", pattern: .three)
                accentRow(title: "4/4", pattern: .four)
                accentRow(title: "5/4", pattern: .five)
                accentRow(title: "6/4", pattern: .six)
                accentRow(title: "7/4", pattern: .seven)
            }
            .padding()
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .padding(.horizontal)

            // Click Sound Section
            VStack(alignment: .leading, spacing: 16) {
                Text("Click Sound")
                    .font(.headline)

                clickRow(title: "Classic", sound: .classic)
                clickRow(title: "Soft", sound: .soft)
                clickRow(title: "Sharp", sound: .sharp)
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

    // MARK: - Click Sound Row
    @ViewBuilder
    private func clickRow(
        title: String,
        sound: AppState.ClickSound
    ) -> some View {
        Button {
            appState.selectedClickSound = sound
        } label: {
            HStack {
                Image(systemName:
                    appState.selectedClickSound == sound
                    ? "checkmark.circle.fill"
                    : "circle"
                )
                .foregroundStyle(
                    appState.selectedClickSound == sound
                    ? .blue
                    : .secondary
                )

                Text(title)
                Spacer()
            }
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    SettingsView()
        .environment(AppState())
}

