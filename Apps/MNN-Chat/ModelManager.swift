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

    // Generation parameters (exposed in settings)
    @Published var temperature: Double = 0.7
    @Published var topK: Int = 40
    @Published var topP: Double = 0.95
    @Published var maxTokens: Int = 128
    @Published var threads: Int = 2

    // Image fallback
    @Published var remoteFallbackEnabled: Bool = true

    // Native handles
    private var ggmlHandle: UnsafeMutableRawPointer? = nil
    private var mnnHandle: UnsafeMutableRawPointer? = nil

    // Loaded model info
    private(set) var backend: ModelBackend? = nil
    private(set) var modelURL: URL? = nil

    init() {
        // initial demo message
        messages = [ChatMessage(text: "欢迎使用 MNN Chat。加载模型后可开始对话。", isUser: false)]
    }

    deinit {
        if let h = ggmlHandle {
            ggml_free_model(h)
            ggmlHandle = nil
        }
        if let h = mnnHandle {
            mnn_free_model(h)
            mnnHandle = nil
        }
    }

    func loadModel(from url: URL) {
        self.modelURL = url
        let suffix = url.pathExtension.lowercased()
        switch suffix {
        case "ggml":
            backend = .ggml
            // load ggml model via native wrapper
            if let handle = ggml_load_model(url.path) {
                ggmlHandle = handle
                print("ggml model loaded: \(url.lastPathComponent)")
            } else {
                ggmlHandle = nil
                print("failed to load ggml model")
            }
        case "mnn":
            backend = .mnn
            if let handle = mnn_load_model(url.path) {
                mnnHandle = handle
                print("mnn model loaded: \(url.lastPathComponent)")
            } else {
                mnnHandle = nil
                print("failed to load mnn model")
            }
        case "onnx":
            backend = .onnx
            print("onnx model selected (integration pending)")
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

        // Dispatch generation based on backend
        switch backend {
        case .ggml:
            startGGMLGenerate(prompt: text)
        case .mnn:
            // TODO: implement MNN-based generation/inference
            simulateStreamingReply()
        case .onnx:
            simulateStreamingReply()
        case .none:
            // no model loaded; fallback simulation
            simulateStreamingReply()
        }
    }

    // MARK: - GGML Integration

    private func startGGMLGenerate(prompt: String) {
        guard let handle = ggmlHandle else {
            simulateStreamingReply()
            return
        }

        // Create C callback
        let cb: @convention(c) (UnsafePointer<CChar>?, UnsafeMutableRawPointer?) -> Void = { tokenPtr, userdata in
            guard let tokenPtr = tokenPtr, let userdata = userdata else { return }
            let token = String(cString: tokenPtr)
            let unmanaged = Unmanaged<ModelManager>.fromOpaque(userdata)
            let mgr = unmanaged.takeUnretainedValue()
            Task { @MainActor in
                if let lastIndex = mgr.messages.lastIndex(where: { !$0.isUser }) {
                    mgr.messages[lastIndex].text += token
                }
            }
        }

        // Pass Swift self as userdata
        let userdata = Unmanaged.passUnretained(self).toOpaque()

        // Call C function (non-blocking in wrapper)
        // Note: ggml_generate_with_params returns immediately while generation runs on background thread in wrapper.
        let rc = ggml_generate_with_params(handle, prompt, Float(self.temperature), Int32(self.topK), Float(self.topP), Int32(self.maxTokens), Int32(self.threads), cb, userdata)
        if rc != 0 {
            print("ggml_generate returned \(rc), falling back to simulated reply")
            simulateStreamingReply()
        }
    }

    func stopGeneration() {
        if let h = ggmlHandle {
            ggml_stop(h)
        }
    }

    // MARK: - Simulation fallback
    private func simulateStreamingReply() {
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

    // Placeholder MNN API call
    func runMNNInference() {
        guard let h = mnnHandle else { return }
        _ = mnn_run_inference(h)
    }
}
