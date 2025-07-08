# Notepad++ MSI Builder for C:\Apps\Notepad++
# Uses portable version in Apps directory

$OutputDir = "C:\Build\NotepadPlusPlus_Apps"
$FinalOutput = "C:\Build\Final"

# Clean and create directories
if (Test-Path $OutputDir) {
    Remove-Item -Path $OutputDir -Recurse -Force -ErrorAction SilentlyContinue
}
New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null
New-Item -ItemType Directory -Path $FinalOutput -Force | Out-Null
Set-Location $OutputDir

Write-Host "Notepad++ MSI Builder for C:\Apps" -ForegroundColor Cyan
Write-Host "==================================" -ForegroundColor Cyan

# Download WiX
$wixPath = "$OutputDir\wix"
if (-not (Test-Path "$wixPath\candle.exe")) {
    Write-Host "Downloading WiX Toolset..." -ForegroundColor Yellow
    $wixUrl = "https://github.com/wixtoolset/wix3/releases/download/wix3112rtm/wix311-binaries.zip"
    Invoke-WebRequest -Uri $wixUrl -OutFile "$OutputDir\wix.zip" -UseBasicParsing
    Expand-Archive -Path "$OutputDir\wix.zip" -DestinationPath $wixPath -Force
    Remove-Item "$OutputDir\wix.zip"
}

# Download Notepad++ version
Write-Host "Downloading Notepad++ x64..." -ForegroundColor Yellow
$nppUrl = "https://github.com/notepad-plus-plus/notepad-plus-plus/releases/download/v8.8.2/npp.8.8.2.portable.x64.zip"
$nppZip = "$OutputDir\npp_portable.zip"
$ProgressPreference = 'SilentlyContinue'
Invoke-WebRequest -Uri $nppUrl -OutFile $nppZip -UseBasicParsing

Write-Host "Extracting Notepad++..." -ForegroundColor Yellow
$nppDir = "$OutputDir\NPP"
Expand-Archive -Path $nppZip -DestinationPath $nppDir -Force
Remove-Item $nppZip

# Download 99er theme
Write-Host "Installing 99er theme..." -ForegroundColor Yellow
$themeUrl = "https://raw.githubusercontent.com/notepad-plus-plus/nppThemes/main/themes/99er.xml"
$themePath = "$nppDir\themes\99er.xml"
Invoke-WebRequest -Uri $themeUrl -OutFile $themePath -UseBasicParsing

# Copy latvian.xml to root as nativeLang.xml
Write-Host "Setting up Latvian language..." -ForegroundColor Yellow
if (Test-Path "$nppDir\localization\latvian.xml") {
    Copy-Item "$nppDir\localization\latvian.xml" "$nppDir\nativeLang.xml" -Force
    Write-Host "Latvian language file copied as nativeLang.xml" -ForegroundColor Green
}

# Copy 99er theme to root as stylers.xml
Write-Host "Setting up 99er theme as default..." -ForegroundColor Yellow
if (Test-Path "$themePath") {
    Copy-Item "$themePath" "$nppDir\stylers.xml" -Force
    Write-Host "99er theme copied as stylers.xml" -ForegroundColor Green
}

# Download Compare plugin
Write-Host "Installing Compare plugin..." -ForegroundColor Yellow
$compareUrl = "https://github.com/pnedev/compare-plugin/releases/download/v2.0.2/ComparePlugin_v2.0.2_X64.zip"
$comparePath = "$OutputDir\compare.zip"
Invoke-WebRequest -Uri $compareUrl -OutFile $comparePath -UseBasicParsing

$tempDir = "$OutputDir\temp"
Expand-Archive -Path $comparePath -DestinationPath $tempDir -Force
$pluginDir = "$nppDir\plugins\ComparePlugin"
New-Item -ItemType Directory -Path $pluginDir -Force | Out-Null

Get-ChildItem -Path $tempDir -Include "*.dll" -Recurse | ForEach-Object {
    Copy-Item $_.FullName $pluginDir -Force
}
Remove-Item $tempDir -Recurse -Force
Remove-Item $comparePath

# Create config files in the installation directory
Write-Host "Creating configuration files..." -ForegroundColor Yellow

# 1. Main config.xml with all settings
$configXml = @'
<?xml version="1.0" encoding="Windows-1252" ?>
<NotepadPlus>
    <GUIConfigs>
      <GUIConfig name="ToolBar" visible="yes" fluentColor="0" fluentCustomColor="12873472" fluentMono="no">standard</GUIConfig>
      <GUIConfig name="StatusBar">show</GUIConfig>
      <GUIConfig name="TabBar" dragAndDrop="yes" drawTopBar="yes" drawInactiveTab="yes" reduce="yes" closeButton="yes" pinButton="yes" showOnlyPinnedButton="no" buttonsOninactiveTabs="no" doubleClick2Close="no" vertical="no" multiLine="no" hide="no" quitOnEmpty="no" iconSetNumber="0"/>
      <GUIConfig name="ScintillaViewsSplitter">vertical</GUIConfig>
      <GUIConfig name="UserDefineDlg" position="undocked">hide</GUIConfig>
      <GUIConfig name="TabSetting" replaceBySpace="no" size="4" backspaceUnindent="no"/>
      <GUIConfig name="AppPosition" x="0" y="0" width="1024" height="700" isMaximized="no"/>
      <GUIConfig name="FindWindowPosition" left="0" top="0" right="0" bottom="0" isLessModeOn="no"/>
      <GUIConfig name="FinderConfig" wrappedLines="no" purgeBeforeEverySearch="no" showOnlyOneEntryPerFoundLine="yes"/>
      <GUIConfig name="noUpdate" intervalDays="15" nextUpdateDate="20250723" autoUpdateMode="1">no</GUIConfig>
      <GUIConfig name="Auto-detection">yes</GUIConfig>
      <GUIConfig name="CheckHistoryFiles">no</GUIConfig>
      <GUIConfig name="TrayIcon">0</GUIConfig>
      <GUIConfig name="MaintainIndent">1</GUIConfig>
      <GUIConfig name="TagsMatchHighLight" TagAttrHighLight="yes" HighLightNonHtmlZone="no">yes</GUIConfig>
      <GUIConfig name="RememberLastSession">yes</GUIConfig>
      <GUIConfig name="KeepSessionAbsentFileEntries">no</GUIConfig>
      <GUIConfig name="DetectEncoding">yes</GUIConfig>
      <GUIConfig name="SaveAllConfirm">yes</GUIConfig>
      <GUIConfig name="NewDocDefaultSettings" format="0" encoding="4" lang="0" codepage="-1" openAnsiAsUTF8="yes" addNewDocumentOnStartup="no" useContentAsTabName="no"/>
      <GUIConfig name="langsExcluded" gr0="0" gr1="0" gr2="0" gr3="0" gr4="0" gr5="0" gr6="0" gr7="0" gr8="0" gr9="0" gr10="0" gr11="0" gr12="0" langMenuCompact="yes"/>
      <GUIConfig name="Print" lineNumber="yes" printOption="3" headerLeft="" headerMiddle="" headerRight="" footerLeft="" footerMiddle="" footerRight="" headerFontName="" headerFontStyle="0" headerFontSize="0" footerFontName="" footerFontStyle="0" footerFontSize="0" margeLeft="0" margeRight="0" margeTop="0" margeBottom="0"/>
      <GUIConfig name="Backup" action="0" useCustumDir="no" dir="" isSnapshotMode="yes" snapshotBackupTiming="7000"/>
      <GUIConfig name="TaskList">yes</GUIConfig>
      <GUIConfig name="MRU">yes</GUIConfig>
      <GUIConfig name="URL">2</GUIConfig>
      <GUIConfig name="uriCustomizedSchemes">svn:// cvs:// git:// imap:// irc:// irc6:// ircs:// ldap:// ldaps:// news: telnet:// gopher:// ssh:// sftp:// smb:// skype: snmp:// spotify: steam:// sms: slack:// chrome:// bitcoin:</GUIConfig>
      <GUIConfig name="globalOverride" fg="no" bg="no" font="no" fontSize="no" bold="no" italic="no" underline="no"/>
      <GUIConfig name="auto-completion" autoCAction="3" triggerFromNbChar="1" autoCIgnoreNumbers="yes" insertSelectedItemUseENTER="yes" insertSelectedItemUseTAB="yes" autoCBrief="no" funcParams="yes"/>
      <GUIConfig name="auto-insert" parentheses="no" brackets="no" curlyBrackets="no" quotes="no" doubleQuotes="no" htmlXmlTag="no"/>
      <GUIConfig name="sessionExt"/>
      <GUIConfig name="workspaceExt"/>
      <GUIConfig name="MenuBar">show</GUIConfig>
      <GUIConfig name="Caret" width="1" blinkRate="600"/>
      <GUIConfig name="openSaveDir" value="0" defaultDirPath="" lastUsedDirPath=""/>
      <GUIConfig name="titleBar" short="no"/>
      <GUIConfig name="insertDateTime" customizedFormat="yyyy-MM-dd HH:mm:ss" reverseDefaultOrder="no"/>
      <GUIConfig name="wordCharList" useDefault="yes" charsAdded=""/>
      <GUIConfig name="delimiterSelection" leftmostDelimiter="40" rightmostDelimiter="41" delimiterSelectionOnEntireDocument="no"/>
      <GUIConfig name="largeFileRestriction" fileSizeMB="200" isEnabled="yes" allowAutoCompletion="no" allowBraceMatch="no" allowSmartHilite="no" allowClickableLink="no" deactivateWordWrap="yes" suppress2GBWarning="no"/>
      <GUIConfig name="multiInst" setting="0" clipboardHistory="no" documentList="no" characterPanel="no" folderAsWorkspace="no" projectPanels="no" documentMap="no" fuctionList="no" pluginPanels="no"/>
      <GUIConfig name="MISC" fileSwitcherWithoutExtColumn="no" fileSwitcherExtWidth="50" fileSwitcherWithoutPathColumn="yes" fileSwitcherPathWidth="50" fileSwitcherNoGroups="no" backSlashIsEscapeCharacterForSql="yes" writeTechnologyEngine="1" isFolderDroppedOpenFiles="no" docPeekOnTab="no" docPeekOnMap="no" sortFunctionList="no" saveDlgExtFilterToAllTypes="no" muteSounds="no" enableFoldCmdToggable="no" hideMenuRightShortcuts="no"/>
      <GUIConfig name="Searching" monospacedFontFindDlg="no" fillFindFieldWithSelected="yes" fillFindFieldSelectCaret="yes" findDlgAlwaysVisible="no" confirmReplaceInAllOpenDocs="yes" replaceStopsWithoutFindingNext="no" inSelectionAutocheckThreshold="1024" fillDirFieldFromActiveDoc="no"/>
      <GUIConfig name="searchEngine" searchEngineChoice="2" searchEngineCustom=""/>
      <GUIConfig name="MarkAll" matchCase="no" wholeWordOnly="yes"/>
      <GUIConfig name="SmartHighLight" matchCase="no" wholeWordOnly="yes" useFindSettings="no" onAnotherView="no">yes</GUIConfig>
      <GUIConfig name="DarkMode" enable="no" colorTone="0" customColorTop="2105376" customColorMenuHotTrack="4539717" customColorActive="3684408" customColorMain="2105376" customColorError="176" customColorText="14737632" customColorDarkText="12632256" customColorDisabledText="8421504" customColorLinkText="65535" customColorEdge="6579300" customColorHotEdge="10197915" customColorDisabledEdge="4737096" enableWindowsMode="no" darkThemeName="DarkModeDefault.xml" darkToolBarIconSet="0" darkTbFluentColor="0" darkTbFluentCustomColor="0" darkTbFluentMono="no" darkTabIconSet="2" darkTabUseTheme="no" lightThemeName="99er.xml" lightToolBarIconSet="4" lightTbFluentColor="0" lightTbFluentCustomColor="12873472" lightTbFluentMono="no" lightTabIconSet="0" lightTabUseTheme="yes"/>
    </GUIConfigs>
    <FindHistory nbMaxFindHistoryPath="10" nbMaxFindHistoryFilter="10" nbMaxFindHistoryFind="10" nbMaxFindHistoryReplace="10" matchWord="no" matchCase="no" wrap="yes" directionDown="yes" fifRecuisive="yes" fifInHiddenFolder="no" fifFilterFollowsDoc="no" fifFolderFollowsDoc="no" searchMode="0" transparencyMode="1" transparency="150" dotMatchesNewline="no" isSearch2ButtonsMode="no" regexBackward4PowerUser="no" />
    <History nbMaxFile="10" inSubMenu="no" customLength="-1" />
</NotepadPlus>
'@
$configXml | Out-File "$nppDir\config.xml" -Encoding UTF8

# Note: No longer creating stylers.model.xml as requested

# 3. CRITICAL: Create doLocalConf.xml for local configuration
Write-Host "Creating doLocalConf.xml for local mode..." -ForegroundColor Yellow
"" | Out-File "$nppDir\doLocalConf.xml" -Encoding UTF8

Write-Host "Configuration files created!" -ForegroundColor Green
Write-Host "- config.xml (with DarkMode config for 99er theme)" -ForegroundColor White
Write-Host "- nativeLang.xml (Latvian language file)" -ForegroundColor White
Write-Host "- stylers.xml (99er theme as default)" -ForegroundColor White
Write-Host "- doLocalConf.xml (forces local config mode)" -ForegroundColor White

# Create WiX source
Write-Host "Creating WiX source..." -ForegroundColor Yellow

# Create product WXS for C:\Apps installation
$productWxs = @'
<?xml version="1.0" encoding="UTF-8"?>
<Wix xmlns="http://schemas.microsoft.com/wix/2006/wi">
  <Product Id="*" 
           Name="Notepad++ Enterprise" 
           Language="1033" 
           Version="8.8.2.0" 
           Manufacturer="Custom Build" 
           UpgradeCode="{12AB34CD-56EF-7890-12AB-34CD56EF7890}">
    
    <Package InstallerVersion="300" 
             Compressed="yes" 
             InstallScope="perMachine"
             Platform="x64" />
    
    <MajorUpgrade DowngradeErrorMessage="A newer version is already installed." />
    <MediaTemplate EmbedCab="yes" />
    
    <Directory Id="TARGETDIR" Name="SourceDir">
      <Directory Id="WindowsVolume">
        <Directory Id="APPSDIR" Name="Apps">
          <Directory Id="INSTALLFOLDER" Name="Notepad++" />
        </Directory>
      </Directory>
      
      <Directory Id="ProgramMenuFolder">
        <Directory Id="ApplicationProgramsFolder" Name="Notepad++" />
      </Directory>
      
      <Directory Id="DesktopFolder" Name="Desktop" />
    </Directory>
    
    <!-- File Associations -->
    <DirectoryRef Id="TARGETDIR">
      <Component Id="FileAssociations" Guid="{AAAA1111-2222-3333-4444-555555555555}" Win64="yes">
        <RegistryKey Root="HKLM" Key="SOFTWARE\Classes\.txt">
          <RegistryValue Type="string" Value="Notepad++.txt" KeyPath="yes" />
        </RegistryKey>
        <RegistryKey Root="HKLM" Key="SOFTWARE\Classes\.log">
          <RegistryValue Type="string" Value="Notepad++.log" />
        </RegistryKey>
        <RegistryKey Root="HKLM" Key="SOFTWARE\Classes\Notepad++.txt">
          <RegistryValue Type="string" Value="Text Document" />
          <RegistryKey Key="DefaultIcon">
            <RegistryValue Type="string" Value="[INSTALLFOLDER]notepad++.exe,0" />
          </RegistryKey>
          <RegistryKey Key="shell\open\command">
            <RegistryValue Type="string" Value='"[INSTALLFOLDER]notepad++.exe" "%1"' />
          </RegistryKey>
        </RegistryKey>
        <RegistryKey Root="HKLM" Key="SOFTWARE\Classes\Notepad++.log">
          <RegistryValue Type="string" Value="Log File" />
          <RegistryKey Key="DefaultIcon">
            <RegistryValue Type="string" Value="[INSTALLFOLDER]notepad++.exe,0" />
          </RegistryKey>
          <RegistryKey Key="shell\open\command">
            <RegistryValue Type="string" Value='"[INSTALLFOLDER]notepad++.exe" "%1"' />
          </RegistryKey>
        </RegistryKey>
      </Component>
      
      <Component Id="DisableUpdates" Guid="{BBBB2222-3333-4444-5555-666666666666}" Win64="yes">
        <RegistryKey Root="HKLM" Key="SOFTWARE\Notepad++">
          <RegistryValue Name="noUpdate" Type="integer" Value="1" KeyPath="yes" />
        </RegistryKey>
      </Component>
    </DirectoryRef>
    
    <!-- Start Menu Shortcut -->
    <DirectoryRef Id="ApplicationProgramsFolder">
      <Component Id="ApplicationShortcut" Guid="{CCCC3333-4444-5555-6666-777777777777}" Win64="yes">
        <Shortcut Id="ApplicationStartMenuShortcut"
                  Name="Notepad++"
                  Target="[INSTALLFOLDER]notepad++.exe"
                  WorkingDirectory="INSTALLFOLDER"
                  Icon="NotepadIcon" />
        <RemoveFolder Id="CleanUpShortCut" On="uninstall" />
        <RegistryValue Root="HKCU" Key="Software\Notepad++\Installer" Name="installed" Type="integer" Value="1" KeyPath="yes" />
      </Component>
    </DirectoryRef>
    
    <!-- Desktop Shortcut -->
    <DirectoryRef Id="DesktopFolder">
      <Component Id="DesktopShortcut" Guid="{DDDD4444-5555-6666-7777-888888888888}" Win64="yes">
        <Shortcut Id="DesktopShortcutId"
                  Name="Notepad++"
                  Target="[INSTALLFOLDER]notepad++.exe"
                  WorkingDirectory="INSTALLFOLDER"
                  Icon="NotepadIcon" />
        <RegistryValue Root="HKCU" Key="Software\Notepad++\Desktop" Name="shortcut" Type="integer" Value="1" KeyPath="yes" />
      </Component>
    </DirectoryRef>
    
    <Icon Id="NotepadIcon" SourceFile="NPP\notepad++.exe" />
    
    <Feature Id="Complete" Title="Notepad++ Complete" Level="1">
      <ComponentRef Id="FileAssociations" />
      <ComponentRef Id="DisableUpdates" />
      <ComponentRef Id="ApplicationShortcut" />
      <ComponentRef Id="DesktopShortcut" />
      <ComponentGroupRef Id="HarvestedFiles" />
    </Feature>
  </Product>
</Wix>
'@

$productWxs | Out-File "$OutputDir\product.wxs" -Encoding UTF8

# Use Heat to harvest all files
Write-Host "Harvesting files with Heat..." -ForegroundColor Yellow
& "$wixPath\heat.exe" dir "$nppDir" -cg HarvestedFiles -gg -scom -sreg -sfrag -srd -dr INSTALLFOLDER -out "$OutputDir\files.wxs" -var var.SourceDir 2>&1 | Out-Host

# Build MSI
Write-Host "Building MSI package..." -ForegroundColor Yellow
& "$wixPath\candle.exe" "$OutputDir\product.wxs" "$OutputDir\files.wxs" -dSourceDir="$nppDir" -arch x64 -out "$OutputDir\" 2>&1 | Out-Host
& "$wixPath\light.exe" "$OutputDir\product.wixobj" "$OutputDir\files.wixobj" -out "$FinalOutput\Notepad++.msi" -sice:ICE38 -sice:ICE64 -sice:ICE91 -sice:ICE80 -sice:ICE30 2>&1 | Out-Host

if (Test-Path "$FinalOutput\Notepad++.msi") {
    Write-Host "SUCCESS! MSI created" -ForegroundColor Green
    
    # Create documentation
    $doc = @"
Notepad++ Enterprise MSI Package - C:\Apps Version
==================================================

Version: 8.8.2 x64
Build Date: $(Get-Date -Format "yyyy-MM-dd HH:mm")

INSTALLATION LOCATION:
C:\Apps\Notepad++\

FEATURES IMPLEMENTED:
✓ Notepad++ x64 version
✓ Latvian UI language (default)
✓ Automatic updates disabled
✓ Compare plugin installed
✓ File associations (.txt, .log)
✓ 99er theme as DEFAULT
✓ Per-machine installation
✓ Desktop and Start Menu shortcuts

CONFIGURATION:
- Location: C:\Apps\Notepad++\
- config.xml - Main configuration with Latvian + 99er theme
- stylers.model.xml - Theme configuration  
- doLocalConf.xml - Forces local config mode
- themes\99er.xml - 99er theme file
- NO AppData usage!

INSTALLATION:
Silent: msiexec /i "Notepad++.msi" /qn
Basic UI: msiexec /i "Notepad++.msi" /qb
Full UI: msiexec /i "Notepad++.msi"

UNINSTALL:
Silent: msiexec /x "Notepad++.msi" /qn
Basic UI: msiexec /x "Notepad++.msi" /qb

KEY BENEFITS:
- Installed in C:\Apps (no Program Files restrictions)
- All users get same configuration
- doLocalConf.xml ensures local config usage
- Enterprise-ready deployment

SHORTCUTS CREATED:
- Desktop: Notepad++ shortcut
- Start Menu: Programs\Notepad++\Notepad++

This version combines portable functionality with 
proper MSI installation in the Apps directory.
"@
    
    $doc | Out-File "$FinalOutput\Documentation.txt" -Encoding UTF8
    
    # Create final ZIP
    $zipPath = "$FinalOutput\Notepad++_Apps.zip"
    Compress-Archive -Path "$FinalOutput\Notepad++.msi", "$FinalOutput\Documentation.txt" -DestinationPath $zipPath -Force
    
    Write-Host "`nC:\APPS PACKAGE READY!" -ForegroundColor Green
    Write-Host "Location: $zipPath" -ForegroundColor Cyan
    Write-Host "`nInstalls to: C:\Apps\Notepad++ with local config!" -ForegroundColor Yellow
    
    # Clean build directory
    Remove-Item $OutputDir -Recurse -Force -ErrorAction SilentlyContinue
    
} else {
    Write-Host "Build failed!" -ForegroundColor Red
}

Write-Host "`nDone!" -ForegroundColor Cyan