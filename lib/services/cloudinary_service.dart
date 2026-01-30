import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:crypto/crypto.dart';

class CloudinaryService {
  static final String cloudName = dotenv.env['CLOUDINARY_CLOUD_NAME'] ?? '';
  static final String apiKey = dotenv.env['CLOUDINARY_API_KEY'] ?? '';
  static final String apiSecret = dotenv.env['CLOUDINARY_API_SECRET'] ?? '';

  // Upload resume PDF to Cloudinary with PUBLIC access
  Future<String?> uploadResume(File file, String userId) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final publicId = 'resumes/resume_$userId';
      
      // Generate signature for authenticated upload
      final signature = _generateUploadSignature(publicId, timestamp);
      
      // Use the /raw/upload endpoint for PDFs
      final url = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/raw/upload');
      
      final request = http.MultipartRequest('POST', url);
      
      // Add file
      request.files.add(await http.MultipartFile.fromPath('file', file.path));
      
      // Add CRITICAL parameters for public access
      request.fields['public_id'] = publicId;
      request.fields['timestamp'] = timestamp;
      request.fields['api_key'] = apiKey;
      request.fields['signature'] = signature;
      request.fields['resource_type'] = 'raw';
      request.fields['type'] = 'upload';
      request.fields['access_mode'] = 'public'; // CRITICAL for public access
      request.fields['invalidate'] = 'true'; // Clear CDN cache
      
      print('📤 Uploading to Cloudinary...');
      print('Public ID: $publicId');
      
      // Send request
      final response = await request.send();
      
      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        final jsonData = json.decode(responseData);
        
        String secureUrl = jsonData['secure_url'] as String;
        
        // IMPORTANT: Ensure URL uses /raw/upload/ path for direct access
        print('✅ Upload successful: $secureUrl');
        print('Access mode: ${jsonData['access_mode']}');
        print('Resource type: ${jsonData['resource_type']}');
        
        return secureUrl;
      } else {
        final responseData = await response.stream.bytesToString();
        print('❌ Cloudinary upload failed: ${response.statusCode}');
        print('Response: $responseData');
        return null;
      }
    } catch (e) {
      print('❌ Error uploading to Cloudinary: $e');
      return null;
    }
  }

  // Generate signature for upload
  String _generateUploadSignature(String publicId, String timestamp) {
    // Build params string in alphabetical order (Cloudinary requirement)
    final params = 'access_mode=public&invalidate=true&public_id=$publicId&timestamp=$timestamp&type=upload$apiSecret';
    return sha1.convert(utf8.encode(params)).toString();
  }

  // Delete resume from Cloudinary
  Future<bool> deleteResume(String publicId) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final signature = _generateDeleteSignature(publicId, timestamp);
      
      final url = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/raw/destroy');
      
      final response = await http.post(
        url,
        body: {
          'public_id': publicId,
          'signature': signature,
          'api_key': apiKey,
          'timestamp': timestamp,
          'type': 'upload',
          'invalidate': 'true',
        },
      );
      
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        print('🗑️ Delete result: ${jsonData['result']}');
        return jsonData['result'] == 'ok';
      }
      return false;
    } catch (e) {
      print('❌ Error deleting from Cloudinary: $e');
      return false;
    }
  }

  // Generate signature for delete
  String _generateDeleteSignature(String publicId, String timestamp) {
    final params = 'invalidate=true&public_id=$publicId&timestamp=$timestamp&type=upload$apiSecret';
    return sha1.convert(utf8.encode(params)).toString();
  }

  // Get public ID from URL
  String getPublicIdFromUrl(String url) {
    try {
      final uri = Uri.parse(url);
      final pathSegments = uri.pathSegments;
      
      // Find 'raw/upload' and extract public_id
      final uploadIndex = pathSegments.indexOf('upload');
      if (uploadIndex != -1 && uploadIndex < pathSegments.length - 1) {
        // Get everything after 'upload/' and remove file extension
        final remainingPath = pathSegments.sublist(uploadIndex + 1);
        final fullPath = remainingPath.join('/');
        
        // Remove file extension
        final lastDotIndex = fullPath.lastIndexOf('.');
        if (lastDotIndex != -1) {
          return fullPath.substring(0, lastDotIndex);
        }
        return fullPath;
      }
      
      return '';
    } catch (e) {
      print('❌ Error parsing public ID: $e');
      return '';
    }
  }
  
  // Get direct download URL (force download instead of inline view)
  String getDownloadUrl(String secureUrl) {
    try {
      final uri = Uri.parse(secureUrl);
      
      // Add fl_attachment flag to force download
      final pathParts = uri.path.split('/upload/');
      if (pathParts.length == 2) {
        final newPath = '${pathParts[0]}/upload/fl_attachment/${pathParts[1]}';
        return uri.replace(path: newPath).toString();
      }
      
      return secureUrl;
    } catch (e) {
      print('❌ Error generating download URL: $e');
      return secureUrl;
    }
  }
}