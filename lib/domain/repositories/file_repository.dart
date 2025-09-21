abstract class FileRepository {
  Future<String> uploadFile(List<int> fileBytes, String fileName);
  Future<void> deleteFile(String fileUrl);
  Future<List<int>> downloadFile(String fileUrl);
}