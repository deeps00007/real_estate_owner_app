import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ImageKitService {
  // 🔴 REPLACE THESE WITH YOUR KEYS FROM THE SCREENSHOT
  final String publicKey = 'public_GuI5dCIV1TjRyPOY'; // From your screenshot
  final String privateKey = 'private_DAREKSumKgYgTAX'; // From your screenshot
  final String urlEndpoint = 'https://ik.imagekit.io/YOUR_ID'; // Find this in your ImageKit dashboard (e.g., /ik-user-id/)

  Future<String> uploadImage(File file) async {
    // ImageKit Upload API
    final uri = Uri.parse('https://upload.imagekit.io/api/v1/files/upload');
    
    // Create multipart request
    final request = http.MultipartRequest('POST', uri);
    
    // Auth: Private key in base64 as Basic Auth
    String basicAuth = 'Basic ' + base64Encode(utf8.encode('$privateKey:'));
    request.headers['Authorization'] = basicAuth;

    // Add File
    final multipartFile = await http.MultipartFile.fromPath('file', file.path);
    request.files.add(multipartFile);

    // Add Parameters
    request.fields['fileName'] = 'property_${DateTime.now().millisecondsSinceEpoch}.jpg';
    request.fields['useUniqueFileName'] = 'true';
    request.fields['folder'] = '/real_estate_properties/'; // Optional folder

    // Send
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      // Return the usable URL
      return jsonResponse['url']; 
    } else {
      throw Exception('ImageKit Upload Failed: ${response.body}');
    }
  }
}
