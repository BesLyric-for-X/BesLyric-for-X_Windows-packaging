
param (
    [Parameter(Mandatory = $true)]
    [string]
    ${DEPLOYED_DIR_PATH},

    [Parameter(Mandatory = $true)]
    [string]
    ${ZIP_PACKAGE_FILE_PATH},

    [Parameter(Mandatory = $true)]
    [string]
    ${ISCC_PATH},
    [Parameter(Mandatory = $true)]
    [string]
    ${ISS_FILE_ENTRIES_INCLUDED_FILE_PATH},
    [Parameter(Mandatory = $true)]
    [string]
    ${SOURCE_DIR_PATH},
    [Parameter(Mandatory = $true)]
    [string]
    ${APP_NAME},
    [Parameter(Mandatory = $true)]
    [string]
    ${ISS_COMPRESSION},
    [Parameter(Mandatory = $true)]
    [string]
    ${OUTPUT_INSTALLER_FILE_PATH},

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


# Show parameters.
$PSBoundParameters | Format-List


try {
    Push-Location -Path (Split-Path -Path $MyInvocation.MyCommand.Path -Parent)


    # Zip it.

    $zipParameters = @{
        'Path'             = ${DEPLOYED_DIR_PATH}
        'DestinationPath'  = ${ZIP_PACKAGE_FILE_PATH}
        'Force'            = $true
        'CompressionLevel' = 'Optimal'
    }

    Compress-Archive @zipParameters


    # Generate the entries of Inno Setup's [Files] section.

    $issParameters = @{
        'BINARY_DIR_PATH'                     = ${DEPLOYED_DIR_PATH}
        'ISS_FILE_ENTRIES_INCLUDED_FILE_PATH' = ${ISS_FILE_ENTRIES_INCLUDED_FILE_PATH}
    }

    & '.\iss\iss_Files_section_included_files_generator.ps1' @issParameters


    # ISCC.exe it.
    # https://jrsoftware.org/ishelp/topic_compilercmdline.htm
    # https://jrsoftware.org/ispphelp/topic_isppcc.htm

    ${outputInstallerDirPath} = Split-Path -Path ${OUTPUT_INSTALLER_FILE_PATH} -Parent
    ${outputInstallerFileBaseName} = [System.IO.Path]::GetFileNameWithoutExtension(${OUTPUT_INSTALLER_FILE_PATH})

    & ${ISCC_PATH} `
        "/O${outputInstallerDirPath}" `
        "/F${outputInstallerFileBaseName}" `
        "/DSource_Directory_Path=${SOURCE_DIR_PATH}" `
        "/DDeployed_Directory_Path=${DEPLOYED_DIR_PATH}" `
        "/DMyAppName=${APP_NAME}" `
        "/DFilesSectionIncludedFilePath=${ISS_FILE_ENTRIES_INCLUDED_FILE_PATH}" `
        "/DMyCompression=${ISS_COMPRESSION}" `
        '.\iss\iss_main.iss'
    if (${LASTEXITCODE} -ne 0) {
        throw "${ISCC_PATH} failed."
    }


    # Generate Enigma Virtual Box project file.

    ${deployedExeFilePath} = Join-Path `
        -Path ${DEPLOYED_DIR_PATH} `
        -ChildPath "${APP_NAME}.exe"
    Write-Output -InputObject "deployedExeFilePath = ${deployedExeFilePath}"

    $evbProjectGeneratorParameters = @{
        'DEPLOYED_DIR_PATH'     = ${DEPLOYED_DIR_PATH}
        'EXE_FILE_PATH'         = ${deployedExeFilePath}
        'EVB_PROJECT_FILE_PATH' = ${EVB_PROJECT_FILE_PATH}
        'EVB_COMPRESS_FILES'    = ${EVB_COMPRESS_FILES}
        'BOXED_EXE_FILE_PATH'   = ${BOXED_EXE_FILE_PATH}
    }

    & '.\evb\evb_project_generator.ps1' @evbProjectGeneratorParameters


    # enigmavbconsole.exe it.
    & ${ENIGMAVBCONSOLE_PATH} ${EVB_PROJECT_FILE_PATH}
    if (${LASTEXITCODE} -ne 0) {
        throw "${ENIGMAVBCONSOLE_PATH} failed."
    }
}
finally {
    Pop-Location
}
