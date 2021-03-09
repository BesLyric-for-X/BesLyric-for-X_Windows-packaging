
# https://riptutorial.com/powershell/example/17733/creating-an-xml-document-using-xmlwriter--
# https://docs.microsoft.com/en-us/dotnet/api/system.xml.xmlwriter
# https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_ref


param (
    [Parameter(Mandatory = $true)]
    [string]
    ${DEPLOYED_DIR_PATH},
    [Parameter(Mandatory = $true)]
    [string]
    ${EXE_FILE_PATH},
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


function Write-FilesInfoXml {
    param (
        [Parameter(Mandatory = $true)]
        [ref]
        ${XmlWriterRef},
        [Parameter(Mandatory = $true)]
        [string]
        ${Path}
    )

    process {
        [System.Xml.XmlWriter] ${innerXmlWriter} = ${xmlWriterRef}.Value

        Write-Output -InputObject "Entering   '${path}'"

        ${fileArray} = Get-ChildItem -Path ${path} -Attributes '!Directory'

        foreach (${file} in ${fileArray}) {
            ${filePath} = Join-Path -Path ${path} -ChildPath ${file}.Name

            Write-Output -InputObject "Found file '${filePath}'"

            # Don't package the main executable twice.
            if (${filePath} -eq ${EXE_FILE_PATH}) {
                continue
            }

            ${innerXmlWriter}.WriteStartElement('File')
            <##> ${innerXmlWriter}.WriteElementString('Type', 2)
            <##> ${innerXmlWriter}.WriteElementString('Name', ${file}.Name)
            <##> ${innerXmlWriter}.WriteElementString('File', ${filePath})
            ${innerXmlWriter}.WriteEndElement()
        }

        ${directoryArray} = Get-ChildItem -Path ${path} -Attributes 'Directory'

        foreach (${directory} in ${directoryArray}) {
            ${directoryPath} = Join-Path -Path ${path} -ChildPath ${directory}.Name

            Write-Output -InputObject "Found dir  '${directoryPath}'"

            ${innerXmlWriter}.WriteStartElement('File')
            <##> ${innerXmlWriter}.WriteElementString('Type', 3)
            <##> ${innerXmlWriter}.WriteElementString('Name', ${directory}.Name)
            <##> ${innerXmlWriter}.WriteStartElement('Files')
            <#  #> Write-FilesInfoXml -XmlWriterRef ([ref]${innerXmlWriter}) -Path ${directoryPath}
            <##> ${innerXmlWriter}.WriteEndElement()
            ${innerXmlWriter}.WriteEndElement()
        }

        Write-Output -InputObject "Leaving    '${path}'"
    }
}


${xmlSettings} = New-Object -TypeName 'System.Xml.XmlWriterSettings'
${xmlSettings}.Encoding = [System.Text.Encoding]::GetEncoding('windows-1252')
${xmlSettings}.Indent = $true
${xmlSettings}.IndentChars = '  ' # two spaces.

${xmlWriter} = [System.Xml.XmlWriter]::Create(${EVB_PROJECT_FILE_PATH}, ${xmlSettings})

${xmlWriter}.WriteStartDocument()
<##> ${xmlWriter}.WriteStartElement('UnnamedRootElement')
<#  #> ${xmlWriter}.WriteElementString('InputFile', ${EXE_FILE_PATH})
<#  #> ${xmlWriter}.WriteElementString('OutputFile', ${BOXED_EXE_FILE_PATH})
<#  #> ${xmlWriter}.WriteStartElement('Files')
<#    #> ${xmlWriter}.WriteElementString('Enabled', $true)
<#    #> ${xmlWriter}.WriteElementString('DeleteExtractedOnExit', $true)
<#    #> ${xmlWriter}.WriteElementString('CompressFiles', ${EVB_COMPRESS_FILES})
<#    #> ${xmlWriter}.WriteStartElement('Files')
<#      #> ${xmlWriter}.WriteStartElement('File')
<#        #> ${xmlWriter}.WriteElementString('Type', 3)
<#        #> ${xmlWriter}.WriteElementString('Name', '%DEFAULT FOLDER%')
<#        #> ${xmlWriter}.WriteStartElement('Files')
<#          #> Write-FilesInfoXml -XmlWriterRef ([ref]${xmlWriter}) -Path ${DEPLOYED_DIR_PATH}
<#        #> ${xmlWriter}.WriteEndElement()
<#      #> ${xmlWriter}.WriteEndElement()
<#    #> ${xmlWriter}.WriteEndElement()
<#  #> ${xmlWriter}.WriteEndElement()
<#  #> ${xmlWriter}.WriteStartElement('Options')
<#    #> ${xmlWriter}.WriteElementString('ShareVirtualSystem', $false)
<#    #> ${xmlWriter}.WriteElementString('MapExecutableWithTemporaryFile', $true)
<#    #> ${xmlWriter}.WriteElementString('AllowRunningOfVirtualExeFiles', $false)
<#  #> ${xmlWriter}.WriteEndElement()
<##> ${xmlWriter}.WriteEndElement()
${xmlWriter}.WriteEndDocument()

${xmlWriter}.Close()


Write-Output -InputObject ('-' * 42)
Write-Output -InputObject "Contents of '${EVB_PROJECT_FILE_PATH}':"
Get-Content -Path ${EVB_PROJECT_FILE_PATH}
Write-Output -InputObject ('-' * 42)
