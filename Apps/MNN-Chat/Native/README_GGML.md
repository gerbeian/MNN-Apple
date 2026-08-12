# GGML integration notes

We added a .gitmodules entry pointing to ggerganov/llama.cpp as a recommended upstream for GGML/llama support.

How to initialize the submodule:

  git submodule update --init --recursive

After that, run scripts/build-llama-ios.sh for guidance on building a static library for iOS. The script does not attempt an automatic complex cross-compile — it provides recommended steps and a placeholder for your platform-specific build commands.

Once you produce a static lib and headers, add the library to the Xcode project (Link Binary With Libraries) and add header search paths to the external/llama.cpp include directory. Then define LLAMA_CPP_AVAILABLE in the target's Swift/Clang preprocessor macros so the GGMLWrapper will try to use the real API.

The GGMLWrapper implementation currently supports a fallback simulated token stream so you can test the UI before finishing native integration.
