
# The main script.
# https://ss64.com/ps/call.html
# https://stackoverflow.com/questions/51333183/powershell-executable-isnt-outputting-to-stdout


param (
    # Inno Setup
    [Parameter(Mandatory = $true)]
    [string]
    ${ISCC_PATH},
    [Parameter(Mandatory = $true)]
    [string]
    ${DEPLOYED_DIR_PATH},
    [Parameter(Mandatory = $true)]
    [string]
    ${EXE_FILE_BASENAME},
    [Parameter(Mandatory = $true)]
    [string]
    ${INSTALLER_OUTPUT_DIR_PATH},
    [Parameter(Mandatory = $true)]
    [string]
    ${SOURCE_DIR_PATH},
    [Parameter(Mandatory = $true)]
    [string]
    ${Included_Files_Section_Entries_File_Path},
    [Parameter(Mandatory = $true)]
    [string]
    ${ISS_COMPRESSION},

    # Enigma Virtual Box    
    [Parameter(Mandatory = $true)]
    [string]
    ${ENIGMAVBCONSOLE_PATH},
    [Parameter(Mandatory = $true)]
    [string]
    ${EVB_PROJECT_FILE_PATH},
    [Parameter(Mandatory = $true)]
    [string]
    ${BOXED_EXE_FILE_PATH},
    [Parameter(Mandatory = $true)]
    [bool]
    ${COMPRESS_FILES}
)


$ErrorActionPreference = 'Stop'


# Show parameters
$PSBoundParameters | Format-List


# Test paths.
if (-Not (Test-Path -Path ${DEPLOYED_DIR_PATH} -PathType 'Container')) {
    throw "The directory '${DEPLOYED_DIR_PATH}' does not exist."
}


# Get main executable path.
${exeFilePath} = Join-Path -Path ${DEPLOYED_DIR_PATH} -ChildPath "${EXE_FILE_BASENAME}.exe"

Write-Output -InputObject "exeFilePath: ${exeFilePath}"

if (-Not (Test-Path -Path ${exeFilePath} -PathType 'Leaf')) {
    throw "The file '${exeFilePath}' does not exist."
}


# Generate the entries of Inno Setup's [Files] section.
& '.\iss\iss_Files_section_included_files_generator.ps1' `
    -Binary_Directory ${DEPLOYED_DIR_PATH} `
    -Included_Files_Section_Entries_File_Path ${Included_Files_Section_Entries_File_Path}


# Generate Enigma Virtual Box project file.
& '.\evb\evb_project_generator.ps1' `
    -DEPLOYED_DIR_PATH ${DEPLOYED_DIR_PATH} `
    -EXE_FILE_PATH ${exeFilePath} `
    -EVB_PROJECT_FILE_PATH ${EVB_PROJECT_FILE_PATH} `
    -BOXED_EXE_FILE_PATH ${BOXED_EXE_FILE_PATH} `
    -COMPRESS_FILES ${COMPRESS_FILES}


# ISCC.exe it.
& ${ISCC_PATH} `
    "/O${INSTALLER_OUTPUT_DIR_PATH}" `
    "/DSource_Directory_Path=${SOURCE_DIR_PATH}" `
    "/DDeployed_Directory_Path=${DEPLOYED_DIR_PATH}" `
    "/DMyAppName=${EXE_FILE_BASENAME}" `
    "/DIncluded_Files_Section_Entries_File_Path=${Included_Files_Section_Entries_File_Path}" `
    "/DMyCompression=${ISS_COMPRESSION}" `
    'iss\iss_main.iss'
if ($LASTEXITCODE -ne 0) {
    throw 'ISCC.exe failed.'
}


# enigmavbconsole.exe it.
& ${ENIGMAVBCONSOLE_PATH} ${EVB_PROJECT_FILE_PATH}
if ($LASTEXITCODE -ne 0) {
    throw 'enigmavbconsole.exe failed.'
}
