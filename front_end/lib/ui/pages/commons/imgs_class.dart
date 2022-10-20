import 'dart:io';
import 'package:http/http.dart';
import 'package:path_provider/path_provider.dart';

class UsersImgs {
  static String _localPath = '';

  static Future<File> getLocalFilePath(userName, imageId) async {
    if (_localPath.isEmpty) {
      _localPath = await getImageStoragePath();
    }

    File imgFile =
        File('$_localPath/${userName}_@_${imageId.split('id=')[1]}.jpg');

    if (!imgFile.existsSync()) {
      Uri imageUrl = Uri.parse(imageId);
      Response image = await get(imageUrl);
      imgFile.writeAsBytesSync(image.bodyBytes);
    }

    return imgFile;
  }

  static Future<String> getImageStoragePath() async {
    final Directory appDocPath = await getApplicationDocumentsDirectory();
    Directory('${appDocPath.path.replaceAll('\\', '/')}/imgs')
        .create(recursive: true);
    return '${appDocPath.path.replaceAll('\\', '/')}/imgs';
  }
}
