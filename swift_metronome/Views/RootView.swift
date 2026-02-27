import SwiftUI

struct RootView: View {
    @State private var page = 1   // 1 = Metronome

    var body: some View {
        TabView(selection: $page) {
            SettingsView()
                .tag(0)

            MetronomeView()
                .tag(1)

            SetlistView()
                .tag(2)
        }
        .tabViewStyle(.page(indexDisplayMode: .always))
        .indexViewStyle(.page(backgroundDisplayMode: .always))
    }
}
