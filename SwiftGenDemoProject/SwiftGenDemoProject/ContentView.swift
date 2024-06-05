import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
          Text(L10n.projectString1)
          Text(L10n.projectString2)
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
