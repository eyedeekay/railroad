UniCode true

# define name of installer
OutFile "railroad-installer.exe"
 
# define installation directory
!define APPNAME "Railroad"
InstallDir "$LOCALAPPDATA\${APPNAME}\"

!define LICENSE_TITLE "MIT License"
PageEx license
    licensetext "${LICENSE_TITLE}"
    licensedata "LICENSE.md"
PageExEnd
Page instfiles

# Include the logic library for checking file exists.
!include LogicLib.nsh

# For removing Start Menu shortcut in Windows 7
RequestExecutionLevel user

# start default section
Section
    Exec 'CheckNetIsolation.exe LoopbackExempt -a -n="Microsoft.Win32WebViewHost_cw5n1h2txyewy"'
    SetOutPath $INSTDIR
    File railroad-windows-amd64.exe
    Delete railroad-windows.exe
    File README.md
    File LICENSE.md
    File /a /r ".\content\"
    File /a /r ".\built-in\"

    # create the uninstaller
    WriteUninstaller "$INSTDIR\uninstall.exe"

    # create a shortcut named "new shortcut" in the start menu programs directory
    # point the new shortcut at the program uninstaller
    CreateShortcut "$SMPROGRAMS\${APPNAME}\Blog with Railroad.lnk" "$INSTDIR\railroad-windows-amd64.exe"
    CreateShortcut "$SMPROGRAMS\${APPNAME}\Uninstall Railroad Blog.lnk" "$INSTDIR\uninstall.exe"
SectionEnd
 
# uninstaller section start
Section "uninstall"

    # first, delete the uninstaller
    Delete "$INSTDIR\uninstall.exe"
    RMDir "$INSTDIR"

    # second, remove the link from the start menu

    Delete "$SMPROGRAMS\Blog with Railroad.lnk"
    Delete "$SMPROGRAMS\new shortcut.lnk"

    # Call un.installZero

    RMDir $INSTDIR
# uninstaller section end
SectionEnd