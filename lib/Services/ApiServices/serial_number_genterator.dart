import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class SerialNumberGenerator {
  final String apiUrl; // API endpoint to fetch the latest ID
  final String maxColumnName; // Column name in the API response (e.g., "max(shop_visit_master_id)")
  int? serialType; // Type of serial (e.g., "shop_visit", "order_master", "order_details")

  SerialNumberGenerator({
    required this.apiUrl,
    required this.maxColumnName,
    required this.serialType,
  });

  // Function to fetch the latest ID from the server
  Future<String?> fetchLatestIdFromServer() async {
    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final items = data['items'] as List<dynamic>?;

        if (items != null && items.isNotEmpty) {
          final latestId = items[0][maxColumnName] as String?;
          if (latestId != null) {
            return latestId;
          } else {
            debugPrint('No $maxColumnName found in the response. Starting from 1.');
            return null; // Return null if maxColumnName is not found
          }
        } else {
          debugPrint('No items found in the response. Starting from 1.');
          return null; // Return null if no items are found
        }
      } else {
        throw Exception('Failed to fetch latest ID: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching latest ID: $e');
      throw Exception('Failed to fetch latest ID: $e');
    }
  }

  // Function to extract and increment the serial number
  Future<void> getAndIncrementSerialNumber() async {
    try {
      // Fetch the latest ID from the server
      final latestId = await fetchLatestIdFromServer();

      if (latestId != null) {
        // Extract the serial number from the ID
        final parts = latestId.split('-');
        if (parts.length > 2) {
          final serialNoPart = parts.last;
          final serialNumber = int.tryParse(serialNoPart);

          if (serialNumber != null) {
            // Increment the serial number
            serialType = serialNumber + 1;
            debugPrint('Latest serial number incremented to: $serialType');
          } else {
            throw Exception('Failed to parse serial number from ID');
          }
        } else {
          throw Exception('Invalid ID format');
        }
      } else {
        // If no latest ID is found, start from 1
        serialType = 1;
        debugPrint('No previous records found. Starting serial number from 1.');
      }
    } catch (e) {
      debugPrint('Error in getAndIncrementSerialNumber: $e');
      throw Exception('Failed to increment serial number: $e');
    }
  }
}