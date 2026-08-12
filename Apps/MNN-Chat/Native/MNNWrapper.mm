// MNNWrapper.mm
#include "MNNWrapper.h"
#include <stdio.h>

MNNModelHandle mnn_load_model(const char* path) {
    (void)path;
    // TODO: call MNN Interpreter::createFromFile and return pointer
    return NULL;
}

int mnn_run_inference(MNNModelHandle handle) {
    (void)handle;
    return 0;
}

void mnn_free_model(MNNModelHandle handle) {
    (void)handle;
}
