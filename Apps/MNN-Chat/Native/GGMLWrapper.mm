// GGMLWrapper.mm
// GGML wrapper implementation that attempts to use llama.cpp when available.
// Build: define LLAMA_CPP_AVAILABLE when you've added the llama.cpp submodule and built/linked the library.

#include "GGMLWrapper.h"
#include <stdlib.h>
#include <string.h>
#include <thread>
#include <atomic>

#ifdef LLAMA_CPP_AVAILABLE
// If you compiled/link llama.cpp as a library, include the proper headers here.
// The exact API surface can differ across forks. Adapt as needed.
#include "llama.h" // adjust include path according to your build
#endif

struct GGMLModelState {
#ifdef LLAMA_CPP_AVAILABLE
    // placeholder for actual llama model handle
    void* model;
#endif
    std::atomic<bool> cancel;
};

GGMLModelHandle ggml_load_model(const char* path) {
    if (!path) return NULL;

#ifdef LLAMA_CPP_AVAILABLE
    // Attempt to load a llama.cpp model via its C++ API.
    GGMLModelState* s = new GGMLModelState();
    s->cancel = false;
    // TODO: replace with actual llama.cpp load call, e.g.:
    // s->model = llama_model_load(path);
    (void)path;
    s->model = nullptr;
    return reinterpret_cast<GGMLModelHandle>(s);
#else
    // Fallback: return a state object but with no real model loaded.
    GGMLModelState* s = new GGMLModelState();
    s->cancel = false;
    s->model = nullptr;
    return reinterpret_cast<GGMLModelHandle>(s);
#endif
}

// Internal helper to run generation on a background thread and invoke callback for each token.
static void run_generation_async_with_params(GGMLModelState* state, const char* prompt, float temperature, int top_k, float top_p, int max_tokens, int threads, ggml_token_cb cb, void* userdata) {
    if (!cb) return;
    (void)threads; // placeholder: real implementation would set thread count on llama.cpp

#ifdef LLAMA_CPP_AVAILABLE
    // PSEUDO: replace this block with actual llama.cpp generation logic.
    // The real implementation should tokenize the prompt, run incremental eval, and invoke cb for each token produced.
    (void)state;
    (void)prompt;
    (void)temperature; (void)top_k; (void)top_p; (void)max_tokens;
    const char* demo = "这是从 ggml 后端流式生成的示例（真实实现请替换此处）。";
    int produced = 0;
    for (const char* p = demo; *p && !state->cancel.load() && (max_tokens <= 0 || produced < max_tokens); ++p, ++produced) {
        char s[8] = {0};
        int len = snprintf(s, sizeof(s), "%c", *p);
        if (len > 0) cb(s, userdata);
        // adjust sleep slightly based on temperature to simulate variability
        int ms = (int)fmax(20.0, 80.0 - temperature * 40.0);
        std::this_thread::sleep_for(std::chrono::milliseconds(ms));
    }
#else
    // fallback simulation (non-llama)
    const char* demo = "这是从 ggml 后端流式生成的示例。";
    int produced = 0;
    for (const char* p = demo; *p && !state->cancel.load() && (max_tokens <= 0 || produced < max_tokens); ++p, ++produced) {
        char s[8] = {0};
        int len = snprintf(s, sizeof(s), "%c", *p);
        if (len > 0) cb(s, userdata);
        int ms = (int)fmax(20.0, 80.0 - temperature * 40.0);
        std::this_thread::sleep_for(std::chrono::milliseconds(ms));
    }
#endif
}

static void run_generation_async(GGMLModelState* state, const char* prompt, ggml_token_cb cb, void* userdata) {
    // Backwards-compatible: call with default params
    run_generation_async_with_params(state, prompt, 0.7f, 40, 0.95f, 128, 2, cb, userdata);
}

int ggml_generate(GGMLModelHandle handle, const char* prompt, ggml_token_cb cb, void* userdata) {
    if (!handle || !prompt || !cb) return -1;
    GGMLModelState* state = reinterpret_cast<GGMLModelState*>(handle);
    // Launch generation on a detached thread so the call is non-blocking from Swift side.
    try {
        std::thread t([state, prompt, cb, userdata]() {
            run_generation_async(state, prompt, cb, userdata);
        });
        t.detach();
    } catch (...) {
        return -2;
    }
    return 0;
}

int ggml_generate_with_params(GGMLModelHandle handle, const char* prompt, float temperature, int top_k, float top_p, int max_tokens, int threads, ggml_token_cb cb, void* userdata) {
    if (!handle || !prompt || !cb) return -1;
    GGMLModelState* state = reinterpret_cast<GGMLModelState*>(handle);
    try {
        std::thread t([state, prompt, temperature, top_k, top_p, max_tokens, threads, cb, userdata]() {
            run_generation_async_with_params(state, prompt, temperature, top_k, top_p, max_tokens, threads, cb, userdata);
        });
        t.detach();
    } catch (...) {
        return -2;
    }
    return 0;
}

void ggml_stop(GGMLModelHandle handle) {
    if (!handle) return;
    GGMLModelState* state = reinterpret_cast<GGMLModelState*>(handle);
    state->cancel.store(true);
}

void ggml_free_model(GGMLModelHandle handle) {
    if (!handle) return;
    GGMLModelState* state = reinterpret_cast<GGMLModelState*>(handle);
    state->cancel.store(true);
    // If there are real resources (state->model), free them here using llama.cpp API.
#ifdef LLAMA_CPP_AVAILABLE
    // TODO: call appropriate destructor/free for the llama model
    (void)state->model;
#endif
    delete state;
}
