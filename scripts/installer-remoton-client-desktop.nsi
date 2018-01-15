!define PRODUCT_NAME "remoton-client-desktop"

!define DESCRIPTION "Shared desktop"
!define VERSIONMAJOR 0
!define VERSIONMINOR 1
!define VERSIONBUILD 1

!define HELPURL "http://github.com/bit4bit"
!define UPDATEURL "http:/github.com/bit4bit/remoton/releases"
!define ABOUTURL "http://github.com/bit4bit"

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
!insertmacro MUI_PAGE_LICENSE LICENSE
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
InstallDir "$PROGRAMFILES\remoton-client-desktop"

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
  ExecWait '"$INSTDIR\xpra_setup.exe" /SP- /SILENT /DIR="$INSTDIR\xpra" /NOICONS /LANG=es'
SectionEnd

Section
  WriteUninstaller "$INSTDIR\uninstaller.exe"
  #GTK
  File /nonfatal "freetype6.dll"
  File /nonfatal "intl.dll"
  File "libasprintf-0.dll"
  File "libatk-1.0-0.dll"
  File "libcairo-2.dll"
  File "libcairo-gobject-2.dll"
  File "libcairo-script-interpreter-2.dll"
  File "libexpat-1.dll"
  File "libfontconfig-1.dll"
  File "libgailutil-18.dll"
  File /nonfatal "libgcc_s_dw2-1.dll"
  File "libgdk_pixbuf-2.0-0.dll"
  File "libgdk-win32-2.0-0.dll"
  File "libgio-2.0-0.dll"
  File "libglib-2.0-0.dll"
  File "libgmodule-2.0-0.dll"
  File "libgobject-2.0-0.dll"
  File "libgthread-2.0-0.dll"
  File "libgtk-win32-2.0-0.dll"
  File "libpango-1.0-0.dll"
  File "libpangocairo-1.0-0.dll"
  File "libpangoft2-1.0-0.dll"
  File "libpangowin32-1.0-0.dll"
  File "libpng14-14.dll"
  File "zlib1.dll"
  
  #MAIN
  File "icon.ico"
  File "remoton.exe"
  File "LICENSE"
  
  CreateDirectory "$SMPROGRAMS\${PRODUCT_NAME}"
  CreateShortCut "$SMPROGRAMS\${PRODUCT_NAME}\${PRODUCT_NAME}.lnk" "$INSTDIR\remoton.exe" "" "$INSTDIR\icon.ico"


  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME}" "DisplayName" "${PRODUCT_NAME} - ${DESCRIPTION}"
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME}" "UninstallString" "$\"$INSTDIR\uninstall.exe$\""
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME}" "QuietUninstallString" "$\"$INSTDIR\uninstall.exe$\" /S"
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME}" "InstallLocation" "$\"$INSTDIR$\""
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME}" "DisplayIcon" "$\"$INSTDIR\logo.ico$\""
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME}" "Publisher" "$\"${PRODUCT_NAME}$\""
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME}" "HelpLink" "$\"${HELPURL}$\""
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME}" "URLUpdateInfo" "$\"${UPDATEURL}$\""
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME}" "URLInfoAbout" "$\"${ABOUTURL}$\""
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME}" "DisplayVersion" "$\"${VERSIONMAJOR}.${VERSIONMINOR}.${VERSIONBUILD}$\""
	WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME}" "VersionMajor" ${VERSIONMAJOR}
	WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME}" "VersionMinor" ${VERSIONMINOR}
	# There is no option for modifying or repairing the install
	WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME}" "NoModify" 1
	WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME}" "NoRepair" 1
SectionEnd

Section "Uninstall"
  Delete "$SMPROGRAMS\${PRODUCT_NAME}\${PRODUCT_NAME}.lnk"
  RMDir "$SMPROGRAMS\${PRODUCT_NAME}"
  
  Delete $INSTDIR\unistaller.exe
  !ifdef BUNDLE
    Delete $INSTDIR\xpra_setup.exe
    Delete $INSTDIR\gtk2_runtime.exe
  !endif
  Delete $INSTDIR\remoton.exe
  RMDir /r /REBOOTOK "$INSTDIR"
  DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME}"
SectionEnd
