// High level routing for different views

import SwiftUI

struct RootView: View {
    var body: some View {
        TabView {
            MetronomeView()
            SetlistView()
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
    }
}
