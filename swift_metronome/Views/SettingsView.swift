import SwiftUI

struct SettingsView: View {
    var body: some View {
        VStack {
            Text("Settings")
                .font(.largeTitle)
                .padding(.top, 40)

            Spacer()

            Text("Coming soon…")
                .foregroundStyle(.secondary)

            Spacer()
        }
    }
}

#Preview {
    SettingsView()
}
