; NOVATERRA per-user installer for the verified Windows x64 portable build.
; Development installer is unsigned; production signing is a separate release gate.
#define MyAppName "NOVATERRA"
#define MyAppVersion "1.2.0-dev"
[Setup]
AppId={{0E563F46-3A0A-4F74-8A0B-4A9930F073E4}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppVerName=NOVATERRA {#MyAppVersion}
AppPublisher=NOVATERRA
AppPublisherURL=https://github.com/bren-wp/NOVATERRA
DefaultDirName={localappdata}\Programs\NOVATERRA
DefaultGroupName=NOVATERRA
DisableProgramGroupPage=yes
PrivilegesRequired=lowest
OutputDir=..\artifacts
OutputBaseFilename=NOVATERRA-Windows-Setup-v1.2.0-dev
Compression=lzma2
SolidCompression=yes
WizardStyle=modern
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
UninstallDisplayIcon={app}\NOVATERRA.exe
VersionInfoVersion=1.2.0.0
VersionInfoDescription=NOVATERRA Windows Development Installer
[Tasks]
Name: "desktopicon"; Description: "Create desktop shortcut"; GroupDescription: "Additional shortcuts:"
[Files]
Source: "..\build\staging\NOVATERRA\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs
[Icons]
Name: "{autoprograms}\NOVATERRA"; Filename: "{app}\NOVATERRA.exe"
Name: "{autodesktop}\NOVATERRA"; Filename: "{app}\NOVATERRA.exe"; Tasks: desktopicon
[Run]
Filename: "{app}\NOVATERRA.exe"; Description: "Launch NOVATERRA"; Flags: nowait postinstall skipifsilent
