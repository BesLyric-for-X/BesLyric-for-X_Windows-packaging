; UTF-8 with BOM is required.


#ifndef Source_Directory_Path
    #error 'The variable "Source_Directory_Path" is NOT #defined.'
#else
    #define Source_Directory_Path RemoveBackslash(Source_Directory_Path)
    #pragma message "Source_Directory_Path = " + Source_Directory_Path
#endif

#ifndef Deployed_Directory_Path
    #error 'The variable "Deployed_Directory_Path" is NOT #defined.'
#else
    #define Deployed_Directory_Path RemoveBackslash(Deployed_Directory_Path)
    #pragma message "Deployed_Directory_Path = " + Deployed_Directory_Path
#endif

#ifndef Included_Files_Section_Entries_File_Path
    #error 'The variable "Included_Files_Section_Entries_File_Path" is NOT #defined.'
#endif

#ifndef MyAppName
    #error 'The variable "MyAppName" is NOT #defined.'
#endif

#ifndef MyCompression
    #error 'The variable "MyCompression" is NOT #defined.'
#endif


#define MyAppExeName MyAppName + ".exe"
#define MyAppExePath AddBackslash(Deployed_Directory_Path) + MyAppExeName
#define MyAppPublisher GetFileCompany(MyAppExePath)

#define MyAppPublisherURL "https://github.com/BesLyric-for-X"
#define MyAppSupportURL "https://github.com/BesLyric-for-X/BesLyric-for-X/issues"
#define MyAppUpdatesURL "https://github.com/BesLyric-for-X/BesLyric-for-X/releases"

; #define B4X_App_Four_Numbers_Version GetFileVersionString(MyAppExePath)
#define B4X_App_Four_Numbers_Version GetFileProductVersion(MyAppExePath)
; #define B4X_App_Three_Numbers_Version GetFileProductVersion(MyAppExePath)
#define B4X_App_Three_Numbers_Version RemoveFileExt(B4X_App_Four_Numbers_Version)

#pragma message "B4X_App_Four_Numbers_Version = " + B4X_App_Four_Numbers_Version
#pragma message "B4X_App_Three_Numbers_Version = " + B4X_App_Three_Numbers_Version


[Setup]
AppId={{792F57C8-A564-47B1-B01C-A4DD3B43C22F}

AppName={#MyAppName}

AppVersion={#B4X_App_Three_Numbers_Version}
VersionInfoVersion={#B4X_App_Four_Numbers_Version}

AppPublisher={#MyAppPublisher}

AppPublisherURL={#MyAppPublisherURL}
AppSupportURL={#MyAppSupportURL}
AppUpdatesURL={#MyAppUpdatesURL}

DisableProgramGroupPage=yes

PrivilegesRequired=lowest

OutputBaseFilename={#MyAppName}_{#B4X_App_Three_Numbers_Version}_Setup

SetupIconFile={#Source_Directory_Path}\BesLyric.ico

; Worth it?
Compression={#MyCompression}

WizardStyle=modern

; Modify the icon in "Apps & features"
; https://stackoverflow.com/questions/20792468/inno-setup-control-panel-icon-does-not-show
UninstallDisplayIcon="{app}\{#MyAppExeName}"

; Show information before installation.
InfoBeforeFile={#Source_Directory_Path}\version.txt

ShowLanguageDialog=yes

; x86 is dying.
;ArchitecturesInstallIn64BitMode=x64 arm64
;ArchitecturesAllowed=x64 arm64

; For the first-time installtion, I will generate a path pointing to
;   %LOCALAPPDATA%\Programs\{#MyAppName}.
DefaultDirName={code:GetDefaultDirName}
; This guy cannot handle the situation where the old installation run
;   with administrator privileges and the new installation run
;   without administrator privileges, and vice versa. In other words,
;   the previous application installation path (AppDir) will be used
;   anyway.
UsePreviousAppDir=yes

; https://stackoverflow.com/questions/28628699/inno-setup-prevent-executing-the-installer-multiple-times-simultaneously
SetupMutex=SetupMutex{#SetupSetting("AppId")}

; In commandline mode, shut it down automatically, and don't restart.
CloseApplications=yes
RestartApplications=no

; Log is important.
SetupLogging=yes


[Languages]  
Name: "zh_CN"; MessagesFile: "zh_CN\ChineseSimplified.isl"
Name: "english"; MessagesFile: "compiler:Default.isl"


[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; 


[Icons]
Name: "{autoprograms}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon


[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "{cm:LaunchProgram,{#StringChange(MyAppName, '&', '&&')}}"; Flags: nowait postinstall skipifsilent


[Files]
#include Str(Included_Files_Section_Entries_File_Path)

; NOTE: Don't use "Flags: ignoreversion" on any shared system files


[CustomMessages]
zh_CN.cm_StopAndKillProcessOfSpecificPath_Failed=无法关闭程序 %1%n错误代码：%2（%3）
zh_CN.cm_UninstallPreviousInstallation_Failed=无法调用卸载程序 %1%n错误代码：%2（%3）
zh_CN.cm_ProcessPreviousInstallation_Failed=无法处理在 %1 的旧安装。%n原因：%n%2%n%n安装程序不能继续。
zh_CN.cm_RunAsAdministrator=您不应该使用管理员权限运行本安装程序。%n%n一定要继续吗？
zh_CN.cm_UACDeniedProbably=您似乎拒绝了卸载程序对管理员权限的请求。%n没有管理员权限将无法卸载旧的安装，您是否要再试一次？

english.cm_StopAndKillProcessOfSpecificPath_Failed=Failed to close %1%ncode: %2 (%3)
english.cm_UninstallPreviousInstallation_Failed=Failed to call uninstaller %1%ncode: %2 (%3)
english.cm_ProcessPreviousInstallation_Failed=Failed to process previous installation in %1.%nReason:%n%2%n%nSetup cannot continue.
english.cm_RunAsAdministrator=You should not run this installer with administrator rights.%n%nContinue anyway?
english.cm_UACDeniedProbably=It appears that you have rejected the uninstaller’s request for administrator privileges.%nThe old installation cannot be uninstalled without administrator rights. Do you want to try again?

cm_Gitter=Gitter
cm_Gitee=Gitee
cm_GitHub=GitHub

zh_CN.cm_QQGroup=QQ 群：1021317114
english.cm_QQGroup=QQ Group: 1021317114

zh_CN.cm_GetHelp=获取帮助：
zh_CN.cm_RepositoryPages=项目源代码：

english.cm_GetHelp=Get help:
english.cm_RepositoryPages=Source code of this project:

cm_Gitee_URL=https://gitee.com/BesLyric-for-X
cm_GitHub_URL=https://github.com/BesLyric-for-X
cm_Gitter_URL=https://gitter.im/BesLyric-for-X_org
cm_QQGroup_URL=https://shang.qq.com/wpa/qunwpa?idkey=90548f8500d6f5b5fd9b6ee89684206053b709b6309a0dc807cdb4cd8704a78e


[Code]
#include "iss_Code.pas"
