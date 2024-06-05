import SwiftUI
import SwiftGenDemo

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
          Text(L10n.projectString1)
          Text(L10n.projectString2)
          Text(SwiftGenDemo.L10n.string1)
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
