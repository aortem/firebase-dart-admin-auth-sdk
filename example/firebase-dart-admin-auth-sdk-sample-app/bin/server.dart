import 'dart:io';
import 'package:path/path.dart' as p;

void main() async {
  // Set the server port
  var port = int.parse(Platform.environment['PORT'] ?? '8080');

  // Set the directory where the web assets are located
  var webDir = Directory(p.join(Directory.current.path, 'build', 'web'));

  var server = await HttpServer.bind(InternetAddress.anyIPv4, port);
  print('Server running on port $port');

  await for (HttpRequest request in server) {
    var path = request.uri.path;

    // Ensure that all paths are relative to the webDir (build/web) and not from the root directory
    var normalizedPath = path.startsWith('/') ? path.substring(1) : path;
    var filePath = p.join(
        webDir.path, normalizedPath == '' ? 'index.html' : normalizedPath);

    // Logging: Print the file path being served for debugging
    print('Serving file: $filePath');

    var file = File(filePath);
    if (await file.exists()) {
      var mimeType = lookupMimeType(filePath) ?? 'text/plain';
      request.response.headers.contentType = ContentType.parse(mimeType);

      // Logging: Print successful serving of file
      print('File served successfully: $filePath');

      await request.response.addStream(file.openRead());
      await request.response.close();
    } else {
      request.response.statusCode = HttpStatus.notFound;

      // Logging: Print 404 error if file not found
      print('File not found: $filePath (404)');

      await request.response.close();
    }
  }
}

String? lookupMimeType(String path) {
  final extension = p.extension(path);
  switch (extension) {
    case '.html':
      return 'text/html';
    case '.css':
      return 'text/css';
    case '.js':
      return 'application/javascript'; // Correct MIME type for JS
    case '.png':
      return 'image/png';
    case '.jpg':
    case '.jpeg':
      return 'image/jpeg';
    case '.json':
      return 'application/json';
    default:
      return 'text/plain';
  }
}
