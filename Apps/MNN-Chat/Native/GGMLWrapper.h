// GGMLWrapper.h
// C API surface for a ggml-based backend (llama.cpp or similar)

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

// Run generation (non-blocking implementations may exist). Returns 0 on success.
int ggml_generate(GGMLModelHandle handle, const char* prompt, ggml_token_cb cb, void* userdata);

// Free model
void ggml_free_model(GGMLModelHandle handle);

#ifdef __cplusplus
}
#endif

#endif /* GGMLWrapper_h */
