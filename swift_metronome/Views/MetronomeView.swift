import SwiftUI
import SwiftData

// MARK: - MetronomeView
struct MetronomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(AppState.self) private var appState

    @Query private var allTempos: [Tempo]

    var tempos: [Tempo] {
        guard let setlist = appState.activeSetlist else {
            return allTempos.filter { $0.setlist == nil }
                .sorted { $0.order < $1.order } // respects .order
        }

        return allTempos.filter { $0.setlist == setlist }
            .sorted { $0.order < $1.order } // respects .order
    }

    @State private var bpm: Int = 120
    @State private var isPulsing: Bool = false
    @State private var isAccentBeat: Bool = false
    @State private var timer: Timer?
    @State private var selectedTempoName: String? = nil
    @State private var isMuted: Bool = true
    @State private var beatIndex: Int = 0

    var body: some View {
        VStack(spacing: 30) {

            // Title
            Text(selectedTempoName ?? "Tempo")
                .font(.title)
                .padding(.top, 40)

            // Pulsing circle (now higher)
            Circle()
                .fill(isPulsing
                      ? (isAccentBeat ? .red : .blue)
                      : .gray.opacity(0.3))
                .frame(width: 80, height: 80)
                .scaleEffect(isPulsing ? 1.2 : 1.0)
                .animation(.easeOut(duration: 0.1), value: isPulsing)

            // BPM wheel picker
            Picker("Tempo", selection: $bpm) {
                ForEach(40...240, id: \.self) { value in
                    Text("\(value) BPM").tag(value)
                }
            }
            .pickerStyle(.wheel)
            .frame(height: 150)
            .clipped()
            .onChange(of: bpm) {
                restartPulse()
            }

            // Mute toggle
            Toggle(isOn: $isMuted) {
                Label(
                    "Mute",
                    systemImage: isMuted
                        ? "speaker.slash.fill"
                        : "speaker.wave.2.fill"
                )
            }
            .padding(.horizontal)

            // Saved tempos
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
        
        // iPhone does not fall asleep while app is in use
        .onAppear {
            UIApplication.shared.isIdleTimerDisabled = true
            startPulse()
        }
        .onDisappear {
            UIApplication.shared.isIdleTimerDisabled = false
            timer?.invalidate()
        }

    }


    // MARK: - BPM Pulse
    func startPulse() {
        timer?.invalidate()
        let interval = 60.0 / Double(bpm)

        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { _ in
            isPulsing = true

            let pattern = appState.activeAccentPattern
            let safeIndex = beatIndex % pattern.count
            let isAccent = pattern[safeIndex]

            // Always update visual state
            isAccentBeat = isAccent

            // Only gate sound
            if !isMuted {
                SynthMetronome.shared.play(isAccent ? .accent : .tap)
            }

            beatIndex = (beatIndex + 1) % pattern.count


            DispatchQueue.main.asyncAfter(deadline: .now() + interval / 2) {
                isPulsing = false
            }
        }
    }

    func restartPulse() {
        beatIndex = 0
        startPulse()
    }

    // MARK: - CRUD
    func deleteTempos(offsets: IndexSet) {
        for index in offsets {
            let tempo = tempos[index]
            if tempo.name == selectedTempoName {
                selectedTempoName = nil
            }
            modelContext.delete(tempos[index])
        }
    }
}

// MARK: - Preview
#Preview {
    MetronomeView()
        .modelContainer(for: Tempo.self, inMemory: true)
}
