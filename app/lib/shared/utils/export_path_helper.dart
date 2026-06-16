import 'dart:io';

class ExportPathHelper {
  /// Obtiene el directorio de exportación ('csv' o 'pdf') relativo al lugar
  /// donde se encuentra la aplicación o el AppImage.
  static Directory getExportDir(String folderName) {
    String baseDirPath;

    // 1. Verificamos si estamos corriendo como un AppImage en Linux
    final appImagePath = Platform.environment['APPIMAGE'];
    if (appImagePath != null && appImagePath.isNotEmpty) {
      // El archivo AppImage se encuentra aquí
      baseDirPath = File(appImagePath).parent.path;
    } else {
      // 2. Si no es AppImage, intentamos usar el directorio actual de ejecución,
      // o el directorio del ejecutable.
      // Para entornos de producción (exe en Windows, por ejemplo),
      // Platform.resolvedExecutable.parent es ideal si queremos que esté junto al exe.
      // Sin embargo, para desarrollo o ejecución general, usamos el path actual.
      // Vamos a priorizar la ubicación del ejecutable si no estamos en entorno dev (como flutter run).
      if (Platform.resolvedExecutable.contains('flutter') ||
          Platform.resolvedExecutable.contains('dart')) {
        baseDirPath = Directory.current.path;
      } else {
        baseDirPath = File(Platform.resolvedExecutable).parent.path;
      }
    }

    final exportDir = Directory(
      '$baseDirPath${Platform.pathSeparator}$folderName',
    );

    if (!exportDir.existsSync()) {
      exportDir.createSync(recursive: true);
    }

    return exportDir;
  }
}
