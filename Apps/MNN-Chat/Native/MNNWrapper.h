// MNNWrapper.h
#ifndef MNNWrapper_h
#define MNNWrapper_h

#ifdef __cplusplus
extern "C" {
#endif

typedef void* MNNModelHandle;

MNNModelHandle mnn_load_model(const char* path);
int mnn_run_inference(MNNModelHandle handle);
void mnn_free_model(MNNModelHandle handle);

#ifdef __cplusplus
}
#endif

#endif /* MNNWrapper_h */
