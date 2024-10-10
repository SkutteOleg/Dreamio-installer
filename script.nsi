; DREAMIO: AI-Powered Adventures Installer Script

!include "LogicLib.nsh"
!include /CHARSET=CP1252 zipdll.nsh

; Define constants
!define APPNAME "DREAMIO: AI-Powered Adventures"
!define SAFENAME "DREAMIO AI-Powered Adventures"
!define COMPANYNAME "Oleg Skutte"
!define DESCRIPTION "DREAMIO is a 'choose-your-own-adventure' game where stories and visuals are dynamically created through the power of generative AI in response to your decisions. Explore endless worlds with limitless possibilities; go anywhere, do anything."

; Variables for version information
Var VersionString
Var DownloadUrl

; Main Install settings
Name "${APPNAME}"
InstallDir "$PROGRAMFILES\${APPNAME}"
OutFile "DreamioInstaller.exe"
RequestExecutionLevel admin

; Include Modern UI
!include "MUI2.nsh"
!include "nsDialogs.nsh"

; Define UI settings
!define MUI_ABORTWARNING
!define MUI_ICON "icon.ico"
!define MUI_UNICON "${NSISDIR}\Contrib\Graphics\Icons\modern-uninstall.ico"

; Add the welcome image
!define MUI_WELCOMEFINISHPAGE_BITMAP "welcome.bmp"

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
    ExecShell "open" "https://games.skutteoleg.com/dreamio/privacy-policy/"
FunctionEnd

Function OpenTermsOfService
    ExecShell "open" "https://games.skutteoleg.com/dreamio/terms-and-conditions/"
FunctionEnd

; Pages
!insertmacro MUI_PAGE_WELCOME
Page custom TermsPage LeaveTermsPage
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_COMPONENTS
!insertmacro MUI_PAGE_INSTFILES
!define MUI_FINISHPAGE_RUN "$INSTDIR\Dreamio.exe"
!define MUI_FINISHPAGE_RUN_TEXT "Launch DREAMIO: AI-Powered Adventures"
!insertmacro MUI_PAGE_FINISH

; Uninstall pages
!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES

; Set languages (first is default language)
!insertmacro MUI_LANGUAGE "English"

; Installer sections
Section "DREAMIO: AI-Powered Adventures" SecCore
    SectionIn RO
    ; Estimate the size (adjust this value based on your actual zip file size)
    AddSize 3000000 ; This assumes a 200 MB installation, adjust as needed
    SetOutPath $INSTDIR
    
    ; Test write permissions
    FileOpen $0 "$INSTDIR\test.txt" w
    FileWrite $0 "Test"
    FileClose $0
    IfFileExists "$INSTDIR\test.txt" +3
        MessageBox MB_OK "Cannot write to install directory"
        Quit
    Delete "$INSTDIR\test.txt"
    
    ; Download and parse the JSON file
    INetC::get "https://games.skutteoleg.com/dreamio/downloads/Builds/Windows/version.json" "$TEMP\version.json" /END
    Pop $0
    StrCmp $0 "OK" +3
        MessageBox MB_OK "Failed to download version information: $0"
        Quit
    
    ; Parse JSON
    nsJSON::Set /file "$TEMP\version.json"
    nsJSON::Get `version` /END
    Pop $VersionString
    nsJSON::Get `latestUrl` /END
    Pop $DownloadUrl
    
    ; Download the zip file
    INetC::get "$DownloadUrl" "$TEMP\latest.zip" /END
    Pop $0
    StrCmp $0 "OK" +3
        MessageBox MB_OK "Download failed: $0"
        Quit
    
    ; Extract the zip file
    nsisunz::UnzipToLog "$TEMP\latest.zip" "$INSTDIR"
    Pop $0
    StrCmp $0 "success" +3
        MessageBox MB_OK "Extraction failed: $0"
        Quit
    
    ; Delete the temporary files
    Delete "$TEMP\latest.zip"
    Delete "$TEMP\version.json"
    
    ; Write uninstaller
    WriteUninstaller "$INSTDIR\Uninstall.exe"
    
    ; Registry information for add/remove programs
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${COMPANYNAME} ${APPNAME}" "DisplayName" "${APPNAME}"
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${COMPANYNAME} ${APPNAME}" "UninstallString" "$\"$INSTDIR\Uninstall.exe$\""
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${COMPANYNAME} ${APPNAME}" "QuietUninstallString" "$\"$INSTDIR\Uninstall.exe$\" /S"
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${COMPANYNAME} ${APPNAME}" "InstallLocation" "$INSTDIR"
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${COMPANYNAME} ${APPNAME}" "DisplayIcon" "$INSTDIR\Dreamio.exe"
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${COMPANYNAME} ${APPNAME}" "Publisher" "${COMPANYNAME}"
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${COMPANYNAME} ${APPNAME}" "DisplayVersion" "$VersionString"
    WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${COMPANYNAME} ${APPNAME}" "NoModify" 1
    WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${COMPANYNAME} ${APPNAME}" "NoRepair" 1
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

Section "Uninstall"
    ; Remove all files and folders
    RMDir /r "$INSTDIR\*.*"
    RMDir "$INSTDIR"
    
    ; Remove desktop shortcut
    Delete "$DESKTOP\${SAFENAME}.lnk"
    
    ; Remove start menu items
    RMDir /r "$SMPROGRAMS\${APPNAME}"
    
    ; Remove registry keys
    DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${COMPANYNAME} ${APPNAME}"
    DeleteRegKey HKCU "SOFTWARE\Oleg Skutte\DREAMIO: AI-Powered Adventures"
    
    ; Remove uninstaller
    Delete "$INSTDIR\Uninstall.exe"
SectionEnd
