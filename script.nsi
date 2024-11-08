; DREAMIO: AI-Powered Adventures Installer Script

; Define constants
!define APPNAME "DREAMIO: AI-Powered Adventures"
!define SAFENAME "DREAMIO AI-Powered Adventures"
!define COMPANYNAME "Oleg Skutte"
!define DESCRIPTION "DREAMIO is a 'choose-your-own-adventure' game where stories and visuals are dynamically created through the power of generative AI in response to your decisions. Explore endless worlds with limitless possibilities; go anywhere, do anything."

; Variables for version information
Var VersionString
Var DownloadUrl
Var UninstallClearRegCheckbox
Var InstallForAllUsers
Var InstallDir

; Main Install settings
Name "${APPNAME}"
OutFile "DreamioInstaller.exe"
RequestExecutionLevel admin

; Include Modern UI
!include "MUI2.nsh"
!include "nsDialogs.nsh"

; Define UI settings
!define MUI_ABORTWARNING
!define MUI_ICON "installer.ico"
!define MUI_UNICON "uninstaller.ico"

; Add the welcome image
!define MUI_WELCOMEFINISHPAGE_BITMAP "welcome.bmp"
!define MUI_UNWELCOMEFINISHPAGE_BITMAP "welcome.bmp"

; Custom page for Terms and Privacy Policy
Var Dialog
Var CheckBox

Function TermsPage
    nsDialogs::Create 1018
    Pop $Dialog

    ${NSD_CreateLabel} 0 0 100% 40u "Before installing, please review Privacy Policy and Terms and Conditions. Click the links below to open them in your web browser:"
    Pop $0

    ${NSD_CreateLink} 0 50u 100% 12u "View Privacy Policy"
    Pop $0
    ${NSD_OnClick} $0 OpenPrivacyPolicy

    ${NSD_CreateLink} 0 70u 100% 12u "View Terms and Conditions"
    Pop $0
    ${NSD_OnClick} $0 OpenTermsOfService

    ${NSD_CreateCheckbox} 0 100u 100% 12u "I accept the Privacy Policy and Terms and Conditions"
    Pop $CheckBox

    nsDialogs::Show
FunctionEnd

Function LeaveTermsPage
    ${NSD_GetState} $CheckBox $0
    ${If} $0 != ${BST_CHECKED}
        MessageBox MB_ICONEXCLAMATION|MB_OK "You must accept the Privacy Policy and Terms and Conditions to continue."
        Abort
    ${EndIf}
FunctionEnd

Function OpenPrivacyPolicy
    ExecShell "open" "https://dreamio.xyz/privacy-policy/"
FunctionEnd

Function OpenTermsOfService
    ExecShell "open" "https://dreamio.xyz/terms-and-conditions/"
FunctionEnd

; Custom page for installation type
Function InstallTypePage
    !insertmacro MUI_HEADER_TEXT "Installation Type" "Choose the installation type"
    nsDialogs::Create 1018
    Pop $Dialog

    ${NSD_CreateRadioButton} 0 0 100% 12u "Install for all users (requires administrator privileges)"
    Pop $InstallForAllUsers
    
    ${NSD_CreateRadioButton} 0 20u 100% 12u "Install for current user only"
    Pop $0
    ${NSD_Check} $0 ; Default to checked for current user
    
    nsDialogs::Show
FunctionEnd

Function UpdateInstallDir
    ${If} $InstallForAllUsers == ${BST_CHECKED}
        StrCpy $INSTDIR "$PROGRAMFILES\${APPNAME}"
    ${Else}
        StrCpy $INSTDIR "$LOCALAPPDATA\${APPNAME}"
    ${EndIf}
FunctionEnd

Function LeaveInstallTypePage
    ${NSD_GetState} $InstallForAllUsers $0
    ${If} $0 == ${BST_CHECKED}
        StrCpy $InstallForAllUsers ${BST_CHECKED}
        SetShellVarContext all
    ${Else}
        StrCpy $InstallForAllUsers ${BST_UNCHECKED}
        SetShellVarContext current
    ${EndIf}
    Call UpdateInstallDir
FunctionEnd

Function DirectoryShow
    Call UpdateInstallDir
FunctionEnd

Function DirectoryLeave
    StrCpy $InstallDir $INSTDIR
FunctionEnd

Function .onInit
    ; Set default to current user installation
    StrCpy $InstallDir "$LOCALAPPDATA\${APPNAME}"
    StrCpy $INSTDIR "$LOCALAPPDATA\${APPNAME}"
    SetShellVarContext current
    
    ; Initialize $InstallForAllUsers
    StrCpy $InstallForAllUsers ${BST_UNCHECKED}
FunctionEnd

; Pages
!insertmacro MUI_PAGE_WELCOME
Page custom TermsPage LeaveTermsPage
Page custom InstallTypePage LeaveInstallTypePage
!define MUI_PAGE_CUSTOMFUNCTION_PRE DirectoryShow
!define MUI_PAGE_CUSTOMFUNCTION_LEAVE DirectoryLeave
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_COMPONENTS
!insertmacro MUI_PAGE_INSTFILES
!define MUI_FINISHPAGE_RUN "$INSTDIR\Dreamio.exe"
!define MUI_FINISHPAGE_RUN_TEXT "Launch DREAMIO: AI-Powered Adventures"
!insertmacro MUI_PAGE_FINISH

; Uninstall pages
!insertmacro MUI_UNPAGE_WELCOME
UninstPage custom un.CustomUninstPage
!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES

; Set languages (first is default language)
!insertmacro MUI_LANGUAGE "English"

; Installer sections
Section "DREAMIO: AI-Powered Adventures" SecCore
    SectionIn RO
    AddSize 3500000 ; Adjust as needed
    SetOutPath $INSTDIR
    
    FileOpen $0 "$INSTDIR\test.txt" w
    FileWrite $0 "Test"
    FileClose $0
    IfFileExists "$INSTDIR\test.txt" +3
        MessageBox MB_OK "Cannot write to install directory"
        Quit
    Delete "$INSTDIR\test.txt"
    
    INetC::get "https://dreamio.xyz/downloads/Builds/Windows/version.json" "$TEMP\version.json" /END
    Pop $0
    StrCmp $0 "OK" +3
        MessageBox MB_OK "Failed to download version information: $0"
        Quit
    
    nsJSON::Set /file "$TEMP\version.json"
    nsJSON::Get `version` /END
    Pop $VersionString
    nsJSON::Get `latestUrl` /END
    Pop $DownloadUrl
    
    INetC::get "$DownloadUrl" "$TEMP\dreamio.zip" /END
    Pop $0
    StrCmp $0 "OK" +3
        MessageBox MB_OK "Download failed: $0"
        Quit
    
    nsisunz::UnzipToLog "$TEMP\dreamio.zip" "$INSTDIR"
    Pop $0
    StrCmp $0 "success" +3
        MessageBox MB_OK "Extraction failed: $0"
        Quit
    
    Delete "$TEMP\dreamio.zip"
    Delete "$TEMP\version.json"
    
    WriteUninstaller "$INSTDIR\Uninstall.exe"
    
    ${If} $InstallForAllUsers == ${BST_CHECKED}
        WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${COMPANYNAME} ${APPNAME}" "DisplayName" "${APPNAME}"
        WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${COMPANYNAME} ${APPNAME}" "UninstallString" "$\"$INSTDIR\Uninstall.exe$\""
        WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${COMPANYNAME} ${APPNAME}" "QuietUninstallString" "$\"$INSTDIR\Uninstall.exe$\" /S"
        WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${COMPANYNAME} ${APPNAME}" "InstallLocation" "$INSTDIR"
        WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${COMPANYNAME} ${APPNAME}" "DisplayIcon" "$INSTDIR\Dreamio.exe"
        WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${COMPANYNAME} ${APPNAME}" "Publisher" "${COMPANYNAME}"
        WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${COMPANYNAME} ${APPNAME}" "DisplayVersion" "$VersionString"
        WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${COMPANYNAME} ${APPNAME}" "NoModify" 1
        WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${COMPANYNAME} ${APPNAME}" "NoRepair" 1
    ${Else}
        WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\${COMPANYNAME} ${APPNAME}" "DisplayName" "${APPNAME}"
        WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\${COMPANYNAME} ${APPNAME}" "UninstallString" "$\"$INSTDIR\Uninstall.exe$\""
        WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\${COMPANYNAME} ${APPNAME}" "QuietUninstallString" "$\"$INSTDIR\Uninstall.exe$\" /S"
        WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\${COMPANYNAME} ${APPNAME}" "InstallLocation" "$INSTDIR"
        WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\${COMPANYNAME} ${APPNAME}" "DisplayIcon" "$INSTDIR\Dreamio.exe"
        WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\${COMPANYNAME} ${APPNAME}" "Publisher" "${COMPANYNAME}"
        WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\${COMPANYNAME} ${APPNAME}" "DisplayVersion" "$VersionString"
        WriteRegDWORD HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\${COMPANYNAME} ${APPNAME}" "NoModify" 1
        WriteRegDWORD HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\${COMPANYNAME} ${APPNAME}" "NoRepair" 1
    ${EndIf}
SectionEnd

Section "Desktop Shortcut" SecDesktop
    CreateShortCut "$DESKTOP\${SAFENAME}.lnk" "$INSTDIR\Dreamio.exe"
SectionEnd

Section "Start Menu Shortcut" SecStartMenu
    CreateDirectory "$SMPROGRAMS\${APPNAME}"
    CreateShortCut "$SMPROGRAMS\${APPNAME}\${APPNAME}.lnk" "$INSTDIR\Dreamio.exe"
SectionEnd

; Descriptions
LangString DESC_SecCore ${LANG_ENGLISH} "Core files for DREAMIO: AI-Powered Adventures."
LangString DESC_SecDesktop ${LANG_ENGLISH} "Create a shortcut on the desktop."
LangString DESC_SecStartMenu ${LANG_ENGLISH} "Create a Start Menu entry."

!insertmacro MUI_FUNCTION_DESCRIPTION_BEGIN
  !insertmacro MUI_DESCRIPTION_TEXT ${SecCore} $(DESC_SecCore)
  !insertmacro MUI_DESCRIPTION_TEXT ${SecDesktop} $(DESC_SecDesktop)
  !insertmacro MUI_DESCRIPTION_TEXT ${SecStartMenu} $(DESC_SecStartMenu)
!insertmacro MUI_FUNCTION_DESCRIPTION_END

; Uninstaller section
Section "Uninstall"
    RMDir /r "$INSTDIR\*.*"
    RMDir "$INSTDIR"
    
    Delete "$DESKTOP\${SAFENAME}.lnk"
    
    RMDir /r "$SMPROGRAMS\${APPNAME}"
    
    DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${COMPANYNAME} ${APPNAME}"
    DeleteRegKey HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\${COMPANYNAME} ${APPNAME}"
    
    ${If} $UninstallClearRegCheckbox == ${BST_CHECKED}
        DeleteRegKey HKCU "SOFTWARE\Oleg Skutte\DREAMIO: AI-Powered Adventures"
    ${EndIf}
    
    Delete "$INSTDIR\Uninstall.exe"
SectionEnd

; Uninstaller functions
Function un.onInit
    StrCpy $UninstallClearRegCheckbox ${BST_UNCHECKED}
FunctionEnd

Function un.CustomUninstPage
    !insertmacro MUI_HEADER_TEXT "Uninstall Options" "Choose additional uninstall options"
    nsDialogs::Create 1018
    Pop $Dialog

    ${NSD_CreateCheckbox} 0 0 100% 12u "Clear user settings (not recommended)"
    Pop $UninstallClearRegCheckbox
    ${NSD_SetState} $UninstallClearRegCheckbox ${BST_UNCHECKED}

    nsDialogs::Show
FunctionEnd
