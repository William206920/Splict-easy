#ifndef AppVersion
#define AppVersion "0.7.0"
#endif

[Setup]
AppId={{1F38F451-1DE5-46E2-88C3-B95B9B4D4491}
AppName=SplitEasy
AppVersion={#AppVersion}
AppPublisher=William206920
AppPublisherURL=https://github.com/William206920/Splict-easy
DefaultDirName={localappdata}\Programs\SplitEasy
DefaultGroupName=SplitEasy
PrivilegesRequired=lowest
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
MinVersion=10.0
OutputDir=..\dist\package
OutputBaseFilename=SplitEasy-{#AppVersion}-Windows-x64-Setup
Compression=lzma2
SolidCompression=yes
WizardStyle=modern
LicenseFile=..\LICENSE
UninstallDisplayIcon={app}\SplitEasy.exe

[Files]
Source: "..\dist\SplitEasy.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\dist\spliteasy-cli.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\LICENSE"; DestDir: "{app}"; Flags: ignoreversion

[Icons]
Name: "{group}\SplitEasy"; Filename: "{app}\SplitEasy.exe"

[Run]
Filename: "{app}\SplitEasy.exe"; Description: "Launch SplitEasy"; Flags: nowait postinstall skipifsilent

; User ledger files and LocalAppData\SplitEasy are deliberately not deleted.
