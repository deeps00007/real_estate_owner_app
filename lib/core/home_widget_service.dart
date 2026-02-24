import 'dart:io';
import 'package:home_widget/home_widget.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import '../../models/property.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';

class HomeWidgetService {
  static const String appGroupId =
      'com.realestate.owner.app.v1'; // Replace with a group ID if iOS support is added later
  static const String androidWidgetName = 'PropertyWidgetProvider';

  static Future<void> initialize() async {
    // Required to set the App Group ID for iOS, but we'll set it anyway for consistency
    await HomeWidget.setAppGroupId(appGroupId);
  }

  static Future<void> updateWidgetWithProperties(
    List<Property> properties,
  ) async {
    try {
      // Limit to top 5 properties to avoid IPC size limits and excessive downloading
      final displayProps = properties.take(5).toList();
      List<Map<String, dynamic>> jsonList = [];

      for (var property in displayProps) {
        String? localImagePath;
        // Download and Save Image for Native Access
        if (property.imageUrl.isNotEmpty) {
          localImagePath = await _downloadImage(property.imageUrl, property.id);
        }

        jsonList.add({
          'id': property.id,
          'title': property.title,
          'location': property.address ?? 'Premium Listing',
          'price': property.formattedPrice,
          'rating': '4.9', // Hardcoded rating for MVP
          'imagePath': localImagePath ?? '',
        });
      }

      // Encode the list to a single JSON string
      final String jsonString = jsonEncode(jsonList);

      // Save the massive JSON string to SharedPreferences
      await HomeWidget.saveWidgetData<String>('properties_list', jsonString);

      // Trigger Android Widget Update
      await HomeWidget.updateWidget(name: androidWidgetName);

      debugPrint('Widget updated with ${displayProps.length} properties');
    } catch (e) {
      debugPrint('Failed to update home widget: $e');
    }
  }

  // Native Android widgets (AppWidgets) cannot directly load URLs easily without
  // adding Glide to the native Android build. To keep the MVP simple, we download
  // the image in Flutter and pass the local path to the native side.
  static Future<String?> _downloadImage(String url, String propertyId) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final documentDirectory = await getApplicationDocumentsDirectory();
        final file = File(
          '${documentDirectory.path}/widget_img_$propertyId.png',
        );
        await file.writeAsBytes(response.bodyBytes);
        return file.path;
      }
    } catch (e) {
      debugPrint('Failed to download image for widget: $e');
    }
    return null;
  }
}
