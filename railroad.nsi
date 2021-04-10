UniCode true

# define name of installer
OutFile "../railroad-installer.exe"
 
# define installation directory
!define APPNAME "Railroad"
InstallDir "$PROGRAMFILES64\${APPNAME}\"

!define LICENSE_TITLE "MIT License"
PageEx license
    licensetext "${LICENSE_TITLE}"
    licensedata "LICENSE.md"
PageExEnd
Page instfiles

# For removing Start Menu shortcut in Windows 7
RequestExecutionLevel admin
 
# start default section
Section
    Exec 'CheckNetIsolation.exe LoopbackExempt -a -n="Microsoft.Win32WebViewHost_cw5n1h2txyewy"'
    # set the installation directory as the destination for the following actions
    SetOutPath $INSTDIR
    File railroad.exe
    File railroad.bat
    File WebView2Loader.dll
    File webview.dll
    File README.md
    File LICENSE.md
    File config.json
    File /a /r ".\content\"
    File /a /r ".\built-in\"

    # create the uninstaller
    WriteUninstaller "$INSTDIR\uninstall.exe"

    # create a shortcut named "new shortcut" in the start menu programs directory
    # point the new shortcut at the program uninstaller
    CreateShortcut "$SMPROGRAMS\Blog with Railroad.lnk" "$INSTDIR\railroad.bat"
    CreateShortcut "$SMPROGRAMS\Uninstall Railroad Blog.lnk" "$INSTDIR\uninstall.exe"
SectionEnd
 
# uninstaller section start
Section "uninstall"

    # first, delete the uninstaller
    Delete "$INSTDIR\uninstall.exe"

    # second, remove the link from the start menu

    Delete "$SMPROGRAMS\Blog with Railroad.lnk"
    Delete "$SMPROGRAMS\new shortcut.lnk"

    RMDir $INSTDIR
# uninstaller section end
SectionEnd