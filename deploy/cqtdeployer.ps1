
param (
    [Parameter(Mandatory = $true)]
    [string]
    ${LIB_DIR_PATH},
    [Parameter(Mandatory = $true)]
    [string]
    ${CQTDEPLOYER_PATH},
    [Parameter(Mandatory = $true)]
    [string]
    ${DEPLOYED_DIR_PATH},
    [Parameter(Mandatory = $true)]
    [string]
    ${BIN_PATH}
)


$ErrorActionPreference = 'Stop'


# Show parameters.
$PSBoundParameters | Format-List


${libsslFilePath} = Join-Path `
    -Path ${LIB_DIR_PATH} `
    -ChildPath 'libssl-1_1-x64.dll'
${libcryptoFilePath} = Join-Path `
    -Path ${LIB_DIR_PATH} `
    -ChildPath 'libcrypto-1_1-x64.dll'

if (-Not (Test-Path -Path ${libsslFilePath} -PathType Leaf)) {
    throw "File '${libsslFilePath}' does not exist."
}
if (-Not (Test-Path -Path ${libcryptoFilePath} -PathType Leaf)) {
    throw "File '${libcryptoFilePath}' does not exist."
}

Write-Output -InputObject "libsslFilePath = ${libsslFilePath}"
Write-Output -InputObject "libcryptoFilePath = ${libcryptoFilePath}"


# CQtDeployer -bin "all,deployable,files"
#   https://github.com/QuasarApp/CQtDeployer/issues/394

& ${CQTDEPLOYER_PATH} `
    '-bin' "${BIN_PATH},${libsslFilePath},${libcryptoFilePath}" `
    '-targetDir' ${DEPLOYED_DIR_PATH} `
    '-libDir' ${LIB_DIR_PATH} `
    '-verbose' '3' `
    'noTranslations' 'clear'
if (${LASTEXITCODE} -ne 0) {
    throw "${CQTDEPLOYER_PATH} failed."
}

#
# & ${CQTDEPLOYER_PATH} `
#     '-bin', "${BIN_PATH},${libsslFilePath},${libcryptoFilePath}", `
#     '-targetDir', ${DEPLOYED_DIR_PATH}, `
#     '-libDir', ${LIB_DIR_PATH}, `
#     '-verbose', '3', `
#     'noTranslations', 'clear'
#
# Note:
#   The above code works on PowerShell 5, but not on 6 and 7. I think
#   this is because the mechanism of array parameter parsing in
#   PowerShell has been changed since PowerShell 6, but I didn't found
#   any no documentation about it.
#
# "&" is the Call Operator: https://ss64.com/ps/call.html
#
#
# You can use EchoArgs to check the actual passed-in parameters.
#
