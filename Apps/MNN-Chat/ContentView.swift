import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    @StateObject private var modelManager = ModelManager()
    @State private var showingPicker = false
    @Environment(\._colorScheme) private var colorScheme

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
                    Menu {
                        Button("Dark/Light Toggle") {
                            // simple demo: real app should use App storage or settings
                            // no-op here
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
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

// Simple chat list
struct ChatListView: View {
    @Binding var messages: [ChatMessage]

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(messages) { msg in
                        GlassCard {
                            HStack {
                                if msg.isUser { Spacer() }
                                Text(msg.text)
                                    .foregroundColor(.primary)
                                    .padding(12)
                                    .background(msg.isUser ? Color.blue.opacity(0.2) : Color.gray.opacity(0.12))
                                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                                if !msg.isUser { Spacer() }
                            }
                        }
                        .id(msg.id)
                    }
                }
                .padding()
            }
            .onChange(of: messages.count) { _ in
                if let last = messages.last {
                    proxy.scrollTo(last.id, anchor: .bottom)
                }
            }
        }
    }
}
