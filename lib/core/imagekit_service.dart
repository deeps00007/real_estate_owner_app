import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ImageKitService {
  // Credentials from your snippet
  final String publicKey = 'public_GuI5dCIV1TjRyPOYtsf1IIqXkxk=';
  final String privateKey = 'private_DAREKSumKgYgTAXq68MtLkoihOQ=';
  final String urlEndpoint = 'https://ik.imagekit.io/projectss';

  Future<String> uploadImage(File file) async {
    final uri = Uri.parse('https://upload.imagekit.io/api/v1/files/upload');

    // 1. Create Multipart Request
    final request = http.MultipartRequest('POST', uri);

    // 2. Authorization Header (Basic Auth with Private Key)
    // Note: The colon ':' at the end is required for ImageKit Basic Auth
    String basicAuth = 'Basic ${base64Encode(utf8.encode('$privateKey:'))}';
    request.headers['Authorization'] = basicAuth;

    // 3. Add File
    final multipartFile = await http.MultipartFile.fromPath('file', file.path);
    request.files.add(multipartFile);

    // 4. Add Parameters (Folder & File Name)
    request.fields['fileName'] =
        'prop_${DateTime.now().millisecondsSinceEpoch}.jpg';
    request.fields['useUniqueFileName'] = 'true';
    request.fields['folder'] = '/property_images/'; // New folder name

    try {
      // 5. Send Request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = jsonDecode(response.body);
        if (kDebugMode) {
          print('Upload Success: ${jsonResponse['url']}');
        }
        return jsonResponse['url'];
      } else {
        if (kDebugMode) {
          print('Upload Failed: ${response.body}');
        }
        throw Exception('ImageKit Upload Failed: ${response.body}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Network Error: $e');
      }
      throw Exception('Network Error: $e');
    }
  }
}
