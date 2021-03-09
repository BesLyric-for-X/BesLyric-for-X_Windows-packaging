
param(
    [Parameter(Mandatory = $true)]
    [string]
    ${BINARY_DIR_PATH},
    [Parameter(Mandatory = $true)]
    [string]
    ${ISS_FILE_ENTRIES_INCLUDED_FILE_PATH}
)


$ErrorActionPreference = 'Stop'


# Show parameters.
$PSBoundParameters | Format-List


# Constants.
${deployedDirPathPlaceholder} = '{#Deployed_Directory_Path}'
${innoSetupVariableApp} = '{app}'
${fileEntryTemplate} = 'Source: "{0}"; DestDir: "{1}"; Flags: ignoreversion'


${fileEntries} = New-Object -TypeName 'System.Collections.ArrayList'

# For the backward compatibility... `Get-ChildItem -File` is better.
${filePathArray} = Get-ChildItem -Path ${BINARY_DIR_PATH} -Recurse `
| Where-Object { -Not $_.PSIsContainer } `
| Select-Object -ExpandProperty 'FullName'

Push-Location -Path ${BINARY_DIR_PATH}

foreach (${filePath} in ${filePathArray}) {
    ${relativePath} = Resolve-Path -Path ${filePath} -Relative

    ${entrySource} = Join-Path `
        -Path ${deployedDirPathPlaceholder} `
        -ChildPath ${relativePath}

    ${entryDestDir} = Join-Path `
        -Path ${innoSetupVariableApp} `
        -ChildPath (Split-Path -Path ${relativePath} -Parent)

    ${fileEntry} = ${fileEntryTemplate} -f @(${entrySource}, ${entryDestDir})

    ${fileEntries}.Add(${fileEntry}) | Out-Null
}

Pop-Location

${fileEntries} | Out-File `
    -FilePath ${ISS_FILE_ENTRIES_INCLUDED_FILE_PATH} `
    -Encoding 'utf8' # Yes, we do need UTF-8-BOM.


Write-Output -InputObject ('-' * 42)
Write-Output -InputObject "Contents of '${ISS_FILE_ENTRIES_INCLUDED_FILE_PATH}':"
Get-Content -Path ${ISS_FILE_ENTRIES_INCLUDED_FILE_PATH}
Write-Output -InputObject ('-' * 42)
