
// https://wiki.freepascal.org/
// https://www.tutorialspoint.com/pascal/

// Syntax
// https://stackoverflow.com/questions/28221394/proper-structure-syntax-for-delphi-pascal-if-then-begin-end-and

// Migrate files from old directory
// https://stackoverflow.com/questions/2000296/inno-setup-how-to-automatically-uninstall-previous-installed-version#answer-2099805
// https://stackoverflow.com/questions/6345920/inno-setup-how-to-abort-terminate-setup-during-install
// https://stackoverflow.com/questions/13921535/skipping-custom-pages-based-on-optional-components-in-inno-setup

// Constant declaration
// https://stackoverflow.com/questions/18771167/why-we-cannot-declare-local-const-variables-in-inno-setup-code

// https://stackoverflow.com/questions/28342666/how-do-i-use-multiple-files-with-the-same-name-with-extracttemporaryfile
// https://jrsoftware.org/ishelp/index.php?topic=isxfunc_extracttemporaryfile

// https://stackoverflow.com/questions/31106514/inno-setup-loop-from-a-to-z

// ---

// https://answers.microsoft.com/en-us/windows/forum/all/wow6432node-registry-startups/481d4851-720f-4084-b1f1-8472c0eb842d
// https://stackoverflow.com/questions/45569783/inno-setup-ignoring-registry-redirection
// https://docs.microsoft.com/en-us/windows/win32/winprog64/shared-registry-keys
//   It seems that HKCU64 for the SOFTWARE Key is meaningless? Is HKCU enough?
//   I think using HKCU32 and HKCU64 instead of HKCU is not a big problem.

// For `Exec`, returnCode == 1 (ERROR_INVALID_FUNCTION), when I refused to run the uninstaller in UAC prompt.
//   https://docs.microsoft.com/en-us/windows/win32/debug/system-error-codes--0-499-

const
    const_string_AppId = '{792F57C8-A564-47B1-B01C-A4DD3B43C22F}';
    const_string_RegistryKeyName = const_string_AppId + '_is1';
    const_string_RegistryKeyPath =
        'Software\Microsoft\Windows\CurrentVersion\Uninstall\'
        + const_string_RegistryKeyName;
    const_string_RegistryValueName_UninstallString = 'UninstallString';
    const_string_RegistryValueName_InstallLocation = 'InstallLocation';
    const_string_UninstallArguments =
        '/VERYSILENT /NORESTART /SUPPRESSMSGBOXES';
    const_string_DirName_Data = 'data';
    const_string_FileName_lyricList = 'lyricList.xml';
    const_string_FileName_setting = 'setting.xml';

    // https://stackoverflow.com/questions/24661916/innosetup-how-to-add-line-break-into-component-description
    const_string_NewLine = #13#10; // <CR><LF>

    const_integer_MaximumDirLength = 100; // characters

var
    global_boolean_CancelWithoutPrompt: Boolean;


function RootKeyToStr(const integer_RootKey: Integer): String;
begin
    Result := IntToStr(integer_RootKey); // fallback

    case (integer_RootKey) of
        HKCU:   Result := 'HKCU';
        HKCU32: Result := 'HKCU32';
        HKCU64: Result := 'HKCU64';
        HKLM:   Result := 'HKLM';
        HKLM32: Result := 'HKLM32';
        HKLM64: Result := 'HKLM64';
    end;
end;


function FmtCustomMessage(
    const
        string_MsgName: String;
        stringArray_Args: array of String
): String;
begin
    Result := FmtMessage(
        CustomMessage(string_MsgName),
        stringArray_Args
    );
    // type mismatch ???
    // Why ?
    // Pass array as parameter?
end;


function GetCleanPath(const string_DirPath_Path: String): String;
begin
    Result := RemoveBackslash(RemoveQuotes(string_DirPath_Path));
end;


function GetConcatenatedCleanPath(
    const
        string_DirPath_Base,
        string_DirName_or_FileName_RelativePath: String
): String;
begin
    Result := GetCleanPath(string_DirPath_Base);

    string_DirName_or_FileName_RelativePath :=
        Trim(string_DirName_or_FileName_RelativePath);

    if (Length(string_DirName_or_FileName_RelativePath) > 0) then
        Result :=
            AddBackslash(Result)
            + GetCleanPath(string_DirName_or_FileName_RelativePath);
end;


procedure MigrateData(const string_DirPath_B4X_InstallLocation: String);
var
    string_DirPath_Data_old,
    string_DirPath_Data_new: String;

    string_FilePath_lyricList_old,
    string_FilePath_setting_old,
    string_FilePath_lyricList_new,
    string_FilePath_setting_new: String;
begin
    string_DirPath_Data_old :=
        GetConcatenatedCleanPath(
            string_DirPath_B4X_InstallLocation,
            const_string_DirName_Data
        );

    Log('MigrateData(' + string_DirPath_Data_old);

    if not (DirExists(string_DirPath_Data_old)) then
    begin
        Log('DirExists(' + string_DirPath_Data_old + ' false, exit.');
        Exit;
    end;

    string_FilePath_lyricList_old :=
        GetConcatenatedCleanPath(
            string_DirPath_Data_old,
            const_string_FileName_lyricList
        );
    string_FilePath_setting_old :=
        GetConcatenatedCleanPath(
            string_DirPath_Data_old,
            const_string_FileName_setting
        );

    string_DirPath_Data_new :=
        GetConcatenatedCleanPath(
            ExpandConstant('{localappdata}'),
            '{#MyAppName}'
        );
    string_FilePath_lyricList_new :=
        GetConcatenatedCleanPath(
            string_DirPath_Data_new,
            const_string_FileName_lyricList
        );
    string_FilePath_setting_new :=
        GetConcatenatedCleanPath(
            string_DirPath_Data_new,
            const_string_FileName_setting
        );

    // Create the tree.
    if not (ForceDirectories(string_DirPath_Data_new)) then
    begin
        Log('ForceDirectories(' + string_DirPath_Data_new + ' failed.');
        Exit;
    end;

    Log(
        'Moving ' + const_string_NewLine
        + string_FilePath_lyricList_old + const_string_NewLine
        + ' to ' + const_string_NewLine
        + string_FilePath_lyricList_new);
    FileCopy(
        string_FilePath_lyricList_old,
        string_FilePath_lyricList_new,
        False // Overwrite it.
    );
    DeleteFile(string_FilePath_lyricList_old);

    Log(
        'Moving ' + const_string_NewLine
        + string_FilePath_setting_old + const_string_NewLine
        + ' to ' + const_string_NewLine
        + string_FilePath_setting_new);
    FileCopy(
        string_FilePath_setting_old,
        string_FilePath_setting_new,
        False // Overwrite it.
    );
    DeleteFile(string_FilePath_setting_old);

    // Remove old stuff.
    Log('RemoveOldDataDir(' + string_DirPath_Data_old);

    RemoveDir(string_DirPath_Data_old);
end;


function FindRegistryInfo(
    const
        integer_RootKey: Integer;
    var
        string_RegistryData_UninstallString,
        string_RegistryData_InstallLocation: String
): Boolean;
var
    string_RegistryData_UninstallString_quoted,
    string_RegistryData_InstallLocation_with_backslash: String;
begin
    Result := False;

    if RegQueryStringValue(
        integer_RootKey,
        const_string_RegistryKeyPath,
        const_string_RegistryValueName_UninstallString,
        string_RegistryData_UninstallString_quoted
    )
    and RegQueryStringValue(
        integer_RootKey,
        const_string_RegistryKeyPath,
        const_string_RegistryValueName_InstallLocation,
        string_RegistryData_InstallLocation_with_backslash
    ) then
    begin
        Result := True;

        string_RegistryData_UninstallString :=
            GetCleanPath(
                string_RegistryData_UninstallString_quoted
            );
        string_RegistryData_InstallLocation :=
            GetCleanPath(
                string_RegistryData_InstallLocation_with_backslash
            );

        Log(
            'FindRegistryInfo(' + RootKeyToStr(integer_RootKey)
            + const_string_NewLine
            + 'string_RegistryData_UninstallString: '
            + string_RegistryData_UninstallString + const_string_NewLine
            + 'string_RegistryData_InstallLocation: '
            + string_RegistryData_InstallLocation
        );
    end
    else
    begin
        Result := False;

        string_RegistryData_UninstallString := '';
        string_RegistryData_InstallLocation := '';

        Log(
            'FindRegistryInfo('
            + RootKeyToStr(integer_RootKey)
            + ' failed'
        );
    end;
end;


function StopAndKillProcessOfSpecificPath(
    const
        string_FilePath_Executable: String
): Integer;
begin
    // https://superuser.com/questions/52159/kill-a-process-with-a-specific-command-line-from-command-line
    // https://stackoverflow.com/questions/13524303/taskkill-to-differentiate-2-images-by-path
    //
    // Unless specified, all operators are case-insensitive.
    //   https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/where-object
    //
    // Although Inno Setup can automatically close (not forcibly) the program to be overwritten,
    //   it cannot close the program that will not be overwritten but belongs to the specific registry key.
    //
    // Double single quotes to escape a single quote.

    string_FilePath_Executable :=
        GetCleanPath(string_FilePath_Executable);

    Exec(
        // 'powershell.exe',
        // '-Command "& { Get-WmiObject Win32_Process | Where-Object { $_.Path -eq '''
        //     + string_FilePath_Executable
        //     + ''' } | ForEach-Object { $_.Terminate() } }"',

        //'powershell.exe',
        //'-Command "& { Get-Process | Where-Object { $_.Path -eq '''
        //    + string_FilePath_Executable
        //    + ''' } | ForEach-Object { $_.CloseMainWindow() } }"',

        // Stop the process gently first.
        'powershell.exe',
        '   -Command "& {                                                   '
        + '     Get-Process |                                               '
        + '     Where-Object {                                              '
        + '         $_.Path -eq ''' + string_FilePath_Executable + '''      '
        + '     } |                                                         '
        + '     ForEach-Object {                                            '
        + '         Write-Host "Stopping $_.Path ...";                      '
        + '         $remainingTrialCount = 50;                              '
        + '         While ($remainingTrialCount -gt 0 -And !$_.HasExited) { '
        + '             $_.CloseMainWindow();                               '
        + '             Start-Sleep -Milliseconds 100;                      '
        + '             $remainingTrialCount--;                             '
        + '             Write-Host "Countdown: $remainingTrialCount";       '
        + '         };                                                      '
        + '         Stop-Process -Force -Id $_.Id                           '
        + '     }                                                           '
        + ' }"                                                              ',
        '',
        SW_HIDE,
        ewWaitUntilTerminated,
        Result
    );

    Log(
        'StopAndKillProcessOfSpecificPath('
        + string_FilePath_Executable + const_string_NewLine
        + 'Code: ' + IntToStr(Result) + ' ' + SysErrorMessage(Result)
    );
end;


function ProccessRegisryInfo(
    const
        integer_RootKey: Integer;
    var
        string_ErrorMessage: String
): Integer;
var
    string_FilePath_B4X_EXE,
    string_DirPath_Parent_of_B4X_InstallLocation: String;

    string_FilePath_B4X_UninstallString,
    string_DirPath_B4X_InstallLocation: String;
begin
    Result := 0;

    if not (FindRegistryInfo(
        integer_RootKey,
        string_FilePath_B4X_UninstallString,
        string_DirPath_B4X_InstallLocation)
    ) then
        Exit;

    string_FilePath_B4X_EXE :=
        GetConcatenatedCleanPath(
            string_DirPath_B4X_InstallLocation,
            '{#MyAppExeName}'
        );

    Result := StopAndKillProcessOfSpecificPath(string_FilePath_B4X_EXE);

    // Powershell goes wrong?
    if (Result <> 0) then
    begin
        string_ErrorMessage :=
            FmtMessage(
                CustomMessage(
                    'cm_StopAndKillProcessOfSpecificPath_Failed'
                ), [
                    string_FilePath_B4X_EXE,
                    IntToStr(Result),
                    SysErrorMessage(Result)
                ]
            );
        Exit;
    end;

    // Uninstall old installation.
    //
    // It's a one-time loop, if no errors occur.
    repeat

        Exec(
            string_FilePath_B4X_UninstallString,
            const_string_UninstallArguments,
            '',
            SW_SHOWNORMAL,
            ewWaitUntilTerminated,
            Result
        );
        Log(
            'Called '
            + string_FilePath_B4X_UninstallString + const_string_NewLine
            + 'Code: ' + IntToStr(Result) + ' ' + SysErrorMessage(Result)
        );

        // Failed to uninstall.
        if (Result <> 0) then
        begin
            // UAC denied probably.
            if (Result = 1) then
            begin
                if (MsgBox(
                    CustomMessage('cm_UACDeniedProbably'),
                    mbInformation,
                    MB_YESNO or MB_SETFOREGROUND
                ) = IDYES)
                then
                    continue; // go to the conditional test.
            end;

            // Other cases.
            string_ErrorMessage :=
                FmtMessage(
                    CustomMessage(
                        'cm_UninstallPreviousInstallation_Failed'
                    ), [
                        string_FilePath_B4X_UninstallString,
                        IntToStr(Result),
                        SysErrorMessage(Result)
                    ]
                );
            Exit;
        end;

    until (Result = 0);

    // Migrate datas from `data/` directory, only once.
    MigrateData(string_DirPath_B4X_InstallLocation);

    // Remove empty old installation directory.
    RemoveDir(string_DirPath_B4X_InstallLocation);

    // Remove directory `BesStudio` (the parent directory of the empty old installation directory).
    string_DirPath_Parent_of_B4X_InstallLocation :=
        ExtractFileDir(string_DirPath_B4X_InstallLocation);

    if (ExtractFileName(
        string_DirPath_Parent_of_B4X_InstallLocation) = 'BesStudio'
    ) then
        RemoveDir(string_DirPath_Parent_of_B4X_InstallLocation);
end;


// Invalid prototype for 'GetDefaultDirName'
//   https://stackoverflow.com/questions/15498590/invalid-prototype-when-using-a-check-function
//   https://jrsoftware.org/ishelp/topic_scriptconstants.htm
//
// https://stackoverflow.com/questions/48460649/innosetup-what-is-the-textbox-name-in-the-folder-selection-dialog
//   WizardForm.DirEdit.Text := 'foo'; // Is not recommended? Let's use `{code:GetDefaultDirName}`.
//
function GetDefaultDirName(const Param: String): String;
begin
    Result := 
        GetConcatenatedCleanPath(
            ExpandConstant('{userpf}'),
            '{#MyAppName}'
        );
    Log('GetDefaultDirName: ' + Result);
end;


// https://stackoverflow.com/questions/21737462/how-to-properly-close-out-of-inno-setup-wizard-without-prompt
//
procedure CancelButtonClick(
    const
        CurPageID: Integer;
    var
        Cancel, Confirm: Boolean
);
begin
    if (global_boolean_CancelWithoutPrompt) then
        Confirm := False;
end;


procedure TerminateWizard();
begin
    global_boolean_CancelWithoutPrompt := True;
    WizardForm.Close();
    Abort(); // The emergency exit in /VERYSILENT mode.
end;


function NextButtonClick(const CurPageID: Integer): Boolean;
begin
    Result := True;

    case (CurPageID) of
        wpReady:
        begin
            // To skip the page 'Preparing to Install', kill the program.
            StopAndKillProcessOfSpecificPath(
                GetConcatenatedCleanPath(
                    ExpandConstant('{app}'),
                    '{#MyAppExeName}'
                )
            );
        end;
        wpSelectDir:
        begin
            // Inno Setup's built-in check is not perfect,
            //   so add another one.
            if (Length(
                Trim(ExpandConstant('{app}'))
            ) > const_integer_MaximumDirLength) then
            begin
                Result := False;

                MsgBox(
                    SetupMessage(msgDirNameTooLong),
                    mbError,
                    MB_OK or MB_SETFOREGROUND
                );
            end;
        end;
    end;
end;


procedure CurStepChanged(const CurStep: TSetupStep);
var
    string_ErrorMessage: String;

    // https://stackoverflow.com/questions/22139355/string-arrays-in-innosetup
    integerArray_RootKeys: array of Integer;
    integer_RootKey_index: Integer;
begin
    case (CurStep) of
        ssInstall:
        begin
            // HKLM32 and HKCU (in this case, HKCU includes HKCU32 and HKCU64).
            integerArray_RootKeys := [HKLM32, HKCU];
            for integer_RootKey_index := 0
                to GetArrayLength(integerArray_RootKeys) - 1
                do
            begin
                if (ProccessRegisryInfo(
                        integerArray_RootKeys[integer_RootKey_index],
                        string_ErrorMessage
                    ) <> 0) then
                begin
                    MsgBox(
                        FmtMessage(
                            CustomMessage('cm_ProcessPreviousInstallation_Failed')
                            ,[
                                RootKeyToStr(integerArray_RootKeys[integer_RootKey_index]),
                                string_ErrorMessage
                            ]
                        ),
                        mbError,
                        MB_OK or MB_SETFOREGROUND
                    );
                    TerminateWizard();
                    Break;
                end;
            end;
        end;
    end;
end;


// https://stackoverflow.com/questions/38934332/how-can-i-make-a-button-or-a-text-in-inno-setup-that-opens-web-page-when-clicked
// Inno Setup 6.0.5\Examples\CodeClasses.iss
// https://stackoverflow.com/questions/41154540/how-to-create-label-on-bevel-line-in-inno-setup
//
// TLabel will be covered by the white area in the dialog, So I use TNewStaticText.
//

procedure OpenBrowser(string_Url: string);
var
    integer_ErrorCode: Integer;
begin
    ShellExec('open', string_Url, '', '', SW_SHOWNORMAL, ewNoWait, integer_ErrorCode);
end;


procedure GiteeLabelClick(Sender: TObject);
begin
    OpenBrowser(CustomMessage('cm_Gitee_URL'));
end;

procedure GitHubLabelClick(Sender: TObject);
begin
    OpenBrowser(CustomMessage('cm_GitHub_URL'));
end;

procedure GitterLabelClick(Sender: TObject);
begin
    OpenBrowser(CustomMessage('cm_Gitter_URL'));
end;

procedure QQGroupLabelClick(Sender: TObject);
begin
    OpenBrowser(CustomMessage('cm_QQGroup_URL'));
end;


procedure CreateLabelsAndLinksOnDialog();
var
    label_RepositoryPages,
    label_GetHelp: TNewStaticText;

    label_Gitter,
    label_QQGroup: TNewStaticText;

    label_GitHub,
    label_Gitee: TNewStaticText;
begin
    label_RepositoryPages := TNewStaticText.Create(WizardForm);
    with label_RepositoryPages do
    begin
        Caption := CustomMessage('cm_RepositoryPages');
        Parent := WizardForm;
        Top :=
            WizardForm.CancelButton.Top
            + WizardForm.CancelButton.Height
            - Height;
        Left := 
            WizardForm.ClientWidth
            - (
                WizardForm.CancelButton.Left
                + WizardForm.CancelButton.Width
            );
        Anchors := [akLeft, akBottom];
    end;

    label_GetHelp := TNewStaticText.Create(WizardForm);
    with label_GetHelp do
    begin
        Caption := CustomMessage('cm_GetHelp');
        Parent := WizardForm;
        Top := label_RepositoryPages.Top - Height - 2;
        Left := label_RepositoryPages.Left;
        Anchors := [akLeft, akBottom];
    end;


    label_Gitter := TNewStaticText.Create(WizardForm);
    with label_Gitter do
    begin
        Caption := CustomMessage('cm_Gitter');
        Cursor := crHand;
        OnClick := @GitterLabelClick;
        Parent := WizardForm;
        { Alter Font *after* setting Parent so the correct defaults are inherited first }
        Font.Style := Font.Style + [fsUnderline];
        Font.Color := clHotLight
        Top := label_GetHelp.Top;
        Left := (label_GetHelp.Left + label_GetHelp.Width) + 4;
        Anchors := [akLeft, akBottom];
    end;

    label_QQGroup := TNewStaticText.Create(WizardForm);
    with label_QQGroup do
    begin
        Caption := CustomMessage('cm_QQGroup');
        Cursor := crHand;
        OnClick := @QQGroupLabelClick;
        Parent := WizardForm;
        { Alter Font *after* setting Parent so the correct defaults are inherited first }
        Font.Style := Font.Style + [fsUnderline];
        Font.Color := clHotLight
        Top := label_Gitter.Top;
        Left := (label_Gitter.Left + label_Gitter.Width) + 4;
        Anchors := [akLeft, akBottom];
    end;


    label_GitHub := TNewStaticText.Create(WizardForm);
    with label_GitHub do
    begin
        Caption := CustomMessage('cm_GitHub');
        Cursor := crHand;
        OnClick := @GitHubLabelClick;
        Parent := WizardForm;
        { Alter Font *after* setting Parent so the correct defaults are inherited first }
        Font.Style := Font.Style + [fsUnderline];
        Font.Color := clHotLight
        Top := label_RepositoryPages.Top;
        Left := 
            (
                label_RepositoryPages.Left
                + label_RepositoryPages.Width
            )
            + 4;
        Anchors := [akLeft, akBottom];
    end;

    label_Gitee := TNewStaticText.Create(WizardForm);
    with label_Gitee do
    begin
        Caption := CustomMessage('cm_Gitee');
        Cursor := crHand;
        OnClick := @GiteeLabelClick;
        Parent := WizardForm;
        { Alter Font *after* setting Parent so the correct defaults are inherited first }
        Font.Style := Font.Style + [fsUnderline];
        Font.Color := clHotLight
        Top := label_GitHub.Top;
        Left := (label_GitHub.Left + label_GitHub.Width) + 4;
        Anchors := [akLeft, akBottom];
    end;
end;


function RefuseAdministrators(): Boolean;
begin
    Result := True;

    // If UAC is turned off, the installer will run with administrator
    //   privileges.
    // 'runas' can be used to avoid it.
    //
    if (IsAdmin()) then
    begin
        Log('Run as administrator.');
        if (MsgBox(
                CustomMessage('cm_RunAsAdministrator'),
                mbConfirmation,
                MB_YESNO or MB_DEFBUTTON2 or MB_SETFOREGROUND
            ) = IDNO) then
            Result := False;
    end;

    // Logs:
    // When UAC is OFF:
    //   User privileges: Administrative
    //   Administrative install mode: No
    //   Install mode root key: HKEY_CURRENT_USER
    //
    // When UAC is OFF and runas the basic user:
    //   User privileges: None
    //   Administrative install mode: No
    //   Install mode root key: HKEY_CURRENT_USER
    //
    // When UAC is ON and run without administrator privileges:
    //   User privileges: None
    //   Administrative install mode: No
    //   Install mode root key: HKEY_CURRENT_USER
    //
    // When UAC is ON and run with administrator privileges:
    //   User privileges: Administrative
    //   Administrative install mode: No
    //   Install mode root key: HKEY_CURRENT_USER
end;


procedure InitializeVariables();
begin
    global_boolean_CancelWithoutPrompt := False;
end;


function InitializeSetup(): Boolean;
begin
    Result := False;

    InitializeVariables();
    Result := RefuseAdministrators();
end;


procedure InitializeWizard();
begin
    CreateLabelsAndLinksOnDialog();
end;
