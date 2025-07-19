// import 'dart:async';
//
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:order_booking_app/Databases/util.dart';
// import 'package:order_booking_app/Screens/PermissionScreens/camera_screen.dart';
// import 'package:order_booking_app/Screens/login_screen.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
//
// import '../Services/FirebaseServices/firebase_remote_config.dart';
// import '../ViewModels/login_view_model.dart';
//
// class CodeScreen extends StatefulWidget {
//   const CodeScreen({super.key});
//
//   @override
//   State<CodeScreen> createState() => _CodeScreenState();
// }
//
// class _CodeScreenState extends State<CodeScreen> {
//   late final TextEditingController companyCodeController;
//   final _formKey = GlobalKey<FormState>();
//  final LoginViewModel loginViewModel = Get.put(LoginViewModel());
//  bool isLoading = false;
//   bool isButtonDisabled = false;
//
//   @override
//   void initState() {
//     super.initState();
//     companyCodeController = TextEditingController();
//   }
//
//   @override
//   void dispose() {
//     companyCodeController.dispose();
//     super.dispose();
//   }
//
//   void _showCenteredSnackBar(String message, {bool isError = false}) {
//     final snackBar = SnackBar(
//       content: Center(
//         child: Text(
//           message,
//           style: const TextStyle(fontSize: 16),
//         ),
//       ),
//       backgroundColor: isError ? Colors.red : Colors.green,
//       behavior: SnackBarBehavior.floating,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(10),
//       ),
//       margin: EdgeInsets.only(
//         bottom: MediaQuery.of(context).size.height * 0.4,
//         left: 20,
//         right: 20,
//       ),
//     );
//
//     ScaffoldMessenger.of(context).showSnackBar(snackBar);
//   }
//
// // Modified version with better error handling and navigation
//   Future<void> _saveCompanyDetails(String companyCode) async {
//     // Show initial loading message
//     _showCenteredSnackBar('Please wait...');
//     setState(() {
//       isLoading = true;
//       isButtonDisabled = true;
//     });
//     try {
//       // Step 1: Get SharedPreferences
//       final prefs = await SharedPreferences.getInstance();
//       await prefs.reload();
//       final isAuthenticated = prefs.getBool('isAuthenticated') ?? false;
// await Config.fetchLatestConfig();
//       // Step 2: Fetch company data
//       final response = await http.get(
//
//         Uri.parse(Config.getApiUrlCompaniesCodes),
//         // Uri.parse('https://cloud.metaxperts.net:8443/erp/beauty_pro_solutions/registeredcompanies/get/'),
//       ).timeout(const Duration(seconds: 30));
//
//       if (response.statusCode != 200) {
//         _showCenteredSnackBar('Failed to fetch company details', isError: true);
//         setState(() {
//           isLoading = false;
//           isButtonDisabled = false;
//         });
//         return;
//       }
//
//       final data = json.decode(response.body);
//       final items = data['items'] as List;
//       final company = items.firstWhere(
//             (item) => item['company_code'] == companyCode,
//         orElse: () => null,
//       );
//
//       if (company == null) {
//         _showCenteredSnackBar('Company code not found', isError: true);
//         setState(() {
//           isLoading = false;
//           isButtonDisabled = false;
//         });
//         return;
//       }
//
//       // Step 3: Save company details
//       setState(() {
//         isLoading = true;
//         isButtonDisabled = true;
//       });
//       await prefs.setString('company_name', company['company_name']);
//       await prefs.setString('workspace_name', company['workspace_name']);
//       await prefs.setString('company_code', companyCode);
//       erpWorkSpace =  await prefs.getString('workspace_name') ?? '';
//
//       // Step 4: Handle authentication if needed
//       if (!isAuthenticated) {
//         try {
//           _showCenteredSnackBar('Setting up your account...');
//           await Config.fetchLatestConfig();
//           await Config.getApiUrlERPCompanyName;
//           companyName = await prefs.getString('company_name') ?? '';
//           debugPrint("Company Name: ${Config.getApiUrlERPCompanyName}");
//           await loginViewModel.checkInternetBeforeNavigation();
//         } catch (e) {
//           debugPrint("Authentication error: $e");
//           _showCenteredSnackBar('Setup failed: ${e.toString()}', isError: true);
//           setState(() {
//             isLoading = false;
//             isButtonDisabled = false;
//           });
//           return;
//         }
//       }
//
//       // Step 5: Final navigation
//       _showCenteredSnackBar('Setup complete!');
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         Get.offAll(() => const CameraScreen());
//       });
//     } on TimeoutException {
//       _showCenteredSnackBar('Request timed out. Please try again', isError: true);
//       setState(() {
//         isLoading = false;
//         isButtonDisabled = false;
//       });
//     } catch (e) {
//       debugPrint('Error in _saveCompanyDetails: $e');
//       _showCenteredSnackBar('Setup failed: ${e.toString()}', isError: true);
//       setState(() {
//         isLoading = false;
//         isButtonDisabled = false;
//       });
//     }
//   }
//   @override
//   Widget build(BuildContext context) {
//     final screenHeight = MediaQuery.of(context).size.height;
//     final screenWidth = MediaQuery.of(context).size.width;
//
//     return Scaffold(
//       backgroundColor: Colors.white,
//       resizeToAvoidBottomInset: true,
//       body: GestureDetector(
//         onTap: () => FocusScope.of(context).unfocus(),
//         child: SafeArea(
//           child: Column(
//             children: [
//               // Top blue background with content
//               Container(
//                 height: screenHeight * 0.35,
//                 width: double.infinity,
//                 decoration: const BoxDecoration(
//                   color: Colors.blueAccent,
//                   borderRadius: BorderRadius.only(
//                     bottomLeft: Radius.circular(30),
//                     bottomRight: Radius.circular(30),
//                   ),
//                 ),
//                 child: const Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Text(
//                       'Welcome to',
//                       style: TextStyle(
//                         fontSize: 26,
//                         color: Colors.white70,
//                         fontWeight: FontWeight.w400,
//                       ),
//                     ),
//                     SizedBox(height: 8),
//                     Text(
//                       'BookIT!',
//                       style: TextStyle(
//                         fontSize: 36,
//                         color: Colors.white,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//
//               // Main content area
//               Expanded(
//                 child: Padding(
//                   padding: EdgeInsets.symmetric(
//                     horizontal: screenWidth * 0.06,
//                     vertical: 30,
//                   ),
//                   child: Form(
//                     key: _formKey,
//                     child: LayoutBuilder(
//                       builder: (context, constraints) {
//                         return SingleChildScrollView(
//                           physics: const ClampingScrollPhysics(),
//                           child: ConstrainedBox(
//                             constraints: BoxConstraints(
//                               minHeight: constraints.maxHeight,
//                             ),
//                             child: IntrinsicHeight(
//                               child: Column(
//                                 mainAxisSize: MainAxisSize.min,
//                                 children: [
//                                   const Text(
//                                     'Please enter the company code to continue.\n',
//                                         // 'This helps us connect you with your team and access your workspace.',
//                                     style: TextStyle(
//                                       fontSize: 17,
//                                       color: Colors.black87,
//                                       height: 1.5,
//                                     ),
//                                     textAlign: TextAlign.center,
//                                   ),
//
//                                   Flexible(
//                                     child: SizedBox(height: screenHeight * 0.02),
//                                   ),
//
//                                   const Align(
//                                     alignment: Alignment.centerLeft,
//                                     child: Text(
//                                       'Company Code',
//                                       style: TextStyle(
//                                         fontSize: 16,
//                                         fontWeight: FontWeight.w500,
//                                         color: Colors.black87,
//                                       ),
//                                     ),
//                                   ),
//                                   const SizedBox(height: 10),
//                                   TextFormField(
//                                     controller: companyCodeController,
//                                     decoration: InputDecoration(
//                                       hintText: 'Enter your company code',
//                                       filled: true,
//                                       fillColor: Colors.grey[100],
//                                       contentPadding: const EdgeInsets.symmetric(
//                                         vertical: 16,
//                                         horizontal: 16,
//                                       ),
//                                       border: OutlineInputBorder(
//                                         borderRadius: BorderRadius.circular(12),
//                                         borderSide: BorderSide.none,
//                                       ),
//                                     ),
//                                     validator: (value) {
//                                       if (value == null || value.isEmpty) {
//                                         return 'Please enter company code';
//                                       }
//                                       return null;
//                                     },
//                                   ),
//                                   const SizedBox(height: 55),
//                                   SizedBox(
//                                     width: double.infinity,
//                                     child: ElevatedButton.icon(
//                                       onPressed: isButtonDisabled ? null : () {
//                                         if (_formKey.currentState!.validate()) {
//                                           _saveCompanyDetails(companyCodeController.text.trim());
//                                         }
//                                       },
//                                     //  icon: const Icon(Icons.arrow_forward_ios_rounded),
//                                       label: Text(
//                                         isLoading?'Please wait...':'Continue',
//                                         style: TextStyle(fontSize: 16),
//                                       ),
//                                       style: ElevatedButton.styleFrom(
//                                         backgroundColor: Colors.blueAccent,
//                                         foregroundColor: Colors.white,
//                                         padding: const EdgeInsets.symmetric(vertical: 16),
//                                         shape: RoundedRectangleBorder(
//                                           borderRadius: BorderRadius.circular(12),
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                   SizedBox(
//                                     height: MediaQuery.of(context).viewInsets.bottom > 0
//                                         ? 20
//                                         : screenHeight * 0.05,
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ),
//                         );
//                       },
//                     ),
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
import 'dart:convert';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:order_booking_app/Databases/util.dart';
import 'package:order_booking_app/Screens/PermissionScreens/camera_screen.dart';
import 'package:order_booking_app/ViewModels/login_view_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Services/FirebaseServices/firebase_remote_config.dart';

class CodeScreen extends StatefulWidget {
  const CodeScreen({super.key});

  @override
  State<CodeScreen> createState() => _CodeScreenState();
}

class _CodeScreenState extends State<CodeScreen> {
  late final TextEditingController companyCodeController;
  final _formKey = GlobalKey<FormState>();
  final LoginViewModel loginViewModel = Get.put(LoginViewModel());
  bool isLoading = false;
  bool isButtonDisabled = false;

  @override
  void initState() {
    super.initState();
    companyCodeController = TextEditingController();
  }

  @override
  void dispose() {
    companyCodeController.dispose();
    super.dispose();
  }

  void _showCenteredSnackBar(String message, {bool isError = false}) {
    final snackBar = SnackBar(
      content: Center(
        child: Text(
          message,
          style: const TextStyle(fontSize: 16),
        ),
      ),
      backgroundColor: isError ? Colors.red : Colors.green,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      margin: EdgeInsets.only(
        bottom: MediaQuery.of(context).size.height * 0.4,
        left: 20,
        right: 20,
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Future<bool> _hasInternet() async {
    var result = await Connectivity().checkConnectivity();
    return result != ConnectivityResult.none;
  }

  Future<void> _saveCompanyDetails(String companyCode) async {
    _showCenteredSnackBar('Please wait...');
    setState(() {
      isLoading = true;
      isButtonDisabled = true;
    });

    if (!await _hasInternet()) {
      _showCenteredSnackBar('No internet connection. Please connect to the internet.', isError: true);
      setState(() {
        isLoading = false;
        isButtonDisabled = false;
      });
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.reload();
      final isAuthenticated = prefs.getBool('isAuthenticated') ?? false;

      await Config.fetchLatestConfig();

      final response = await http.get(
        Uri.parse(Config.getApiUrlCompaniesCodes),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode != 200) {
        _showCenteredSnackBar('Failed to fetch company details', isError: true);
        setState(() {
          isLoading = false;
          isButtonDisabled = false;
        });
        return;
      }

      final data = json.decode(response.body);
      final items = data['items'] as List;
      final company = items.firstWhere(
            (item) => item['company_code'] == companyCode,
        orElse: () => null,
      );

      if (company == null) {
        _showCenteredSnackBar('Company code not found', isError: true);
        setState(() {
          isLoading = false;
          isButtonDisabled = false;
        });
        return;
      }

      await prefs.setString('company_name', company['company_name']);
      await prefs.setString('workspace_name', company['workspace_name']);
      await prefs.setString('company_code', companyCode);
      erpWorkSpace = await prefs.getString('workspace_name') ?? '';

      if (!isAuthenticated) {
        try {
          _showCenteredSnackBar('Setting up your account...');
          await Config.fetchLatestConfig();
          await Config.getApiUrlERPCompanyName;
          companyName = await prefs.getString('company_name') ?? '';
          debugPrint("Company Name: ${Config.getApiUrlERPCompanyName}");
          await loginViewModel.checkInternetBeforeNavigation();
        } catch (e) {
          debugPrint("Authentication error: $e");
          _showCenteredSnackBar('Setup failed: ${e.toString()}', isError: true);
          setState(() {
            isLoading = false;
            isButtonDisabled = false;
          });
          return;
        }
      }

      _showCenteredSnackBar('Setup complete!');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.offAll(() => const CameraScreen());
      });
    } on SocketException {
      _showCenteredSnackBar('No internet. Please connect and try again.', isError: true);
    } on TimeoutException {
      _showCenteredSnackBar('Request timed out. Please try again.', isError: true);
    } on http.ClientException {
      _showCenteredSnackBar('Connection failed. Check your internet and try again.', isError: true);
    } catch (e) {
      debugPrint('Error in _saveCompanyDetails: $e');
      _showCenteredSnackBar('Something went wrong. Please try again later.', isError: true);
    } finally {
      setState(() {
        isLoading = false;
        isButtonDisabled = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: Column(
            children: [
              Container(
                height: screenHeight * 0.35,
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.blueAccent,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Welcome to',
                      style: TextStyle(
                        fontSize: 26,
                        color: Colors.white70,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'BookIT!',
                      style: TextStyle(
                        fontSize: 36,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.06,
                    vertical: 30,
                  ),
                  child: Form(
                    key: _formKey,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return SingleChildScrollView(
                          physics: const ClampingScrollPhysics(),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minHeight: constraints.maxHeight,
                            ),
                            child: IntrinsicHeight(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text(
                                    'Please enter the company code to continue.\n',
                                    style: TextStyle(
                                      fontSize: 17,
                                      color: Colors.black87,
                                      height: 1.5,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 20),
                                  const Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      'Company Code',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  TextFormField(
                                    controller: companyCodeController,
                                    decoration: InputDecoration(
                                      hintText: 'Enter your company code',
                                      filled: true,
                                      fillColor: Colors.grey[100],
                                      contentPadding: const EdgeInsets.symmetric(
                                        vertical: 16,
                                        horizontal: 16,
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide.none,
                                      ),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter company code';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 55),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: isButtonDisabled
                                          ? null
                                          : () {
                                        if (_formKey.currentState!.validate()) {
                                          _saveCompanyDetails(companyCodeController.text.trim());
                                        }
                                      },
                                      child: Text(
                                        isLoading ? 'Please wait...' : 'Continue',
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.blueAccent,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(vertical: 16),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: MediaQuery.of(context).viewInsets.bottom > 0
                                        ? 20
                                        : screenHeight * 0.05,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
