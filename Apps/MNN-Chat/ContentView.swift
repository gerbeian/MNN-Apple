import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    @StateObject private var modelManager = ModelManager()
    @State private var showingPicker = false
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                LiquidGlassView()
                    .frame(height: 200)

                ChatListView(messages: $modelManager.messages)

                HStack {
                    Button(action: { showingPicker = true }) {
                        Image(systemName: "doc")
                        Text("Load model")
                    }
                    .padding(.leading)

                    Toggle(isOn: $modelManager.useGPU) {
                        Text("GPU")
                    }
                    .padding(.horizontal)

                    Spacer()

                    Button(action: {
                        modelManager.sendUserMessage("Hello")
                    }) {
                        Text("Send")
                            .bold()
                            .padding(.horizontal)
                            .padding(.vertical, 8)
                            .background(Capsule().fill(Color.accentColor))
                            .foregroundColor(.white)
                    }
                    .padding(.trailing)
                }
                .frame(height: 60)
                .background(VisualEffectBlur(effect: .systemUltraThinMaterial))
            }
            .navigationTitle("MNN Chat")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: SettingsView(modelManager: modelManager)) {
                        Image(systemName: "gearshape")
                    }
                }
            }
            .fileImporter(isPresented: $showingPicker, allowedContentTypes: [.data], allowsMultipleSelection: false) { result in
                switch result {
                case .success(let urls):
                    if let url = urls.first {
                        modelManager.loadModel(from: url)
                    }
                case .failure(let err):
                    print("Picker error: \(err)")
                }
            }
        }
    }
}
