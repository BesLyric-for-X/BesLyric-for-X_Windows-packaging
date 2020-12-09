
# Long live ss64.com !


param(
    [Parameter(Mandatory = $true)]
    [string]
    ${Binary_Directory},
    [Parameter(Mandatory = $true)]
    [string]
    ${Included_Files_Section_Entries_File_Path}
)


$ErrorActionPreference = 'Stop'


# Show parameters
$PSBoundParameters | Format-List


${const_string_InnoSetup_variable_App} = '{app}'
${const_string_File_entry} = 'Source: "{0}"; DestDir: "{1}"; Flags: ignoreversion'
${const_string_deployedDirPathPlaceholder} = '{#Deployed_Directory_Path}'


${array_string_InnoSetup_section_File_entries} = New-Object -TypeName 'System.Collections.ArrayList'

${filePathArray} = Get-ChildItem -Recurse -Path ${Binary_Directory} `
| Where-Object { ! $_.PSIsContainer } `
| Select-Object -ExpandProperty FullName

Push-Location -Path ${Binary_Directory}

    foreach (${filePath} in ${filePathArray}) {
        ${string_relative_path} = Resolve-Path -Path ${filePath} -Relative

        ${string_InnoSetup_section_File_property_Source} = Join-Path `
            -Path ${const_string_deployedDirPathPlaceholder} `
            -ChildPath ${string_relative_path}

        ${string_InnoSetup_section_File_property_DestDir} = Join-Path `
            -Path ${const_string_InnoSetup_variable_App} `
            -ChildPath (Split-Path -Path ${string_relative_path} -Parent)

        ${entry} = ${const_string_File_entry} -f `
            ${string_InnoSetup_section_File_property_Source}, `
            ${string_InnoSetup_section_File_property_DestDir}

        ${array_string_InnoSetup_section_File_entries}.Add(${entry}) > $null
    }

Pop-Location    

${array_string_InnoSetup_section_File_entries} `
| Out-File -FilePath ${Included_Files_Section_Entries_File_Path} -Encoding utf8 # Yes, we do need UTF-8-BOM.

Exit 0
