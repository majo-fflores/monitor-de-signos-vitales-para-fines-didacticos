; ==============================================================================
; DATA VITAL - INNO SETUP INSTALLER CONFIGURATION
; ==============================================================================
; Requiere: Inno Setup 6.x (https://jrsoftware.org/isinfo.php)
; Compilar: Abrir en Inno Setup Compiler > Ctrl+F9
; ==============================================================================

; --- Constantes del proyecto (centralizar cambios de versión aquí) ---
#define AppName "DataVital"
#define AppVersion "1.0.0"
#define AppPublisher "(JATC) - Just Another Tech Company"
#define AppCopyright "Copyright (C) 2026 " + AppPublisher
#define AppURL ""
#define AppExeName "DataVital.exe"

[Setup]
; --- Identificación única (NO cambiar entre versiones) ---
AppId={{E91CA367-A1FA-4A59-BD79-DFD5523910F1}
AppName={#AppName}
AppVersion={#AppVersion}

; --- Metadatos del publicador y branding ---
AppPublisher={#AppPublisher}
AppPublisherURL={#AppURL}
AppSupportURL={#AppURL}
AppUpdatesURL={#AppURL}
AppCopyright={#AppCopyright}

; --- Información de versión embebida en el binario del instalador ---
VersionInfoVersion={#AppVersion}
VersionInfoCompany={#AppPublisher}
VersionInfoCopyright={#AppCopyright}
VersionInfoProductName={#AppName}
VersionInfoProductVersion={#AppVersion}
VersionInfoDescription=Instalador de {#AppName}

; --- Rutas de instalación ---
DefaultDirName={autopf}\{#AppName}
DefaultGroupName={#AppName}
DisableProgramGroupPage=yes
DisableWelcomePage=no

; --- Arquitectura: Solo sistemas 64-bit (x64 y ARM64) ---
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible

; --- Versión mínima de Windows: Windows 10 ---
MinVersion=10.0

; --- Privilegios: Admin requerido, con opción de override para el usuario ---
PrivilegesRequired=admin
PrivilegesRequiredOverridesAllowed=dialog

; --- Prevenir instalaciones concurrentes (mutex) ---
SetupMutex=DataVitalSetupMutex
AppMutex=Local\DataVitalSingleInstanceMutex
UsedUserAreasWarning=no

; --- Gestión de aplicaciones en ejecución ---
CloseApplications=yes
CloseApplicationsFilter=*.exe
RestartApplications=yes

; --- Compilación y salida ---
OutputDir=..\..\build\windows\dist
OutputBaseFilename=DataVital-Installer
SetupIconFile=runner\resources\app_icon.ico
Compression=lzma2
SolidCompression=yes

; --- Icono mostrado en "Agregar o quitar programas" ---
UninstallDisplayIcon={app}\{#AppExeName}
UninstallDisplayName={#AppName}

; --- Estilo visual moderno ---
WizardStyle=modern
WizardSizePercent=120,120

; Assets visuales del wizard
WizardImageFile=..\assets\installer\wizard_side.bmp

; Color de fondo de la imagen lateral
; Para #5E5CE6: RR=5E, GG=5C, BB=E6. El valor BGR resultante es $E65C5E.
WizardImageBackColor=$E65C5E
WizardImageBackColorDynamicDark=$242424

[Languages]
Name: "spanish"; MessagesFile: "compiler:Languages\Spanish.isl"

[Messages]
spanish.WelcomeLabel1=Bienvenido al asistente de instalación de DataVital
spanish.WelcomeLabel2=Este asistente guiará el proceso de instalación de DataVital en su sistema, la plataforma inteligente para el monitoreo, adquisición y visualización de bioseñales en tiempo real.%n%nSe recomienda cerrar todas las demás aplicaciones antes de continuar para asegurar una instalación sin conflictos.

[Files]
; Frontend Flutter
Source: "..\..\build\windows\dist\{#AppExeName}"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\..\build\windows\dist\*.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\..\build\windows\dist\data\*"; DestDir: "{app}\data"; Flags: ignoreversion recursesubdirs createallsubdirs
; Backend Go
Source: "..\..\build\windows\dist\datavital-backend.exe"; DestDir: "{app}"; Flags: ignoreversion
; Iconos
Source: "runner\resources\app_icon_shortcut.ico"; DestDir: "{app}"; Flags: ignoreversion

[Icons]
Name: "{group}\{#AppName}"; Filename: "{app}\{#AppExeName}"; IconFilename: "{app}\app_icon_shortcut.ico"
Name: "{autodesktop}\{#AppName}"; Filename: "{app}\{#AppExeName}"; IconFilename: "{app}\app_icon_shortcut.ico"; Check: ShouldCreateDesktopIcon

[Run]
; Agregar excepción de firewall para que el backend pueda escuchar en localhost
Filename: "netsh"; Parameters: "advfirewall firewall add rule name=""DataVital Backend"" dir=in action=allow program=""{app}\datavital-backend.exe"" enable=yes"; Flags: runhidden; StatusMsg: "Configurando firewall..."
Filename: "{app}\{#AppExeName}"; Description: "{cm:LaunchProgram,{#StringChange(AppName, '&', '&&')}}"; Flags: nowait postinstall skipifsilent

[UninstallRun]
; Eliminar la regla de firewall al desinstalar
Filename: "netsh"; Parameters: "advfirewall firewall delete rule name=""DataVital Backend"""; Flags: runhidden; RunOnceId: "DeleteFirewallRule"
; Asegurarse de que el backend esté detenido antes de borrar archivos
Filename: "taskkill"; Parameters: "/F /IM datavital-backend.exe"; Flags: runhidden; RunOnceId: "KillBackend"

[UninstallDelete]
; Limpiar archivos generados por la app en tiempo de ejecución
Type: filesandordirs; Name: "{app}\data"
Type: files; Name: "{app}\app_icon_shortcut.ico"
Type: files; Name: "{app}\datavital-backend.exe"
; Limpiar base de datos local creada por el backend
Type: filesandordirs; Name: "{userdocs}\..\.datavital"

[Code]
var
  CreateDesktopIconCheckBox: TNewCheckBox;

procedure InitializeWizard;
var
  ImageWidthDiff: Integer;
begin
  // 1. PÁGINA DE BIENVENIDA (WelcomePage)
  ImageWidthDiff := ScaleX(250) - WizardForm.WizardBitmapImage.Width;
  WizardForm.WizardBitmapImage.Width := ScaleX(250);
  
  WizardForm.WelcomeLabel1.Left := WizardForm.WelcomeLabel1.Left + ImageWidthDiff;
  WizardForm.WelcomeLabel1.Width := WizardForm.WelcomeLabel1.Width - ImageWidthDiff;
  WizardForm.WelcomeLabel2.Left := WizardForm.WelcomeLabel2.Left + ImageWidthDiff;
  WizardForm.WelcomeLabel2.Width := WizardForm.WelcomeLabel2.Width - ImageWidthDiff;

  // 2. PÁGINA DE SELECCIÓN DE DIRECTORIO (SelectDirPage)
  CreateDesktopIconCheckBox := TNewCheckBox.Create(WizardForm);
  CreateDesktopIconCheckBox.Parent := WizardForm.SelectDirPage;
  CreateDesktopIconCheckBox.Left := WizardForm.DirEdit.Left;
  CreateDesktopIconCheckBox.Top := WizardForm.DirEdit.Top + WizardForm.DirEdit.Height + ScaleY(20);
  CreateDesktopIconCheckBox.Width := WizardForm.DirEdit.Width;
  CreateDesktopIconCheckBox.Height := ScaleY(20);
  CreateDesktopIconCheckBox.Caption := 'Crear un acceso directo en el Escritorio';
  CreateDesktopIconCheckBox.Checked := True; 

  // 3. PÁGINA DE FINALIZACIÓN (FinishedPage)
  // Hacer visible la imagen lateral
  WizardForm.WizardBitmapImage2.Visible := True;
  
  // Incrementar el ancho de la imagen a 250 píxeles
  WizardForm.WizardBitmapImage2.Width := ScaleX(250);
  
  // Desplazar las etiquetas de texto a la derecha para adaptarlas al nuevo ancho
  WizardForm.FinishedHeadingLabel.Left := WizardForm.FinishedHeadingLabel.Left + ImageWidthDiff;
  WizardForm.FinishedHeadingLabel.Width := WizardForm.FinishedHeadingLabel.Width - ImageWidthDiff;
  WizardForm.FinishedHeadingLabel.Alignment := taLeftJustify;
  
  WizardForm.FinishedLabel.Left := WizardForm.FinishedLabel.Left + ImageWidthDiff;
  WizardForm.FinishedLabel.Width := WizardForm.FinishedLabel.Width - ImageWidthDiff;
  WizardForm.FinishedLabel.Alignment := taLeftJustify;
  
  // Desplazar el checkbox "Ejecutar..." a la derecha
  WizardForm.RunList.Left := WizardForm.RunList.Left + ImageWidthDiff;
  WizardForm.RunList.Width := WizardForm.RunList.Width - ImageWidthDiff;
end;

function ShouldCreateDesktopIcon: Boolean;
begin
  Result := CreateDesktopIconCheckBox.Checked;
end;
