import SwiftUI

struct SettingsView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        VStack(spacing: 24) {

            // Title
            Text("Settings")
                .font(.largeTitle)
                .padding(.top, 40)

            // Time Signature Section
            VStack(alignment: .leading, spacing: 16) {
                Text("Time Signature")
                    .font(.headline)

                accentRow(pattern: .none)
                accentRow(pattern: .two)
                accentRow(pattern: .three)
                accentRow(pattern: .four)
                accentRow(pattern: .five)
                accentRow(pattern: .six)
                accentRow(pattern: .seven)
            }
            .padding()
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .padding(.horizontal)

            // Click Sound Section
            VStack(alignment: .leading, spacing: 16) {
                Text("Click Sound")
                    .font(.headline)

                clickRow(sound: .classic)
                clickRow(sound: .soft)
                clickRow(sound: .sharp)
            }
            .padding()
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .padding(.horizontal)

            Spacer()
        }
    }

    // MARK: - Accent Row
    private func accentRow(pattern: AppState.AccentPattern) -> some View {
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

                Text(pattern.displayName)

                Spacer()

                beatDots(for: pattern)
            }
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private func beatDots(for pattern: AppState.AccentPattern) -> some View {
        if pattern == .none {
            Text("–")
                .foregroundStyle(.secondary)
                .frame(width: 40)
        } else {
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

    // MARK: - Click Sound Row
    private func clickRow(sound: AppState.ClickSound) -> some View {
        HStack {
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

                    Text(sound.displayName)
                    Spacer()
                }
            }
            .buttonStyle(.plain)

            Button {
                SynthMetronome.shared.setClickStyle(sound.synthStyle)
                SynthMetronome.shared.play(.tap)
                SynthMetronome.shared.setClickStyle(appState.selectedClickSound.synthStyle)
            } label: {
                Image(systemName: "play.circle")
                    .foregroundStyle(.blue)
                    .font(.title3)
            }
            .buttonStyle(.plain)
        }
    }
}

#Preview {
    SettingsView()
        .environment(AppState())
}
