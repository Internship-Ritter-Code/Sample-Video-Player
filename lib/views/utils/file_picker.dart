import 'dart:io';

import 'package:file_picker/file_picker.dart';

class FilePick {
  Future<File?> pickAFile() async {
    var data = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: [
        "mp4",
        "3gp",
        "mkv",
        "avi",
      ],
    );
    if (data != null) {
      var file = File(data.files.first.path!);
      return file;
    }
    return null;
  }
}
