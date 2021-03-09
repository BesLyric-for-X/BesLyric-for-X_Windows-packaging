
param (
    [Parameter(Mandatory = $true)]
    [string]
    ${B4X_DEP_PATH},
    [Parameter(Mandatory = $true)]
    [string]
    ${SOURCE_DIR_PATH},
    [Parameter(Mandatory = $true)]
    [string]
    ${OUTPUT_DIR_PATH},
    [Parameter(Mandatory = $true)]
    [string]
    ${OUTPUT_EXE_BASENAME}
)


$ErrorActionPreference = 'Stop'


# Show parameters.
$PSBoundParameters | Format-List


try {
    Push-Location -Path ${OUTPUT_DIR_PATH}

    if (Test-Path -Path '.qmake.stash' -PathType Leaf) {
        Remove-Item -Path '.qmake.stash'
    }

    & 'qmake.exe' `
        '-makefile' `
        '-o' 'Makefile' `
        '-spec' 'win32-g++' `
        '-before' `
        "B4X_DEP_PATH=${B4X_DEP_PATH}" `
        '-after' `
        "TARGET=${OUTPUT_EXE_BASENAME}" `
        "DESTDIR=${OUTPUT_DIR_PATH}" `
        'CONFIG+=release' `
        ${SOURCE_DIR_PATH}
    if (${LASTEXITCODE} -ne 0) {
        throw 'qmake.exe failed.'
    }

    # https://stackoverflow.com/questions/39274324/get-total-number-of-cores-from-a-computer-without-hyperthreading
    & 'mingw32-make.exe' `
        '-f' 'Makefile' `
        'release' `
        "-j$((Get-CimInstance -ClassName 'Win32_ComputerSystem').NumberOfLogicalProcessors)"
    if (${LASTEXITCODE} -ne 0) {
        throw 'mingw32-make.exe failed.'
    }
}
finally {
    Pop-Location
}
