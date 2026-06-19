#include <flutter/dart_project.h>
#include <flutter/flutter_view_controller.h>
#include <windows.h>
#include <string>

#include "flutter_window.h"
#include "utils.h"

// ==============================================================================
// BACKEND PROCESS MANAGEMENT
// ==============================================================================
// El backend Go (datavital-backend.exe) se lanza como proceso hijo sin ventana
// de consola. Se busca en el mismo directorio que el ejecutable principal.
// Al cerrar la aplicación Flutter, el backend se termina limpiamente.
// ==============================================================================

static PROCESS_INFORMATION g_backendProcessInfo = {};
static bool g_backendRunning = false;

// Lanza datavital-backend.exe como proceso hijo oculto (sin ventana de consola).
// Retorna true si el proceso se lanzó exitosamente.
static bool LaunchBackendProcess() {
  // Obtener la ruta del directorio donde está el ejecutable actual
  wchar_t exePath[MAX_PATH];
  DWORD len = ::GetModuleFileNameW(nullptr, exePath, MAX_PATH);
  if (len == 0 || len >= MAX_PATH) {
    return false;
  }

  // Quitar el nombre del ejecutable para quedarnos solo con el directorio
  std::wstring exeDir(exePath);
  size_t lastSlash = exeDir.find_last_of(L"\\/");
  if (lastSlash != std::wstring::npos) {
    exeDir = exeDir.substr(0, lastSlash);
  }

  // Construir la ruta completa al backend
  std::wstring backendPath = exeDir + L"\\datavital-backend.exe";

  // Verificar que el archivo existe antes de intentar lanzarlo
  DWORD attribs = ::GetFileAttributesW(backendPath.c_str());
  if (attribs == INVALID_FILE_ATTRIBUTES) {
    // El backend no existe en el directorio; puede estar en modo desarrollo
    // donde el backend se ejecuta por separado. No es un error fatal.
    return false;
  }

  // Preparar el comando. Necesitamos un buffer mutable para CreateProcess.
  std::wstring cmdLine = L"\"" + backendPath + L"\"";
  std::vector<wchar_t> cmdLineBuf(cmdLine.begin(), cmdLine.end());
  cmdLineBuf.push_back(L'\0');

  STARTUPINFOW startupInfo = {};
  startupInfo.cb = sizeof(startupInfo);
  // Ocultar la ventana del proceso hijo
  startupInfo.dwFlags = STARTF_USESHOWWINDOW;
  startupInfo.wShowWindow = SW_HIDE;

  ZeroMemory(&g_backendProcessInfo, sizeof(g_backendProcessInfo));

  // Lanzar el backend sin ventana de consola
  BOOL success = ::CreateProcessW(
      backendPath.c_str(),    // Ruta del ejecutable
      cmdLineBuf.data(),      // Línea de comandos
      nullptr,                // Atributos de seguridad del proceso
      nullptr,                // Atributos de seguridad del hilo
      FALSE,                  // No heredar handles
      CREATE_NO_WINDOW,       // Sin ventana de consola
      nullptr,                // Usar variables de entorno del padre
      exeDir.c_str(),         // Directorio de trabajo = directorio del exe
      &startupInfo,
      &g_backendProcessInfo
  );

  if (success) {
    g_backendRunning = true;
    // Esperar un momento para que el backend inicialice el servidor HTTP
    ::Sleep(800);
  }

  return success == TRUE;
}

// Termina el proceso del backend de forma limpia.
static void TerminateBackendProcess() {
  if (!g_backendRunning) {
    return;
  }

  // Verificar si el proceso sigue vivo
  DWORD exitCode = 0;
  if (::GetExitCodeProcess(g_backendProcessInfo.hProcess, &exitCode) &&
      exitCode == STILL_ACTIVE) {
    // Terminar el proceso
    ::TerminateProcess(g_backendProcessInfo.hProcess, 0);
    // Esperar hasta 3 segundos a que termine
    ::WaitForSingleObject(g_backendProcessInfo.hProcess, 3000);
  }

  // Limpiar handles
  ::CloseHandle(g_backendProcessInfo.hProcess);
  ::CloseHandle(g_backendProcessInfo.hThread);
  ZeroMemory(&g_backendProcessInfo, sizeof(g_backendProcessInfo));
  g_backendRunning = false;
}

// ==============================================================================
// PUNTO DE ENTRADA PRINCIPAL
// ==============================================================================

int APIENTRY wWinMain(_In_ HINSTANCE instance, _In_opt_ HINSTANCE prev,
                      _In_ wchar_t *command_line, _In_ int show_command) {
  // Create a named mutex to ensure only one instance of the app is running.
  HANDLE mutex = ::CreateMutex(nullptr, TRUE, L"Local\\DataVitalSingleInstanceMutex");
  if (mutex == nullptr || ::GetLastError() == ERROR_ALREADY_EXISTS) {
    // If it already exists, find the existing window and bring it to the foreground
    HWND existing_window = ::FindWindow(L"FLUTTER_RUNNER_WIN32_WINDOW", L"DataVital");
    if (existing_window) {
      ::ShowWindow(existing_window, SW_SHOWNORMAL);
      ::SetForegroundWindow(existing_window);
    }
    if (mutex) {
      ::CloseHandle(mutex);
    }
    return EXIT_SUCCESS;
  }

  // Lanzar el backend Go antes de inicializar Flutter.
  // Si falla (ej: no existe el exe), la app sigue funcionando —
  // útil en modo desarrollo donde el backend se corre manualmente.
  LaunchBackendProcess();

  // Attach to console when present (e.g., 'flutter run') or create a
  // new console when running with a debugger.
  if (!::AttachConsole(ATTACH_PARENT_PROCESS) && ::IsDebuggerPresent()) {
    CreateAndAttachConsole();
  }

  // Initialize COM, so that it is available for use in the library and/or
  // plugins.
  ::CoInitializeEx(nullptr, COINIT_APARTMENTTHREADED);

  flutter::DartProject project(L"data");

  std::vector<std::string> command_line_arguments =
      GetCommandLineArguments();

  project.set_dart_entrypoint_arguments(std::move(command_line_arguments));

  FlutterWindow window(project);
  Win32Window::Point origin(10, 10);
  Win32Window::Size size(1280, 720);
  if (!window.Create(L"DataVital", origin, size)) {
    TerminateBackendProcess();
    ::CloseHandle(mutex);
    return EXIT_FAILURE;
  }
  window.SetQuitOnClose(true);

  ::MSG msg;
  while (::GetMessage(&msg, nullptr, 0, 0)) {
    ::TranslateMessage(&msg);
    ::DispatchMessage(&msg);
  }

  // Terminar el backend al cerrar la aplicación
  TerminateBackendProcess();

  ::CoUninitialize();
  ::ReleaseMutex(mutex);
  ::CloseHandle(mutex);
  return EXIT_SUCCESS;
}

