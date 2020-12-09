# BesLyric-for-X Packaging Script (Windows)

## 简介

本仓库中的脚本用于 Windows 上的 BesLyric-for-X 的 Inno Setup 安装程序制作。

## 注意

- 脚本在 Inno Setup 6.0.5 通过测试；
- 子模块`zh_CN`包含简体中文语言文件，来自 [kira-96/Inno-Setup-Chinese-Simplified-Translation](https://github.com/kira-96/Inno-Setup-Chinese-Simplified-Translation) ；
- 对 32 位的支持将在未来停止。

## 使用方法

### 获取脚本

```console
> git clone --recurse-submodules https://github.com/BesLyric-for-X/BesLyric-for-X_Windows-packaging.git
```

### Inno Setup Console-mode Compiler (ISCC)

#### 官方文档

- [Command Line Compiler Execution - Inno Setup Preprocessor Help](https://jrsoftware.org/ishelp/topic_compilercmdline.htm)
- [Inno Setup Preprocessor: Command Line Compiler Execution - Inno Setup Preprocessor Help](https://jrsoftware.org/ispphelp/topic_isppcc.htm)

#### 命令

```console
> ISCC.exe "/O\\outputDir" "/D..." ... BesLyric-for-X_Inno-Setup.iss
```

为避免重复输入命令，推荐使用 [VS Code 的任务列表](#任务列表-tasksjson-示例)。

#### 参数

以下是输出文件夹的路径`/O...`与 .iss 脚本文件路径之外的各种参数。

##### 0. `B4X_SourceCode_Directory` （必需）

BesLyric-for-X 源代码所在文件夹的路径。

##### 1. `B4X_Binary_Directory` （必需）

`BesLyric-for-X.exe`文件所在文件夹的路径。

### VS Code

#### 拓展

- [Inno Setup](https://marketplace.visualstudio.com/items?itemName=idleberg.innosetup)
- [Pascal](https://marketplace.visualstudio.com/items?itemName=alefragnani.pascal)

#### 任务列表 tasks.json 示例

基于 [idleberg/vscode-innosetup@`2e7af99`/src/task.ts#L15-L33](https://github.com/idleberg/vscode-innosetup/blob/2e7af99808acde50920b8b16501dad2e51e0025d/src/task.ts#L16-L34) ，注意路径中对反斜杠的转义。

```json
{
  "version": "2.0.0",
  "tasks": [
    {
      "label": "Inno Setup: Compile Script",
      "type": "process",
      "command": "C:\\Inno Setup 6\\ISCC.exe",
      "args": [
        "/OC:\\output\\setup",
        "/DB4X_SourceCode_Directory=C:\\src\\BesLyric-for-X",
        "/DB4X_Binary_Directory=C:\\output\\release_bin",
        "${file}"
      ],
      "presentation": {
        "reveal": "always",
        "echo": false
      },
      "group": {
        "kind": "build",
        "isDefault": true
      }
    }
  ]
}
```
