; Script generated by the Inno Script Studio Wizard.
; SEE THE DOCUMENTATION FOR DETAILS ON CREATING INNO SETUP SCRIPT FILES!

#define MyAppName "Product Overlay Generator"
#define MyAppVersion "1.0"
#define MyAppPublisher "Wade Murdock"
#define MyAppURL "https://hbdgmain.sharepoint.com/:w:/s/Technology/EbGgjDpRTJ5Lvu4KoGZkm-MBbs4T3D_8Yt7vLZYf-mlhzQ?e=3DC5A0"
#define MyAppExeName "Product Overlay Generator.exe"
#define MyUninstallerName "Uninstall"

[Setup]
;PrivilegesRequired=lowest
; NOTE: The value of AppId uniquely identifies this application.
; Do not use the same AppId value in installers for other applications.
; (To generate a new GUID, click Tools | Generate GUID inside the IDE.)
AppId={{A3F60414-DABC-4CBE-ABE7-15D296D296A1}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
;AppVerName={#MyAppName} {#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}
DefaultDirName={pf}\{#MyAppName}
DefaultGroupName={#MyAppName}
OutputBaseFilename=Product Overlay Generator
SetupIconFile=HewnFloorIcon.ico
Compression=none
;SolidCompression=yes
AlwaysRestart=False
ArchitecturesInstallIn64BitMode=x64
UninstallFilesDir={app}\Uninstall
UninstallDisplayIcon={app}\{#MyAppExeName}
UninstallDisplayName={#MyAppName}

[Messages]
SetupAppTitle = Setup - {#MyAppName}
SetupWindowTitle = Setup - {#MyAppName}

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Dirs]
Name: "{app}\Uninstall"; Attribs: hidden

[Files]
Source: "Product Overlay Generator.exe"; DestDir: "{app}";
Source: "Overlays\*"; DestDir: "{app}\Overlays";
Source: "_assets\*"; DestDir: "{app}\_assets";
; NOTE: Don't use "Flags: ignoreversion" on any shared system files

[Icons]
Name: "{app}\{#MyUninstallerName}"; Filename: "{app}\Uninstall\unins000.exe"
Name: "{userprograms}\Product Overlay Generator"; Filename: "{app}\Product Overlay Generator.exe"

[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "Launch Product Overlay Generator"; Flags: postinstall nowait skipifsilent

[UninstallDelete]
Type: files; Name: "{app}\Product Overlay Generator.exe"
Type: filesandordirs; Name: "{app}\_assets"
Type: filesandordirs; Name: "{app}\Overlays"
Type: dirifempty; Name: "{app}"

[Code]
function InitializeUninstall(): Boolean;
  var ErrorCode: Integer;
begin
  ShellExec('open','taskkill.exe','/f /im "Product Overlay Generator.exe"','',SW_HIDE,ewNoWait,ErrorCode);
  ShellExec('open','tskill.exe',' Product Overlay Generator.exe','',SW_HIDE,ewNoWait,ErrorCode);
  result := True;
end;