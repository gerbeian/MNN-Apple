#ifndef GGMLWrapper_h
#define GGMLWrapper_h

#include <stdio.h>

#ifdef __cplusplus
extern "C" {
#endif

// Opaque handle
typedef void* GGMLModelHandle;

// Load a ggml model from local path. Returns NULL on failure.
GGMLModelHandle ggml_load_model(const char* path);

// Start streaming generation; callback receives a C string token (must copy if needed)
typedef void (*ggml_token_cb)(const char* token, void* userdata);

// Run generation (non-blocking). Returns 0 on success.
int ggml_generate(GGMLModelHandle handle, const char* prompt, ggml_token_cb cb, void* userdata);

// Run generation with parameters (non-blocking). Parameters:
// temperature: float, top_k: int, top_p: float, max_tokens: int, threads: int
int ggml_generate_with_params(GGMLModelHandle handle, const char* prompt, float temperature, int top_k, float top_p, int max_tokens, int threads, ggml_token_cb cb, void* userdata);

// Stop an ongoing generation (sets cancel flag). Safe to call if no generation is running.
void ggml_stop(GGMLModelHandle handle);

// Free model
void ggml_free_model(GGMLModelHandle handle);

#ifdef __cplusplus
}
#endif

#endif /* GGMLWrapper_h */
