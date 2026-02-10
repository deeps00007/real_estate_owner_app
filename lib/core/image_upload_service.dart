import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ImageUploadService {
  static const String _privateKey = 'private_DAREKSumKgYgTAXq68MtLkoihOQ=';
  static const String _publicKey = 'public_GuI5dCIV1TjRyPOYtsf1IIqXkxk=';
  static const String _urlEndpoint =
      'https://ik.imagekit.io/projectss/property_images/';
  static const String _uploadUrl =
      'https://upload.imagekit.io/api/v1/files/upload';

  Future<String?> uploadImage(File file) async {
    try {
      final String fileName = file.path.split('/').last;

      final request = http.MultipartRequest('POST', Uri.parse(_uploadUrl));

      // Add authentication
      String basicAuth = 'Basic ${base64Encode(utf8.encode('$_privateKey:'))}';
      request.headers['Authorization'] = basicAuth;

      // Add file
      request.files.add(await http.MultipartFile.fromPath('file', file.path));

      // Add parameters
      request.fields['fileName'] = fileName;
      request.fields['publicKey'] = _publicKey;
      request.fields['folder'] =
          '/property_images/'; // specific folder if needed

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return data['url'] as String;
      } else {
        print('Upload failed: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }
}
