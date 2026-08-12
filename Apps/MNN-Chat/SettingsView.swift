import SwiftUI

struct SettingsView: View {
    @ObservedObject var modelManager: ModelManager
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        Form {
            Section(header: Text("Generation Parameters")) {
                HStack {
                    Text("Temperature")
                    Spacer()
                    Text(String(format: "%.2f", modelManager.temperature))
                        .foregroundColor(.secondary)
                }
                Slider(value: $modelManager.temperature, in: 0.0...1.5, step: 0.01)

                Stepper(value: $modelManager.topK, in: 1...200, step: 1) {
                    Text("Top K: \(modelManager.topK)")
                }

                HStack {
                    Text("Top P")
                    Spacer()
                    Text(String(format: "%.2f", modelManager.topP))
                        .foregroundColor(.secondary)
                }
                Slider(value: $modelManager.topP, in: 0.0...1.0, step: 0.01)

                Stepper(value: $modelManager.maxTokens, in: 1...1024, step: 1) {
                    Text("Max Tokens: \(modelManager.maxTokens)")
                }

                Stepper(value: $modelManager.threads, in: 1...8, step: 1) {
                    Text("Threads: \(modelManager.threads)")
                }
            }

            Section(header: Text("Runtime")) {
                Toggle(isOn: $modelManager.useGPU) {
                    Text("Use GPU (if available)")
                }

                Toggle(isOn: $modelManager.remoteFallbackEnabled) {
                    Text("Enable remote image fallback")
                }
            }

            Section {
                Button("Done") {
                    presentationMode.wrappedValue.dismiss()
                }
            }
        }
        .navigationTitle("Settings")
    }
}
