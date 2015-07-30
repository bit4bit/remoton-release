!define PRODUCT_NAME "remoton-support-desktop"


SetCompressor lzma
 
 
 
; MUI 1.67 compatible ------
!include "MUI.nsh"
!include "x64.nsh"
!include "FileFunc.nsh"

; MUI Settings
!define MUI_ABORTWARNING
!define MUI_ICON "icon.ico"
!define MUI_LANGDLL_ALLLANGUAGES

; Welcome page
!insertmacro MUI_PAGE_WELCOME
; Components page
!insertmacro MUI_PAGE_COMPONENTS
; Instfiles page
!insertmacro MUI_PAGE_INSTFILES
; Finish page
!insertmacro MUI_PAGE_FINISH
 
; Language files
!insertmacro MUI_LANGUAGE "English"

 
; Reserve files
!insertmacro MUI_RESERVEFILE_INSTALLOPTIONS

; MUI end ------

Name "${PRODUCT_NAME} ${PRODUCT_VERSION}"
OutFile installer.exe
InstallDir "$PROGRAMFILES\remoton-support-desktop"

ShowInstDetails show

Section -SETTINGS
  SetOutPath "$INSTDIR"
  SetOverwrite ifnewer
SectionEnd


Section "Xpra" SEC01
  !ifdef BUNDLE
    File "xpra_setup.exe"
    !else

    NSISdl::download  https://www.xpra.org/dists/windows/Xpra_Setup_${XPRA_VERSION}-${XPRA_REVISION}.exe xpra_setup.exe
    Pop $R0
    StrCmp $R0 "success" +3
    MessageBox MB_OK "Download Xpra failed: $R0"
    Quit
  !endif
  ExecWait '"$INSTDIR\xpra_setup.exe" /SP- /SILENT'
SectionEnd

Section "Gtk 2 Runtime" SEC02
  File "freetype6.dll"
  File "libasprintf-0.dll"
  File "libatk-1.0-0.dll"
  File "libcairo-2.dll"
  File "libcairo-gobject-2.dll"
  File "libcairo-script-interpreter-2.dll"
  File "libexpat-1.dll"
  File "libfontconfig-1.dll"
  File "libfreetype-6.dll"
  File "libgailutil-18.dll"
  File "libgio-2.0-0.dll"
  File "libgmodule-2.0-0.dll"
  File "libgobject-2.0-0.dll"
  File "libintl-8.dll"
  File "libpangocairo-1.0-0.dll"
  File "libpango-1.0-0.dll"
  File "libpangocairo-1.0-0.dll"
  File "libpangoft2-1.0-0.dll"
  File "libpangowin32-1.0-0.dll"
  File "libpng14-14.dll"
  
  
  File "libgthread-2.0-0.dll"
  File "libgobject-2.0-0.dll"

  File "libgdk-win32-2.0-0.dll"
  File "libgtk-win32-2.0-0.dll"

  File "libgdk_pixbuf-2.0-0.dll"
  File "libglib-2.0-0.dll"
SectionEnd

Section
  WriteUninstaller "$INSTDIR\uninstaller.exe"
  File "remoton-support-desktop.exe"
  CreateShortCut "$SMPROGRAMS\remonto-support-desktop.lnk" "$INSTDIR\remoton-support-desktop.exe"
SectionEnd

Section "Uninstall"
  Delete $INSTDIR\unistaller.exe
  !ifdef BUNDLE
    Delete $INSTDIR\xpra_setup.exe
    Delete $INSTDIR\gtk2_runtime.exe
  !endif
  Delete $INSTDIR\remoton-support-desktop.exe
  RMDir "$INSTDIR"
SectionEnd
