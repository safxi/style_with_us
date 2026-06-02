import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

/// Displays an [XFile] picked via `image_picker` in a platform-safe way.
///
/// On web a `File` object is not available, so we load the bytes and show
/// via [Image.memory]. On mobile/desktop we simply use [Image.file].
Widget buildPickedImage(XFile? picked, {double? height, BoxFit? fit}) {
  if (picked == null) return const SizedBox.shrink();
  if (kIsWeb) {
    return FutureBuilder<Uint8List>(
      future: picked.readAsBytes(),
      builder: (_, snap) {
        if (!snap.hasData) return const Center(child: CircularProgressIndicator());
        return Image.memory(
          snap.data!,
          height: height,
          fit: fit,
        );
      },
    );
  } else {
    return Image.file(
      File(picked.path),
      height: height,
      fit: fit,
    );
  }
}
