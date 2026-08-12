# MNN-Apple

本仓库目标：在 iOS / iPadOS 上使用 SwiftUI 构建一个支持多后缀模型（.ggml, .mnn, .onnx）的聊天与图片生成功能原型，包含“液态玻璃”风格的精美 UI。

重要说明
- 本仓库不包含大型模型文件（如 .ggml/.mnn/.onnx）。请根据 README 指引把模型放入设备或在运行时从 Files 选择。
- 需要引入开源依赖（如 llama.cpp / ggml、MNN iOS framework、ONNX Runtime 等）。仓库将提供集成骨架与接口封装，具体第三方代码请按说明手动引入或以 submodule 形式添加。

快速开始
1. 在 Xcode 打开 Apps/MNN-Chat（目前为 Swift 源码骨架）。
2. 按 README 中依赖说明引入：
   - ggml / llama.cpp（用于 .ggml 模型）
   - MNN iOS framework（用于 .mnn）
   - ONNX Runtime iOS（用于 .onnx，可选）
3. 在设备上运行并通过 UI 选择本地模型文件进行加载。

分支策略
- 已创建 feature/multi-model-ggml 分支用于后续功能开发。不过你已授权我直接在 main 分支提交初始实现。

贡献与许可
- 本项目欢迎贡献。第三方依赖请确保许可兼容（MIT / Apache 等）。

