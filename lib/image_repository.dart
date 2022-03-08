import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';

class ImageRepository {
  Dio dio = Dio(BaseOptions(
      connectTimeout: 60 * 1000, // 60 seconds
      receiveTimeout: 60 * 1000,
      sendTimeout: 60 * 1000 // 60 seconds
      ));
  Future<String?> uploadImage(File file) async {
    try {
      FormData formData = FormData.fromMap(
        {
          "file": await MultipartFile.fromFile(file.path),
          "downsample": "true",
        },
      );
      var response = await dio.post(
        "http://15.206.253.19:8080/enhance",
        data: formData,
      );
      log(
        response.data.toString(),
      );
      return response.data["enhanced"];
    } on DioError catch (e) {
      log(
        e.toString(),
      );
    }
  }
}
