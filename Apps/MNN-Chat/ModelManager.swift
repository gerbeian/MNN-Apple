import Foundation
import Combine
import SwiftUI

enum ModelBackend {
    case ggml
    case mnn
    case onnx
}

struct ChatMessage: Identifiable, Equatable {
    let id = UUID()
    var text: String
    var isUser: Bool
}

@MainActor
final class ModelManager: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var useGPU: Bool = false

    private var cancellables = Set<AnyCancellable>()

    // Loaded model info
    private(set) var backend: ModelBackend? = nil
    private(set) var modelURL: URL? = nil

    func loadModel(from url: URL) {
        self.modelURL = url
        let suffix = url.pathExtension.lowercased()
        switch suffix {
        case "ggml":
            backend = .ggml
            // TODO: call GGMLWrapper to load
            print("Detected ggml model")
        case "mnn":
            backend = .mnn
            // TODO: call MNNWrapper to load
            print("Detected mnn model")
        case "onnx":
            backend = .onnx
            // TODO: call ONNX runtime wrapper to load
            print("Detected onnx model")
        default:
            backend = nil
            print("Unsupported model suffix: \(suffix)")
        }
    }

    func sendUserMessage(_ text: String) {
        let msg = ChatMessage(text: text, isUser: true)
        messages.append(msg)
        // append assistant placeholder
        let assistant = ChatMessage(text: "", isUser: false)
        messages.append(assistant)
        streamResponse(for: text)
    }

    private func streamResponse(for prompt: String) {
        // In real implementation: call into ggml/mnn/onnx wrapper and stream tokens.
        // Here we simulate streaming tokens for demo and UI wiring.
        let simulated = "这是基于本地模型生成的示例回复，支持流式展示。"
        var current = ""
        let tokens = simulated.map { String($0) }
        Task {
            for token in tokens {
                try? await Task.sleep(nanoseconds: 50_000_000) // 50ms per token
                current += token
                await MainActor.run {
                    if let lastIndex = self.messages.lastIndex(where: { !$0.isUser }) {
                        self.messages[lastIndex].text = current
                    }
                }
            }
        }
    }
}
