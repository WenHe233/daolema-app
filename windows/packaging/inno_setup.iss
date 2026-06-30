#ifndef MyAppVersion
  #define MyAppVersion "0.0.0"
#endif

#ifndef ArtifactLabel
  #define ArtifactLabel MyAppVersion
#endif

#define MyAppName "导了吗"
#define MyAppExeName "daolema.exe"

[Setup]
AppId={{7A6BC16E-35B0-4B88-A901-CFFEC4B69C82}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher=Daolema Contributors
DefaultDirName={localappdata}\Programs\Daolema
DefaultGroupName={#MyAppName}
DisableProgramGroupPage=yes
PrivilegesRequired=lowest
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
OutputDir=dist
OutputBaseFilename=Daolema-{#ArtifactLabel}-windows-x64-setup
SetupIconFile=..\runner\resources\app_icon.ico
Compression=lzma2
SolidCompression=yes
WizardStyle=modern
UninstallDisplayIcon={app}\{#MyAppExeName}

[Files]
Source: "..\..\build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{autoprograms}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon

[Tasks]
Name: "desktopicon"; Description: "创建桌面快捷方式"; GroupDescription: "附加图标："; Flags: unchecked

[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "启动 {#MyAppName}"; Flags: nowait postinstall skipifsilent
