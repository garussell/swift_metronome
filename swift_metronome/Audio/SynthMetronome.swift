import AVFoundation

// MARK: - Synthesized Metronome
final class SynthMetronome {

    static let shared = SynthMetronome()

    enum Sound {
        case tap
        case accent
    }

    private let engine = AVAudioEngine()
    private let player = AVAudioPlayerNode()

    private var tapBuffer: AVAudioPCMBuffer?
    private var accentBuffer: AVAudioPCMBuffer?

    private let sampleRate: Double = 44_100

    // MARK: - Init
    private init() {
        engine.attach(player)

        let format = AVAudioFormat(
            standardFormatWithSampleRate: sampleRate,
            channels: 1
        )!

        engine.connect(player, to: engine.mainMixerNode, format: format)

        // Generate buffers
        tapBuffer = makeBeepBuffer(
            frequency: 900,
            amplitude: 0.35,
            duration: 0.05,
            format: format
        )

        accentBuffer = makeBeepBuffer(
            frequency: 1500,
            amplitude: 0.7,
            duration: 0.05,
            format: format
        )

        startEngine()
        activateAudioSession()
    }

    // MARK: - Public API
    func play(_ sound: Sound) {
        let buffer: AVAudioPCMBuffer?

        switch sound {
        case .tap:
            buffer = tapBuffer
        case .accent:
            buffer = accentBuffer
        }

        guard let buffer else { return }

        player.scheduleBuffer(
            buffer,
            at: nil,
            options: .interrupts,
            completionHandler: nil
        )

        if !player.isPlaying {
            player.play()
        }
    }

    // MARK: - Buffer Generation
    private func makeBeepBuffer(
        frequency: Float,
        amplitude: Float,
        duration: Float,
        format: AVAudioFormat
    ) -> AVAudioPCMBuffer {

        let frameCount = AVAudioFrameCount(format.sampleRate * Double(duration))

        let buffer = AVAudioPCMBuffer(
            pcmFormat: format,
            frameCapacity: frameCount
        )!

        buffer.frameLength = frameCount

        let channelData = buffer.floatChannelData![0]
        let sr = Float(format.sampleRate)

        for i in 0..<Int(frameCount) {
            let sample = sin(2.0 * Float.pi * frequency * Float(i) / sr)
            channelData[i] = sample * amplitude
        }

        return buffer
    }

    // MARK: - Audio Engine
    private func startEngine() {
        do {
            try engine.start()
        } catch {
            print("AVAudioEngine failed to start:", error)
        }
    }

    // MARK: - Audio Session
    private func activateAudioSession() {
        let session = AVAudioSession.sharedInstance()

        do {
            try session.setCategory(
                .playback,
                mode: .default,
                options: [.mixWithOthers]
            )
            try session.setActive(true)
        } catch {
            print("Failed to activate audio session:", error)
        }
    }
}
