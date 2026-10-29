# K230 RTOS SDK Documentation / 开发文档

本仓库提供嘉楠 Kendryte K230 RTOS Only SDK 的中英文文档，涵盖 SDK 编译、固件烧录、应用开发、AI 与多媒体、API 参考和硬件兼容性。

This repository contains the Chinese and English documentation for the Canaan Kendryte K230 RTOS Only SDK, covering SDK builds, firmware flashing, application development, AI and multimedia, API references, and hardware compatibility.

## 阅读文档 / Documentation

| 内容 / Topic | 中文 | English |
| --- | --- | --- |
| 文档首页 / Overview | [文档首页](zh/index.md) | [Overview](en/index.md) |
| 快速入门 / Quick start | [快速入门](zh/quick_start.md) | [Quick start](en/quick_start.md) |
| 编译 SDK / Build the SDK | [编译指南](zh/userguide/how_to_build.md) | [Build guide](en/userguide/how_to_build.md) |
| 烧录固件 / Flash firmware | [烧录指南](zh/userguide/how_to_flash.md) | [Flashing guide](en/userguide/how_to_flash.md) |
| 应用开发 / Application development | [应用开发指南](zh/app_develop_guide/index.md) | [Application development](en/app_develop_guide/index.md) |
| 进阶开发 / Advanced development | [进阶开发指南](zh/advanced_development_guide/index.md) | [Advanced development](en/advanced_development_guide/index.md) |
| API 参考 / API reference | [API 参考](zh/api_reference/index.md) | [API reference](en/api_reference/index.md) |
| AI 开发 / AI development | [AI 开发指南](zh/ai_dev_doc.md) | [AI development](en/ai_dev_doc.md) |
| 硬件兼容性 / Hardware compatibility | [兼容列表](zh/hardware_compatibility/index.md) | [Compatibility lists](en/hardware_compatibility/index.md) |
| 常见问题 / FAQ | [常见问题](zh/faq.md) | [FAQ](en/faq.md) |

## 构建文档网站 / Build the documentation website

可以直接在仓库中阅读 Markdown 文档。构建 HTML 网站需要 Python、Sphinx 依赖，以及提供网站模板和静态资源的服务器。请先将环境变量 `WEB_DOCS_BUILDER_URL` 设置为可访问的模板服务器地址，再运行以下命令。

You can read the Markdown files directly in this repository. Building the HTML website requires Python, the Sphinx dependencies, and a server providing the website templates and static assets. Set the `WEB_DOCS_BUILDER_URL` environment variable to a reachable template server before running:

```sh
python3 -m pip install -r requirements.txt
make html
```

生成的中文和英文页面分别位于 `_build/html/zh/` 和 `_build/html/en/`。

The generated Chinese and English pages are written to `_build/html/zh/` and `_build/html/en/`, respectively.

## 参与贡献 / Contributing

发现文档问题或希望完善内容，请提交 [Issue](https://github.com/kendryte/k230_rtos_docs/issues) 或 Pull Request，并参考[贡献指南](.github/CONTRIBUTING.md)和[行为准则](.github/CODE_OF_CONDUCT.md)。文档页面请使用小写英文文件名，并尽量同步更新中英文内容；仓库根目录的入口文件使用 `README.md`。

Report documentation issues or suggest improvements through [Issues](https://github.com/kendryte/k230_rtos_docs/issues) and pull requests. Read the [contribution guide](.github/CONTRIBUTING.md) and [code of conduct](.github/CODE_OF_CONDUCT.md). Use lowercase English filenames for documentation pages and update both language versions where possible; the repository's root entry file is `README.md`.
