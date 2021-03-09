
# The main script.
#
# Long live ss64.com !
# https://ss64.com/ps/call.html
# https://stackoverflow.com/questions/51333183/powershell-executable-isnt-outputting-to-stdout
#
# https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_splatting
# https://devblogs.microsoft.com/scripting/use-splatting-to-simplify-your-powershell-scripts/


param (
    [Parameter(Mandatory = $true)]
    [string]
    ${B4X_DEP_PATH},

    # Build.
    [Parameter(Mandatory = $true)]
    [string]
    ${SOURCE_DIR_PATH},
    [Parameter(Mandatory = $true)]
    [string]
    ${OUTPUT_EXE_DIR_PATH},
    [Parameter(Mandatory = $true)]
    [string]
    ${OUTPUT_EXE_FILE_BASENAME},

    # CQtDeployer.
    [Parameter(Mandatory = $true)]
    [string]
    ${CQTDEPLOYER_PATH},
    [Parameter(Mandatory = $true)]
    [string]
    ${DEPLOYED_DIR_PATH},

    # ZIP.
    [Parameter(Mandatory = $true)]
    [string]
    ${ZIP_PACKAGE_FILE_PATH},

    # Inno Setup.
    [Parameter(Mandatory = $true)]
    [string]
    ${ISCC_PATH},
    [Parameter(Mandatory = $true)]
    [string]
    ${ISS_FILE_ENTRIES_INCLUDED_FILE_PATH},
    [Parameter(Mandatory = $true)]
    [string]
    ${ISS_COMPRESSION},
    [Parameter(Mandatory = $true)]
    [string]
    ${OUTPUT_INSTALLER_FILE_PATH},

    # Enigma Virtual Box.
    [Parameter(Mandatory = $true)]
    [string]
    ${ENIGMAVBCONSOLE_PATH},
    [Parameter(Mandatory = $true)]
    [string]
    ${EVB_PROJECT_FILE_PATH},
    [Parameter(Mandatory = $true)]
    [bool]
    ${EVB_COMPRESS_FILES},
    [Parameter(Mandatory = $true)]
    [string]
    ${BOXED_EXE_FILE_PATH}
)


$ErrorActionPreference = 'Stop'


Set-StrictMode -Version 3.0


# Show parameters.
$PSBoundParameters | Format-List


# Remove quotes from all path-like variables and normalize them.
#   https://stackoverflow.com/questions/495618/how-to-normalize-a-path-in-powershell
#   I didn't use `String.Trim("`"'")` because it looks confusing.
${B4X_DEP_PATH} = `
    [System.IO.Path]::GetFullPath(${B4X_DEP_PATH}.Trim('"').Trim("'"))

${SOURCE_DIR_PATH} = `
    [System.IO.Path]::GetFullPath(${SOURCE_DIR_PATH}.Trim('"').Trim("'"))
${OUTPUT_EXE_DIR_PATH} = `
    [System.IO.Path]::GetFullPath(${OUTPUT_EXE_DIR_PATH}.Trim('"').Trim("'"))

${CQTDEPLOYER_PATH} = `
    [System.IO.Path]::GetFullPath(${CQTDEPLOYER_PATH}.Trim('"').Trim("'"))
${DEPLOYED_DIR_PATH} = `
    [System.IO.Path]::GetFullPath(${DEPLOYED_DIR_PATH}.Trim('"').Trim("'"))

${ZIP_PACKAGE_FILE_PATH} = `
    [System.IO.Path]::GetFullPath(${ZIP_PACKAGE_FILE_PATH}.Trim('"').Trim("'"))

${ISCC_PATH} = `
    [System.IO.Path]::GetFullPath(${ISCC_PATH}.Trim('"').Trim("'"))
${ISS_FILE_ENTRIES_INCLUDED_FILE_PATH} = `
    [System.IO.Path]::GetFullPath(${ISS_FILE_ENTRIES_INCLUDED_FILE_PATH}.Trim('"').Trim("'"))
${OUTPUT_INSTALLER_FILE_PATH} = `
    [System.IO.Path]::GetFullPath(${OUTPUT_INSTALLER_FILE_PATH}.Trim('"').Trim("'"))

${ENIGMAVBCONSOLE_PATH} = `
    [System.IO.Path]::GetFullPath(${ENIGMAVBCONSOLE_PATH}.Trim('"').Trim("'"))
${EVB_PROJECT_FILE_PATH} = `
    [System.IO.Path]::GetFullPath(${EVB_PROJECT_FILE_PATH}.Trim('"').Trim("'"))
${BOXED_EXE_FILE_PATH} = `
    [System.IO.Path]::GetFullPath(${BOXED_EXE_FILE_PATH}.Trim('"').Trim("'"))



# Test part of the paths.
if (-Not (Test-Path -Path ${B4X_DEP_PATH} -PathType Container)) {
    throw "Directory '${B4X_DEP_PATH}' does not exist."
}

if (-Not (Test-Path -Path ${SOURCE_DIR_PATH} -PathType Container)) {
    throw "Directory '${SOURCE_DIR_PATH}' does not exist."
}
if (-Not (Test-Path -Path ${OUTPUT_EXE_DIR_PATH} -PathType Container)) {
    throw "Directory '${OUTPUT_EXE_DIR_PATH}' does not exist."
}

if (-Not (Test-Path -Path ${CQTDEPLOYER_PATH} -PathType Leaf)) {
    throw "File '${CQTDEPLOYER_PATH}' does not exist."
}
if (Test-Path -Path ${DEPLOYED_DIR_PATH} -PathType Container) {
    throw "Should not deploy files into '${DEPLOYED_DIR_PATH}' because this path points to an existing item."
}

if (-Not (Test-Path -Path ${ISCC_PATH} -PathType Leaf)) {
    throw "File '${ISCC_PATH}' does not exist."
}

if (-Not (Test-Path -Path ${ENIGMAVBCONSOLE_PATH} -PathType Leaf)) {
    throw "File '${ENIGMAVBCONSOLE_PATH}' does not exist."
}


# Common variables.
${b4xDepBinPath} = `
    Join-Path -Path ${B4X_DEP_PATH} -ChildPath '\bin'
${outputExeFilePath} = `
    Join-Path -Path ${OUTPUT_EXE_DIR_PATH} -ChildPath "${OUTPUT_EXE_FILE_BASENAME}.exe"


# Test part of the paths.
if (-Not (Test-Path -Path ${b4xDepBinPath} -PathType Container)) {
    throw "File '${b4xDepBinPath}' does not exist."
}
if (-Not (Test-Path -Path ${outputExeFilePath} -PathType Leaf)) {
    throw "File '${outputExeFilePath}' does not exist."
}


try {
    Push-Location -Path (Split-Path -Path $MyInvocation.MyCommand.Path -Parent)


    # # Build it.
    # $buildParameters = @{
    #     'B4X_DEP_PATH'        = ${B4X_DEP_PATH}
    #     'SOURCE_DIR_PATH'     = ${SOURCE_DIR_PATH}
    #     'OUTPUT_DIR_PATH'     = ${OUTPUT_EXE_DIR_PATH}
    #     'OUTPUT_EXE_BASENAME' = ${OUTPUT_EXE_FILE_BASENAME}
    # }

    # & '.\build\qmake-make.ps1' @buildParameters


    # CQtDeployer it.
    $deployParameters = @{
        'LIB_DIR_PATH'      = ${b4xDepBinPath}
        'CQTDEPLOYER_PATH'  = ${CQTDEPLOYER_PATH}
        'DEPLOYED_DIR_PATH' = ${DEPLOYED_DIR_PATH}
        'BIN_PATH'          = ${outputExeFilePath}
    }

    & '.\deploy\cqtdeployer.ps1' @deployParameters


    # Package it.
    $packageParameters = @{
        'DEPLOYED_DIR_PATH'                   = ${DEPLOYED_DIR_PATH}

        'ZIP_PACKAGE_FILE_PATH'               = ${ZIP_PACKAGE_FILE_PATH}

        'ISCC_PATH'                           = ${ISCC_PATH}
        'ISS_FILE_ENTRIES_INCLUDED_FILE_PATH' = ${ISS_FILE_ENTRIES_INCLUDED_FILE_PATH}
        'SOURCE_DIR_PATH'                     = ${SOURCE_DIR_PATH}
        'APP_NAME'                            = ${OUTPUT_EXE_FILE_BASENAME}
        'ISS_COMPRESSION'                     = ${ISS_COMPRESSION}
        'OUTPUT_INSTALLER_FILE_PATH'          = ${OUTPUT_INSTALLER_FILE_PATH}

        'ENIGMAVBCONSOLE_PATH'                = ${ENIGMAVBCONSOLE_PATH}
        'EVB_PROJECT_FILE_PATH'               = ${EVB_PROJECT_FILE_PATH}
        'EVB_COMPRESS_FILES'                  = ${EVB_COMPRESS_FILES}
        'BOXED_EXE_FILE_PATH'                 = ${BOXED_EXE_FILE_PATH}
    }

    & '.\package\_package.ps1' @packageParameters
}
finally {
    Pop-Location
}
