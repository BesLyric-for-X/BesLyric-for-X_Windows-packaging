# BesLyric-for-X Deployment and Packaging Scripts (Windows)

## Introduction

The scripts in this repository are used to deploy and package BesLyric-for-X on Windows.

## Dependent tools

These tools are required to complete the work:

- PowerShell 5
- qmake (used by CQtDeployer)
- CQtDeployer 1.4.7.0
- Inno Setup 6.0.5 (u)
- Enigma Virtual Box v9.60 Build 20210209

## How to use

### Prerequisites

- Add the path to the parent directory of `qmake` to your `PATH` environment variable (use the same `qmake` as when building BesLyric-for-X).

### Get scripts

```shell
PS > git clone --recurse-submodules https://github.com/BesLyric-for-X/BesLyric-for-X_Windows_build-deploy-package.git
PS > #         \--------__--------/
PS > #              Important!
```

### Execute with a bunch of parameters

```powershell
$params = @{
    B4X_DEP_PATH                         = "<the B4X_DEP_PATH>"
    SOURCE_DIR_PATH                      = "<path to the source code's directory>"
    OUTPUT_EXE_DIR_PATH                  = "<path to the built exe's parent directory>"
    OUTPUT_EXE_FILE_BASENAME             = "<bas ename of the built exe>"

    # CQtDeployer.
    CQTDEPLOYER_PATH                     = "<path to Inno Setup's cqtdeployer.bat or .exe>"
    DEPLOYED_DIR_PATH                    = "<path to the directory contains exe and all dependant dlls>"

    # ZIP.
    ZIP_PACKAGE_FILE_PATH                = "<path to the created zip file>"

    # Inno Setup.
    ISCC_PATH                            = "<path to Inno Setup's ISCC.exe>"
    ISS_FILE_ENTRIES_INCLUDED_FILE_PATH  = "<path to the generated Inno Setup's section [Files] included file>"
    ISS_COMPRESSION                      = "<https://jrsoftware.org/ishelp/topic_setup_compression.htm>"
    OUTPUT_INSTALLER_FILE_PATH           = "<path to the created Inno Setup installer>"

    # Enigma Virtual Box.
    ENIGMAVBCONSOLE_PATH                 = "<path to Enigma Virtual Box's enigmavbconsole.exe>"
    EVB_PROJECT_FILE_PATH                = "<path to the generated Enigma Virtual Box project file>"
    EVB_COMPRESS_FILES                   = "<does Enigma Virtual Box compress files: $true or $false>"
    BOXED_EXE_FILE_PATH                  = "<path to Enigma Virtual Box's output boxed exe>"
}

& '.\main.ps1' @params
```

## Credits

Projects:

- [QuasarApp/CQtDeployer](https://github.com/QuasarApp/CQtDeployer)
- [Inno Setup - jrsoftware](https://jrsoftware.org/isinfo.php)
- [idleberg.innosetup - Inno Setup - Visual Studio Marketplace](https://marketplace.visualstudio.com/items?itemName=idleberg.innosetup)
- [alefragnani.pascal - Pascal - Visual Studio Marketplace](https://marketplace.visualstudio.com/items?itemName=alefragnani.pascal)
- [kira-96/Inno-Setup-Chinese-Simplified-Translation](https://github.com/kira-96/Inno-Setup-Chinese-Simplified-Translation)
- [Enigma Virtual Box](https://www.enigmaprotector.com/en/aboutvb.html)

Documentations:

- [PowerShell commands - PowerShell - SS64.com](https://ss64.com/ps/)
- [Free Pascal - Advanced open source Pascal compiler for Pascal and Object Pascal - Home Page.html](https://www.freepascal.org/)
- [Pascal Tutorial - Tutorialspoint](https://www.tutorialspoint.com/pascal/)
