; Inno Setup 6 script for the Prism Browser installer.
; Built by scripts/build_windows.ps1 -Installer, which passes the version:
;   ISCC.exe /DAppVersion=0.3.0 [/DBundleWebView2] installer\prism_browser.iss

#ifndef AppVersion
  #define AppVersion "0.0.0"
#endif
#define AppName "Prism Browser"
#define AppExe "prism_browser.exe"
#define ProgId "PrismBrowserHTML"
#define SourceDir "..\build\windows\x64\runner\Release"

[Setup]
AppId={{5E1C3C4A-6B8E-4E8F-9C2B-7A1D3F0B9E21}
AppName={#AppName}
AppVersion={#AppVersion}
AppVerName={#AppName} {#AppVersion}
AppPublisher=Prism Browser contributors
AppPublisherURL=https://github.com/wepper6200/Prism-Browser
DefaultDirName={autopf}\{#AppName}
DefaultGroupName={#AppName}
DisableProgramGroupPage=yes
; Per-user by default (no UAC prompt); the dialog offers an all-users install.
PrivilegesRequired=lowest
PrivilegesRequiredOverridesAllowed=dialog
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
MinVersion=10.0
CloseApplications=yes
SetupIconFile=..\windows\runner\resources\app_icon.ico
UninstallDisplayIcon={app}\{#AppExe}
UninstallDisplayName={#AppName}
OutputDir=..\dist
OutputBaseFilename=PrismBrowser-{#AppVersion}-windows-x64-setup
Compression=lzma2/max
SolidCompression=yes
WizardStyle=modern

[Languages]
Name: "ru"; MessagesFile: "compiler:Languages\Russian.isl"
Name: "en"; MessagesFile: "compiler:Default.isl"

[CustomMessages]
en.BrowserTask=Register {#AppName} as a web browser (can be chosen as default in Windows Settings)
ru.BrowserTask=Зарегистрировать {#AppName} как браузер (его можно будет выбрать по умолчанию в параметрах Windows)
en.InstallingWebView2=Installing Microsoft Edge WebView2 Runtime...
ru.InstallingWebView2=Установка Microsoft Edge WebView2 Runtime...

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked
Name: "browser"; Description: "{cm:BrowserTask}"

[Files]
Source: "{#SourceDir}\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs
#ifdef BundleWebView2
Source: "MicrosoftEdgeWebview2Setup.exe"; DestDir: "{tmp}"; Flags: deleteafterinstall; Check: NeedsWebView2
#endif

[Icons]
Name: "{autoprograms}\{#AppName}"; Filename: "{app}\{#AppExe}"
Name: "{autodesktop}\{#AppName}"; Filename: "{app}\{#AppExe}"; Tasks: desktopicon

[Registry]
; Browser registration (Default Apps). HKA = HKCU per-user, HKLM all users.
Root: HKA; Subkey: "Software\Classes\{#ProgId}"; ValueType: string; ValueName: ""; ValueData: "{#AppName} HTML Document"; Flags: uninsdeletekey; Tasks: browser
Root: HKA; Subkey: "Software\Classes\{#ProgId}\DefaultIcon"; ValueType: string; ValueName: ""; ValueData: """{app}\{#AppExe}"",0"; Tasks: browser
Root: HKA; Subkey: "Software\Classes\{#ProgId}\shell\open\command"; ValueType: string; ValueName: ""; ValueData: """{app}\{#AppExe}"" ""%1"""; Tasks: browser
Root: HKA; Subkey: "Software\Clients\StartMenuInternet\PrismBrowser"; ValueType: string; ValueName: ""; ValueData: "{#AppName}"; Flags: uninsdeletekey; Tasks: browser
Root: HKA; Subkey: "Software\Clients\StartMenuInternet\PrismBrowser\DefaultIcon"; ValueType: string; ValueName: ""; ValueData: """{app}\{#AppExe}"",0"; Tasks: browser
Root: HKA; Subkey: "Software\Clients\StartMenuInternet\PrismBrowser\shell\open\command"; ValueType: string; ValueName: ""; ValueData: """{app}\{#AppExe}"""; Tasks: browser
Root: HKA; Subkey: "Software\Clients\StartMenuInternet\PrismBrowser\Capabilities"; ValueType: string; ValueName: "ApplicationName"; ValueData: "{#AppName}"; Tasks: browser
Root: HKA; Subkey: "Software\Clients\StartMenuInternet\PrismBrowser\Capabilities"; ValueType: string; ValueName: "ApplicationDescription"; ValueData: "Fast, private browser"; Tasks: browser
Root: HKA; Subkey: "Software\Clients\StartMenuInternet\PrismBrowser\Capabilities"; ValueType: string; ValueName: "ApplicationIcon"; ValueData: """{app}\{#AppExe}"",0"; Tasks: browser
Root: HKA; Subkey: "Software\Clients\StartMenuInternet\PrismBrowser\Capabilities\URLAssociations"; ValueType: string; ValueName: "http"; ValueData: "{#ProgId}"; Tasks: browser
Root: HKA; Subkey: "Software\Clients\StartMenuInternet\PrismBrowser\Capabilities\URLAssociations"; ValueType: string; ValueName: "https"; ValueData: "{#ProgId}"; Tasks: browser
Root: HKA; Subkey: "Software\Clients\StartMenuInternet\PrismBrowser\Capabilities\FileAssociations"; ValueType: string; ValueName: ".html"; ValueData: "{#ProgId}"; Tasks: browser
Root: HKA; Subkey: "Software\Clients\StartMenuInternet\PrismBrowser\Capabilities\FileAssociations"; ValueType: string; ValueName: ".htm"; ValueData: "{#ProgId}"; Tasks: browser
Root: HKA; Subkey: "Software\RegisteredApplications"; ValueType: string; ValueName: "PrismBrowser"; ValueData: "Software\Clients\StartMenuInternet\PrismBrowser\Capabilities"; Flags: uninsdeletevalue; Tasks: browser

[Run]
#ifdef BundleWebView2
; Pages are rendered by WebView2. Windows 11 ships it; older systems get the
; official Evergreen runtime (silent, per-machine bootstrapper).
Filename: "{tmp}\MicrosoftEdgeWebview2Setup.exe"; Parameters: "/silent /install"; StatusMsg: "{cm:InstallingWebView2}"; Flags: waituntilterminated; Check: NeedsWebView2
#endif
Filename: "{app}\{#AppExe}"; Description: "{cm:LaunchProgram,{#AppName}}"; Flags: nowait postinstall skipifsilent

[UninstallDelete]
; WebView2 profile (cookies, cache) is removed with the app; settings
; (shared_preferences) stay unless the user removes them.
Type: filesandordirs; Name: "{localappdata}\Prism\Prism Browser\webview2"

[Code]
const
  WebView2Key = 'SOFTWARE\WOW6432Node\Microsoft\EdgeUpdate\Clients\{F3017226-FE2A-4295-8BDF-00C3A9A7E4C5}';
  WebView2KeyUser = 'Software\Microsoft\EdgeUpdate\Clients\{F3017226-FE2A-4295-8BDF-00C3A9A7E4C5}';

function HasVersion(Root: Integer; Key: string): Boolean;
var
  V: string;
begin
  Result := RegQueryStringValue(Root, Key, 'pv', V) and (V <> '') and (V <> '0.0.0.0');
end;

function NeedsWebView2: Boolean;
begin
  Result := not (HasVersion(HKLM, WebView2Key) or HasVersion(HKCU, WebView2KeyUser));
end;
