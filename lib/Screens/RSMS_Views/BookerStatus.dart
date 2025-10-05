// import 'dart:async';
// import 'dart:convert';
//
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:intl/intl.dart';
// import 'package:order_booking_app/Services/FirebaseServices/firebase_remote_config.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// import '../../Databases/util.dart';
// import '../../Models/Bookers_RSM_SM_NSM_Models/BookerStatusModel.dart';
// import '../../main.dart';
// import 'booker_details_page.dart';
//
// class BookerStatusPage extends StatefulWidget {
//   final String role; // "BOOKER", "RSM", "SM", "NSM"
//
//   const BookerStatusPage({super.key, required this.role});
//
//   @override
//   _BookerStatusPageState createState() => _BookerStatusPageState();
// }
//
// class _BookerStatusPageState extends State<BookerStatusPage> {
//   List<BookerStatusModel> _allBookers = [];
//   List<BookerStatusModel> _filteredBookers = [];
//   final List<BookerStatusModel> _displayedBookers = [];
//   final TextEditingController _nameController = TextEditingController();
//   final TextEditingController _attendanceController = TextEditingController();
//   final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
//
//   @override
//   void initState() {
//     super.initState();
//     _loadData();
//   }
//
//   Future<void> _loadData() async {
//     bool isConnected = await isNetworkAvailable();
//     if (isConnected) {
//       bool newDataFetched = await _fetchAndSaveData();
//       if (newDataFetched) {
//         await _loadBookersData();
//         _filteredBookers = _allBookers;
//         _addBookersToList(_filteredBookers);
//       } else {
//         await _loadBookersData();
//         _filteredBookers = _allBookers;
//         _addBookersToList(_filteredBookers);
//       }
//     } else {
//       // Load cached data
//       await _loadBookersData();
//       _filteredBookers = _allBookers;
//       _addBookersToList(_filteredBookers);
//
//       // Show last sync time
//       SharedPreferences prefs = await SharedPreferences.getInstance();
//       String? lastSyncTime = prefs.getString('last_sync_time');
//       if (lastSyncTime != null) {
//         DateTime syncDateTime = DateTime.parse(lastSyncTime);
//         String formattedTime = "${syncDateTime.toLocal()}";
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Last sync: $formattedTime')),
//         );
//       }
//     }
//   }
//
//   Future<bool> _fetchAndSaveData() async {
//     await Config.fetchLatestConfig();
//
//     // API URL changes by role
//     String url = "";
//     if (widget.role == "RSM") {
//       url =
//       '${Config.getApiUrlServerIP}${Config.getApiUrlERPCompanyName}${Config.getApiUrlRsmShop}$user_id';
//     } else if (widget.role == "BOOKER") {
//       url =
//       '${Config.getApiUrlServerIP}${Config.getApiUrlERPCompanyName}${Config.getApiUrlRsmBookersStatus}$user_id';
//     } else if (widget.role == "SM") {
//       url =
//       '${Config.getApiUrlServerIP}${Config.getApiUrlERPCompanyName}${Config.getApiUrlSmShop}$user_id';
//     } else if (widget.role == "NSM") {
//       url =
//       '${Config.getApiUrlServerIP}${Config.getApiUrlERPCompanyName}${Config.getApiUrlNsmShop}$user_id';
//     }
//
//     final response = await http.get(Uri.parse(url));
//
//     if (response.statusCode == 200) {
//       final data = json.decode(response.body)['items'];
//       List<BookerStatusModel> fetchedBookers = data
//           .map<BookerStatusModel>((json) => BookerStatusModel.fromJson(json))
//           .toList();
//
//       // Compare with existing data to check if new data is fetched
//       bool isNewData = _hasNewData(fetchedBookers, _allBookers);
//
//       if (isNewData) {
//         _allBookers = fetchedBookers;
//         await _saveBookersData();
//
//         // Save the last sync timestamp
//         SharedPreferences prefs = await SharedPreferences.getInstance();
//         await prefs.setString(
//             'last_sync_time', DateTime.now().toIso8601String());
//       }
//
//       return isNewData;
//     } else {
//       throw Exception('Failed to load data');
//     }
//   }
//
//   bool _hasNewData(
//       List<BookerStatusModel> newData, List<BookerStatusModel> oldData) {
//     if (newData.length != oldData.length) return true;
//     for (int i = 0; i < newData.length; i++) {
//       if (newData[i].toJson() != oldData[i].toJson()) return true;
//     }
//     return false;
//   }
//
//   Future<String?> _getLastSyncTime() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     String? lastSyncTime = prefs.getString('last_sync_time');
//     if (lastSyncTime != null) {
//       DateTime syncDateTime = DateTime.parse(lastSyncTime);
//       return "${syncDateTime.toLocal()}";
//     }
//     return null;
//   }
//
//   Future<void> _saveBookersData() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     String bookersJson =
//     jsonEncode(_allBookers.map((b) => b.toJson()).toList());
//     prefs.setString('bookers_data', bookersJson);
//   }
//
//   Future<void> _loadBookersData() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     String? bookersJson = prefs.getString('bookers_data');
//     if (bookersJson != null) {
//       List<dynamic> jsonList = jsonDecode(bookersJson);
//       _allBookers =
//           jsonList.map((json) => BookerStatusModel.fromJson(json)).toList();
//     }
//   }
//
//   void _addBookersToList(List<BookerStatusModel> bookers) async {
//     for (int i = 0; i < bookers.length; i++) {
//       if (!_displayedBookers.contains(bookers[i])) {
//         _displayedBookers.add(bookers[i]);
//         _listKey.currentState?.insertItem(
//             _displayedBookers.indexOf(bookers[i]),
//             duration: const Duration(seconds: 1));
//         await Future.delayed(const Duration(milliseconds: 300));
//       }
//     }
//   }
//
//   void _removeBookersFromList() async {
//     for (int i = _displayedBookers.length - 1; i >= 0; i--) {
//       final removedBooker = _displayedBookers.removeAt(i);
//       _listKey.currentState?.removeItem(
//         i,
//             (context, animation) => _buildBookerCard(removedBooker, animation),
//         duration: const Duration(milliseconds: 300),
//       );
//       await Future.delayed(const Duration(milliseconds: 100));
//     }
//   }
//
//   void _filterBookers() {
//     final nameFilter = _nameController.text.toLowerCase();
//     final attendanceFilter = _attendanceController.text.toLowerCase();
//     _filteredBookers = _allBookers.where((booker) {
//       final matchesName = booker.name.toLowerCase().contains(nameFilter);
//       final matchesStatus =
//       booker.attendanceStatus.toLowerCase().contains(attendanceFilter);
//       return matchesName && matchesStatus;
//     }).toList();
//     _removeBookersFromList();
//     _addBookersToList(_filteredBookers);
//   }
//
//   void showProfessionalDialog(BuildContext context, String message,
//       IconData icon, Color backgroundColor,
//       {String? actionText, VoidCallback? onActionPressed}) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return Dialog(
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12.0),
//           ),
//           elevation: 8,
//           child: Container(
//             padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [backgroundColor.withOpacity(0.7), backgroundColor],
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//               ),
//               borderRadius: BorderRadius.circular(12.0),
//             ),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 Icon(icon, color: Colors.white, size: 36),
//                 const SizedBox(height: 16),
//                 Text(
//                   message,
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontSize: 18,
//                     fontWeight: FontWeight.w500,
//                   ),
//                   textAlign: TextAlign.center,
//                 ),
//                 if (actionText != null && onActionPressed != null) ...[
//                   const SizedBox(height: 24),
//                   ElevatedButton(
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.white,
//                       foregroundColor: backgroundColor,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       padding: const EdgeInsets.symmetric(
//                           vertical: 12, horizontal: 24),
//                       elevation: 5,
//                     ),
//                     onPressed: onActionPressed,
//                     child: Text(
//                       actionText,
//                       style: const TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                 ],
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
//
//   Future<void> _handleRefresh() async {
//     try {
//       bool isConnected = await isNetworkAvailable();
//
//       if (isConnected) {
//         const timeoutDuration = Duration(seconds: 20);
//         Future<void> loadDataFuture = _loadData();
//
//         await loadDataFuture.timeout(timeoutDuration, onTimeout: () {
//           throw TimeoutException('Data loading took too long');
//         });
//
//         setState(() {
//           _filteredBookers = _allBookers;
//           _removeBookersFromList();
//           _addBookersToList(_filteredBookers);
//         });
//
//         showProfessionalDialog(
//           context,
//           'Data refreshed successfully!',
//           Icons.check_circle_outline,
//           Colors.blue[600]!,
//         );
//       } else {
//         showProfessionalDialog(
//           context,
//           'No internet connection. Please check your connection and try again.',
//           Icons.signal_wifi_off,
//           Colors.red[600]!,
//           actionText: 'Retry',
//           onActionPressed: () {
//             Navigator.of(context).pop();
//             _handleRefresh();
//           },
//         );
//       }
//     } catch (e) {
//       if (e is TimeoutException) {
//         showProfessionalDialog(
//           context,
//           'Data refresh timed out. Please try again later.',
//           Icons.timer_off,
//           Colors.orange[600]!,
//           actionText: 'Retry',
//           onActionPressed: () {
//             Navigator.of(context).pop();
//             _handleRefresh();
//           },
//         );
//       } else {
//         if (kDebugMode) {
//           print('Error during refresh: $e');
//         }
//         showProfessionalDialog(
//           context,
//           'Failed to refresh data. Please try again later.',
//           Icons.error_outline,
//           Colors.orange[600]!,
//           actionText: 'Retry',
//           onActionPressed: () {
//             Navigator.of(context).pop();
//             _handleRefresh();
//           },
//         );
//       }
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('${widget.role} BOOKER STATUS'),
//         backgroundColor: Colors.blue,
//       ),
//       body: RefreshIndicator(
//         onRefresh: _handleRefresh,
//         child: Column(
//           children: [
//             _buildTextField('Search by name', _nameController, false, false),
//             FutureBuilder<String?>(
//               future: _getLastSyncTime(),
//               builder: (context, snapshot) {
//                 if (snapshot.connectionState == ConnectionState.waiting) {
//                   return const CircularProgressIndicator();
//                 } else if (snapshot.hasData && snapshot.data != null) {
//                   DateTime lastSyncDateTime = DateTime.parse(snapshot.data!);
//                   String formattedTime =
//                   DateFormat('dd MMM yyyy, hh:mm a').format(lastSyncDateTime);
//                   return Padding(
//                     padding: const EdgeInsets.symmetric(vertical: 2.0),
//                     child: Row(
//                       children: [
//                         const Icon(Icons.access_time, color: Colors.blue),
//                         const SizedBox(width: 8.0),
//                         Text(
//                           'Last Sync: $formattedTime',
//                           style: const TextStyle(fontSize: 10.0),
//                         ),
//                       ],
//                     ),
//                   );
//                 } else {
//                   return Container();
//                 }
//               },
//             ),
//             Expanded(
//               child: AnimatedList(
//                 key: _listKey,
//                 initialItemCount: _displayedBookers.length,
//                 itemBuilder: (context, index, animation) {
//                   final booker = _displayedBookers[index];
//                   return _buildBookerCard(booker, animation);
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildTextField(String hint, TextEditingController controller,
//       bool isDate, bool isReadOnly) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 6.0),
//       child: Card(
//         elevation: 3.0,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(8.0),
//         ),
//         child: TextField(
//           controller: controller,
//           decoration: InputDecoration(
//             prefixIcon: Icon(
//               isDate ? Icons.calendar_today : Icons.search,
//               color: Colors.blue,
//             ),
//             hintText: hint,
//             hintStyle: TextStyle(color: Colors.grey[600], fontSize: 14),
//             border: InputBorder.none,
//             contentPadding:
//             const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
//           ),
//           keyboardType:
//           isDate ? TextInputType.datetime : TextInputType.text,
//           readOnly: isReadOnly,
//           onChanged: (value) {
//             _filterBookers();
//           },
//         ),
//       ),
//     );
//   }
//
//   Widget _buildBookerCard(BookerStatusModel booker, Animation<double> animation) {
//     final String name = booker.name ?? 'Unknown';
//     final String bookerId = booker.booker_id ?? 'N/A';
//     final String designation = booker.designation ?? 'N/A';
//     final String attendance = booker.attendanceStatus ?? 'unknown';
//
//     Color statusColor;
//     String statusText;
//
//     switch (attendance) {
//       case 'clock_in':
//         statusColor = Colors.green;
//         statusText = 'Clocked In';
//         break;
//       case 'clock_out':
//         statusColor = Colors.red;
//         statusText = 'Clocked Out';
//         break;
//       default:
//         statusColor = Colors.grey;
//         statusText = 'Unknown';
//     }
//
//     return FadeTransition(
//       opacity: animation,
//       child: Card(
//         margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
//         elevation: 2,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(6.0),
//         ),
//         child: Padding(
//           padding: const EdgeInsets.all(10.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Booker Name
//               Text(
//                 name,
//                 style: const TextStyle(
//                     fontSize: 14, fontWeight: FontWeight.bold),
//               ),
//               const SizedBox(height: 4),
//
//               // Booker ID
//               Text(
//                 "ID: $bookerId",
//                 style: const TextStyle(fontSize: 12, color: Colors.black87),
//               ),
//               const SizedBox(height: 4),
//
//               // Designation
//               Text(
//                 "Designation: $designation",
//                 style: const TextStyle(fontSize: 12, color: Colors.blueGrey),
//               ),
//               const SizedBox(height: 6),
//
//               // Attendance Status
//               Container(
//                 padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
//                 decoration: BoxDecoration(
//                   color: statusColor.withOpacity(0.15),
//                   borderRadius: BorderRadius.circular(6),
//                 ),
//                 child: Text(
//                   statusText,
//                   style: TextStyle(
//                     fontSize: 12,
//                     fontWeight: FontWeight.w500,
//                     color: statusColor,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }










import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_client_sse/constants/sse_request_type_enum.dart';
import 'package:flutter_client_sse/flutter_client_sse.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:order_booking_app/Services/FirebaseServices/firebase_remote_config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../Databases/util.dart';
import '../../Models/Bookers_RSM_SM_NSM_Models/BookerStatusModel.dart';
import '../../main.dart';
import 'booker_details_page.dart';

class RSMBookerStatus extends StatefulWidget {
  @override
  _RSMBookerStatusState createState() => _RSMBookerStatusState();
}

class _RSMBookerStatusState extends State<RSMBookerStatus> {
  List<BookerStatusModel> _allBookers = [];
  List<BookerStatusModel> _filteredBookers = [];
  final List<BookerStatusModel> _displayedBookers = [];
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _attendanceController = TextEditingController();
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();




  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    bool isConnected = await isNetworkAvailable();
    if (isConnected) {
      bool newDataFetched = await _fetchAndSaveData();
      if (newDataFetched) {
        await _loadBookersData();
        _filteredBookers = _allBookers;
        _addBookersToList(_filteredBookers);
      } else {
        await _loadBookersData();
        _filteredBookers = _allBookers;
        _addBookersToList(_filteredBookers);
      }
    } else {
      // Load cached data
      await _loadBookersData();
      _filteredBookers = _allBookers;
      _addBookersToList(_filteredBookers);

      // Show last sync time
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? lastSyncTime = prefs.getString('last_sync_time');
      if (lastSyncTime != null) {
        DateTime syncDateTime = DateTime.parse(lastSyncTime);
        String formattedTime = "${syncDateTime.toLocal()}";
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Last sync: $formattedTime')),
        );
      }
    }
  }
  Future<void> _fetchAndSaveDataWithSSE() async {
    final url = 'https://cloud.metaxperts.net:8443/erp/test1/rsmbookerstatus/get/$user_id';

    try {
      // Subscribe to the SSE endpoint
      SSEClient.subscribeToSSE(
        method: SSERequestType.GET, // Use GET method for SSE
        url: url,
        header: {
          'Authorization': 'Bearer your_token', // Add headers if required
        },
      ).listen(
            (event) async {
          // Handle incoming SSE events
          if (event.data != null) {
            // Decode the JSON data from the event
            final Map<String, dynamic> responseData = json.decode(event.data!);
            final List<dynamic> items = responseData['items'];

            // Convert JSON data to a list of BookerStatusModel objects
            List<BookerStatusModel> fetchedBookers = items
                .map<BookerStatusModel>((json) => BookerStatusModel.fromJson(json))
                .toList();

            // Compare with existing data to check if new data is fetched
            bool isNewData = _hasNewData(fetchedBookers, _allBookers);

            if (isNewData) {
              // Update the local data
              _allBookers = fetchedBookers;

              // Save the updated data locally
              await _saveBookersData();

              // Save the last sync timestamp
              SharedPreferences prefs = await SharedPreferences.getInstance();
              await prefs.setString('last_sync_time', DateTime.now().toIso8601String());

              print('New data saved successfully!');
            } else {
              print('No new data found.');
            }
          }
        },
        onError: (error) {
          // Handle SSE connection errors
          print('SSE Error: $error');
        },
        onDone: () {
          // Handle SSE connection closure
          print('SSE connection closed.');
        },
      );
    } catch (e) {
      // Handle any exceptions
      print('Error in SSE connection: $e');
    }
  }
  Future<bool> _fetchAndSaveData() async {
    await Config.fetchLatestConfig();
    final url = '${Config.getApiUrlServerIP}${Config.getApiUrlERPCompanyName}${Config.getApiUrlRsmBookersStatus}$user_id';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {



      final data = json.decode(response.body)['items'];
      List<BookerStatusModel> fetchedBookers = data.map<BookerStatusModel>((json) => BookerStatusModel.fromJson(json)).toList();

      // Compare with existing data to check if new data is fetched
      bool isNewData = _hasNewData(fetchedBookers, _allBookers);

      if (isNewData) {
        _allBookers = fetchedBookers;
        await _saveBookersData();

        // Save the last sync timestamp
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('last_sync_time', DateTime.now().toIso8601String());
      }

      return isNewData;
    } else {
      throw Exception('Failed to load data');
    }
  }

  bool _hasNewData(List<BookerStatusModel> newData, List<BookerStatusModel> oldData) {
    if (newData.length != oldData.length) return true;
    for (int i = 0; i < newData.length; i++) {
      if (newData[i].toJson() != oldData[i].toJson()) return true;
    }
    return false;
  }

  Future<String?> _getLastSyncTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? lastSyncTime = prefs.getString('last_sync_time');
    if (lastSyncTime != null) {
      DateTime syncDateTime = DateTime.parse(lastSyncTime);
      return "${syncDateTime.toLocal()}";
    }
    return null;
  }


  Future<void> _saveBookersData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String bookersJson = jsonEncode(_allBookers.map((b) => b.toJson()).toList());
    prefs.setString('bookers_data', bookersJson);
  }

  Future<void> _loadBookersData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? bookersJson = prefs.getString('bookers_data');
    if (bookersJson != null) {
      List<dynamic> jsonList = jsonDecode(bookersJson);
      _allBookers = jsonList.map((json) => BookerStatusModel.fromJson(json)).toList();
    }
  }



  void _addBookersToList(List<BookerStatusModel> bookers) async {
    for (int i = 0; i < bookers.length; i++) {
      if (!_displayedBookers.contains(bookers[i])) {
        _displayedBookers.add(bookers[i]);
        _listKey.currentState?.insertItem(_displayedBookers.indexOf(bookers[i]), duration: const Duration(seconds: 1));
        await Future.delayed(const Duration(milliseconds: 300));
      }
    }
  }

  void _removeBookersFromList() async {
    for (int i = _displayedBookers.length - 1; i >= 0; i--) {
      final removedBooker = _displayedBookers.removeAt(i);
      _listKey.currentState?.removeItem(
        i,
            (context, animation) => _buildBookerCard(removedBooker, animation),
        duration: const Duration(milliseconds: 300),
      );
      await Future.delayed(const Duration(milliseconds: 100));
    }
  }

  void _filterBookers() {
    final nameFilter = _nameController.text.toLowerCase();
    final attendanceFilter = _attendanceController.text.toLowerCase();
    _filteredBookers = _allBookers.where((booker) {
      final matchesName = booker.name.toLowerCase().contains(nameFilter);
      // final matchesName = booker.booker_id.toLowerCase().contains(nameFilter);
      final matchesStatus = booker.attendanceStatus.toLowerCase().contains(attendanceFilter);
      return matchesName && matchesStatus;
    }).toList();
    _removeBookersFromList();
    _addBookersToList(_filteredBookers);
  }

  void showProfessionalDialog(BuildContext context, String message, IconData icon, Color backgroundColor, {String? actionText, VoidCallback? onActionPressed}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          elevation: 8,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [backgroundColor.withOpacity(0.7), backgroundColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white, size: 36),
                const SizedBox(height: 16),
                Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (actionText != null && onActionPressed != null) ...[
                  const SizedBox(height: 24),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                     foregroundColor: backgroundColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                      elevation: 5,
                    ),
                    onPressed: onActionPressed,
                    child: Text(
                      actionText,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }


  Future<void> _handleRefresh() async {
    try {
      bool isConnected = await isNetworkAvailable();

      if (isConnected) {
        // Set a timeout duration
        const timeoutDuration = Duration(seconds: 20);

        // Create a Future that will complete when data is loaded or timeout occurs
        Future<void> loadDataFuture = _loadData();

        // Run the loadDataFuture with a timeout
        await loadDataFuture.timeout(timeoutDuration, onTimeout: () {
          throw TimeoutException('Data loading took too long');
        });

        // Update the list after data is loaded
        setState(() {
          _filteredBookers = _allBookers;
          _removeBookersFromList();
          _addBookersToList(_filteredBookers);
        });

        // Notify user of successful refresh
        showProfessionalDialog(
          context,
          'Data refreshed successfully!',
          Icons.check_circle_outline,
          Colors.blue[600]!,

        );
      } else {
        // Notify user of connectivity issue
        showProfessionalDialog(
          context,
          'No internet connection. Please check your connection and try again.',
          Icons.signal_wifi_off,
          Colors.red[600]!,
          actionText: 'Retry',
          onActionPressed: () {
            Navigator.of(context).pop(); // Close the dialog
            _handleRefresh(); // Retry refreshing data
          },
        );
      }

    }
    catch (e) {
      // Handle timeout and other errors
      if (e is TimeoutException) {
        showProfessionalDialog(
          context,
          'Data refresh timed out. Please try again later.',
          Icons.timer_off,
          Colors.orange[600]!,
          actionText: 'Retry',
          onActionPressed: () {
            Navigator.of(context).pop(); // Close the dialog
            _handleRefresh(); // Retry refreshing data
          },
        );
      } else {
        // Handle any other errors
        if (kDebugMode) {
          print('Error during refresh: $e');
        }
        showProfessionalDialog(
          context,
          'Failed to refresh data. Please try again later.',
          Icons.error_outline,
          Colors.orange[600]!,
          actionText: 'Retry',
          onActionPressed: () {
            Navigator.of(context).pop(); // Close the dialog
            _handleRefresh(); // Retry refreshing data
          },
        );
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('BOOKER STATUS DETAIL'),
          backgroundColor: Colors.blue,
        ),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,

        child:  Column(
          children: [
            Column(
              children: [
                _buildTextField('Search by name', _nameController, false, false),
              ],
            ),

            FutureBuilder<String?>(
              future: _getLastSyncTime(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasData && snapshot.data != null) {
                  DateTime lastSyncDateTime = DateTime.parse(snapshot.data!);
                  String formattedTime = DateFormat('dd MMM yyyy, hh:mm a').format(lastSyncDateTime);
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2.0),
                    child: Row(
                      children: [
                        const Icon(Icons.access_time, color: Colors.blue),
                        const SizedBox(width: 8.0),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Last Sync: ',
                              style: TextStyle(fontSize: 10.0),
                            ),
                            const SizedBox(height: 4.0), // Add gap between Last Sync and the date
                            Text(
                              formattedTime,
                              style: const TextStyle( fontSize: 10.0),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                } else {
                  return Container(); // No data to display
                }
              },
            ),

            Expanded(
              child: AnimatedList(
                key: _listKey,
                initialItemCount: _displayedBookers.length,
                itemBuilder: (context, index, animation) {
                  final booker = _displayedBookers[index];
                  return _buildBookerCard(booker, animation);
                },
              ),
            ),
          ],
        ),
      ),
      );
  }

  Widget _buildTextField(String hint, TextEditingController controller, bool isDate, bool isReadOnly) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Card(
        elevation: 3.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: TextField(
          controller: controller,
          decoration: InputDecoration(
            prefixIcon: Icon(
              isDate ? Icons.calendar_today : Icons.search,
              color: Colors.blue,
            ),
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[600], fontSize: 14),
            border: InputBorder.none,
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.blue, width: 1.0),
              borderRadius: BorderRadius.circular(8.0),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey[300]!, width: 1.0),
              borderRadius: BorderRadius.circular(8.0),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
          ),
          keyboardType: isDate ? TextInputType.datetime : TextInputType.text,
          readOnly: isReadOnly,
          onChanged: (value) {
            _filterBookers();
          },
        ),
      ),
    );
  }

  Widget _buildBookerCard(BookerStatusModel booker, Animation<double> animation) {
    Color statusColor;
    String statusText;

    // Determine the color and text based on the attendance status
    switch (booker.attendanceStatus) {
      case 'clock_in':
        statusColor = Colors.blue;
        statusText = 'Clocked In';
        break;
      case 'clock_out':
        statusColor = Colors.red;
        statusText = 'Clocked Out';
        break;
      default:
        statusColor = Colors.grey;
        statusText = 'Unknown';
    }

    return FadeTransition(
      opacity: animation,
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RSMBookerDetailsPage(booker: booker),
            ),
          );
        },
        child: Card(
          margin: const EdgeInsets.all(1.0),
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(2.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(5.0),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(2.0),
                  child: SizedBox(
                    width: 45,
                    height: 45,
                    child: Image.asset(
                      'assets/icons/avatar3.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 7.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booker.name,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4.0),
                      Text(
                        'ID: ${booker.booker_id}',
                        style: const TextStyle(fontSize: 11, color: Colors.black),
                      ),
                      const SizedBox(height: 1.0),
                      Row(
                        children: [
                          const Icon(Icons.work, size: 11.0, color: Colors.blue),
                          const SizedBox(width: 4.0),
                          Expanded(
                            child: Text(
                              ' ${booker.designation}',
                              style: const TextStyle(fontSize: 11),
                            ),
                          ),
                        ],
                      ),
                      if (booker.designation == 'SO') ...[
                        const SizedBox(height: 4.0),
                        Row(
                          children: [
                            const Icon(Icons.location_city, size: 11.0, color: Colors.blue),
                            const SizedBox(width: 4.0),
                            Expanded(
                              child: Text(
                                'City: ${booker.city}',
                                style: const TextStyle(fontSize: 11),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 4.0),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            booker.attendanceStatus == 'clock_in' ? Icons.check : Icons.close,
                            size: 11.0,
                            color: statusColor,
                          ),
                          const SizedBox(width: 2.0),
                          Text(
                            statusText,
                            style: TextStyle(fontSize: 12, color: statusColor),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

