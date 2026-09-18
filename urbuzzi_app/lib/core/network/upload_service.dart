import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kDebugMode, debugPrint;

class UploadService {
  final Dio _dio;

  UploadService(this._dio);

  Future<String?> uploadFile(PlatformFile file) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          file.path!,
          filename: file.name,
        ),
      });

      // Rota apontando para o StorageController do core-service (Gateway)
      final response = await _dio.post(
        '/storage/upload', 
        data: formData,
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return response.data['url']; // Retorna a URL pública gerada no S3/R2
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Erro no upload: $e');
      }
    }
    return null;
  }
}
