import SwiftUI
import SwiftData

struct MetronomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(AppState.self) private var appState

    @Query private var allTempos: [Tempo]

    var tempos: [Tempo] {
        guard let setlist = appState.activeSetlist else {
            return allTempos
                .filter { $0.setlist == nil }
                .sorted { $0.order < $1.order }
        }

        return allTempos
            .filter { $0.setlist == setlist }
            .sorted { $0.order < $1.order }
    }

    @State private var bpm: Int = 120
    @State private var isPulsing = false
    @State private var isAccentBeat = false
    @State private var timer: Timer?
    @State private var selectedTempoName: String?
    @State private var isMuted = true
    @State private var beatIndex = 0

    var body: some View {
        VStack(spacing: 30) {

            Text(selectedTempoName ?? "Tempo")
                .font(.title)
                .padding(.top, 40)

            Circle()
                .fill(
                    isPulsing
                    ? (isAccentBeat ? .red : .blue)
                    : .gray.opacity(0.3)
                )
                .frame(width: 80, height: 80)
                .scaleEffect(isPulsing ? 1.2 : 1.0)
                .animation(.easeOut(duration: 0.1), value: isPulsing)

            Picker("Tempo", selection: $bpm) {
                ForEach(40...240, id: \.self) {
                    Text("\($0) BPM").tag($0)
                }
            }
            .pickerStyle(.wheel)
            .frame(height: 150)
            .clipped()
            .onChange(of: bpm) {
                restartPulse()
            }

            Toggle(isOn: $isMuted) {
                Label(
                    "Mute",
                    systemImage: isMuted
                        ? "speaker.slash.fill"
                        : "speaker.wave.2.fill"
                )
            }
            .padding(.horizontal)

            List {
                ForEach(tempos) { tempo in
                    Button {
                        bpm = tempo.bpm
                        selectedTempoName = tempo.name
                        restartPulse()
                    } label: {
                        HStack {
                            Text(tempo.name)
                            Spacer()
                            Text("\(tempo.bpm) BPM")
                        }
                    }
                }
                .onDelete(perform: deleteTempos)
            }
        }
        .onAppear {
            UIApplication.shared.isIdleTimerDisabled = true

            SynthMetronome.shared.setClickStyle(
                appState.selectedClickSound.synthStyle
            )

            startPulse()
        }
        .onChange(of: appState.selectedClickSound) { newStyle in
            SynthMetronome.shared.setClickStyle(newStyle.synthStyle)
        }
        .onDisappear {
            UIApplication.shared.isIdleTimerDisabled = false
            timer?.invalidate()
        }
    }

    // MARK: - Pulse Logic
    private func startPulse() {
        timer?.invalidate()

        let interval = 60.0 / Double(bpm)

        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { _ in
            isPulsing = true

            let pattern = appState.activeAccentPattern
            let index = beatIndex % pattern.count
            let isAccent = pattern[index]

            isAccentBeat = isAccent

            if !isMuted {
                SynthMetronome.shared.play(isAccent ? .accent : .tap)
            }

            beatIndex = (beatIndex + 1) % pattern.count

            DispatchQueue.main.asyncAfter(deadline: .now() + interval / 2) {
                isPulsing = false
            }
        }
    }

    private func restartPulse() {
        beatIndex = 0
        startPulse()
    }

    // MARK: - CRUD
    private func deleteTempos(offsets: IndexSet) {
        for index in offsets {
            let tempo = tempos[index]
            if tempo.name == selectedTempoName {
                selectedTempoName = nil
            }
            modelContext.delete(tempo)
        }
    }
}


// MARK: - Preview
#Preview {
    MetronomeView()
        .modelContainer(for: Tempo.self, inMemory: true)
}
