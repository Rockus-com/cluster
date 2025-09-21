import 'package:dio/dio.dart';

import '../../../domain/repositories/file_repository.dart';
import '../../services/http_service.dart';

class FileRepositoryImpl implements FileRepository {
  final HttpService httpService;

  FileRepositoryImpl({required this.httpService});

  @override
  Future<String> uploadFile(List<int> fileBytes, String fileName) async {
    try {
      final response = await httpService.post(
        '/upload-file',
        data: FormData.fromMap({
          'file': MultipartFile.fromBytes(fileBytes, filename: fileName),
          'filename': fileName,
        }),
      );
      return response.data['file_url'];
    } on DioError catch (e) {
      throw Exception(e.response?.data['detail'] ?? 'Failed to upload file');
    }
  }

  @override
  Future<void> deleteFile(String fileUrl) async {
    try {
      await httpService.delete('/files', data: {'file_url': fileUrl});
    } on DioError catch (e) {
      throw Exception(e.response?.data['detail'] ?? 'Failed to delete file');
    }
  }

  @override
  Future<List<int>> downloadFile(String fileUrl) async {
    try {
      final response = await httpService.get(
        '/download-file',
        queryParameters: {'file_url': fileUrl},
        options: Options(responseType: ResponseType.bytes),
      );
      return List<int>.from(response.data);
    } on DioError catch (e) {
      throw Exception(e.response?.data['detail'] ?? 'Failed to download file');
    }
  }
}