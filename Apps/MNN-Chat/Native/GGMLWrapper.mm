// GGMLWrapper.mm
// Minimal stub implementations. Replace with real llama.cpp / ggml bridge.

#include "GGMLWrapper.h"
#include <stdlib.h>
#include <string.h>

GGMLModelHandle ggml_load_model(const char* path) {
    // TODO: load model via llama.cpp or ggml API
    (void)path;
    return NULL;
}

int ggml_generate(GGMLModelHandle handle, const char* prompt, ggml_token_cb cb, void* userdata) {
    (void)handle; (void)prompt;
    // Simulate tokens
    const char* demo = "这是从 ggml 后端流式生成的示例。";
    for (const char* p = demo; *p; ++p) {
        char s[5] = {0};
        int len = snprintf(s, sizeof(s), "%c", *p);
        if (len > 0 && cb) cb(s, userdata);
        // in real code, sleep/yield appropriately
    }
    return 0;
}

void ggml_free_model(GGMLModelHandle handle) {
    (void)handle;
    // free resources
}
