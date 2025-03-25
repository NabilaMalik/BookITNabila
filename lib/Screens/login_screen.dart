import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:order_booking_app/ViewModels/ProductsViewModel.dart';
import 'package:order_booking_app/ViewModels/add_shop_view_model.dart';
import 'package:order_booking_app/ViewModels/attendance_out_view_model.dart';
import 'package:order_booking_app/ViewModels/attendance_view_model.dart';
import 'package:order_booking_app/ViewModels/location_view_model.dart';
import 'package:order_booking_app/ViewModels/login_view_model.dart';
import 'package:order_booking_app/ViewModels/order_details_view_model.dart';
import 'package:order_booking_app/ViewModels/order_master_view_model.dart';
import 'package:order_booking_app/ViewModels/recovery_form_view_model.dart';
import 'package:order_booking_app/ViewModels/shop_visit_details_view_model.dart';
import 'package:order_booking_app/ViewModels/shop_visit_view_model.dart';
import 'package:order_booking_app/ViewModels/update_function_view_model.dart';
import 'package:order_booking_app/screens/Components/custom_button.dart';
import 'package:order_booking_app/screens/signup_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Databases/util.dart';
import '../Models/returnform_details_model.dart';
import '../ViewModels/return_form_details_view_model.dart';
import '../ViewModels/return_form_view_model.dart';
import '../components/under_part.dart';
import '../constants.dart';
import '../widgets/rounded_button.dart';
import '../widgets/rounded_icon.dart';
import 'components/custom_editable_menu_option.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}
class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  late final addShopViewModel = Get.put(AddShopViewModel());
  late final productsViewModel = Get.put(ProductsViewModel());
  late final shopVisitViewModel = Get.put(ShopVisitViewModel());
  late final shopVisitDetailsViewModel = Get.put(ShopVisitDetailsViewModel());
  late final orderMasterViewModel = Get.put(OrderMasterViewModel());
  late final orderDetailsViewModel = Get.put(OrderDetailsViewModel());
  late final recoveryFormViewModel = Get.put(RecoveryFormViewModel());
  late final returnFormViewModel = Get.put(ReturnFormViewModel());
  late final ReturnFormDetailsViewModel returnFormDetailsViewModel = Get.put(ReturnFormDetailsViewModel());

  late final attendanceViewModel = Get.put(AttendanceViewModel());
  late final attendanceOutViewModel = Get.put(AttendanceOutViewModel());
  final LocationViewModel locationViewModel = Get.put(LocationViewModel());
  late final updateFunctionViewModel = Get.put(UpdateFunctionViewModel());
  final LoginViewModel loginViewModel = Get.put(LoginViewModel());

  final _formKey = GlobalKey<FormState>();
  bool isChecked = true;
  bool isLoading = false;
  bool isPasswordVisible = false;
  bool isButtonDisabled = false;

  // Add a ValueNotifier to track progress
  final ValueNotifier<double> _progressNotifier = ValueNotifier<double>(0.0);

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
      isButtonDisabled = true;
      _progressNotifier.value = 0.0; // Reset progress
    });

    final prefs = await SharedPreferences.getInstance();
    final connectivityResult = await Connectivity().checkConnectivity();

    if (connectivityResult == ConnectivityResult.none) {
      Get.snackbar('Error', 'No internet connection', snackPosition: SnackPosition.BOTTOM);
      setState(() {
        isLoading = false;
        isButtonDisabled = false;
      });
      return;
    }

    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isEmpty || result[0].rawAddress.isEmpty) {
        Get.snackbar('Error', 'No internet connection', snackPosition: SnackPosition.BOTTOM);
        setState(() {
          isLoading = false;
          isButtonDisabled = false;
        });
        return;
      }
    } catch (_) {
      Get.snackbar('Error', 'No internet connection', snackPosition: SnackPosition.BOTTOM);
      setState(() {
        isLoading = false;
        isButtonDisabled = false;
      });
      return;
    }

    final success = await loginViewModel.login(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );

    if (!success) {
      Get.snackbar('Error', 'Invalid user ID or password', snackPosition: SnackPosition.BOTTOM);
      setState(() {
        isLoading = false;
        isButtonDisabled = false;
      });
      return;
    }

    await prefs.setString('userId', _emailController.text.trim());
    await prefs.reload();
    user_id = prefs.getString('userId')!;
    debugPrint("User ID: $user_id");

    try {
      // Total number of tasks to track progress
      final totalTasks = 10; // Adjust this based on the number of tasks
      int completedTasks = 0;

      // Function to update progress
      void updateProgress() {
        completedTasks++;
        _progressNotifier.value = completedTasks / totalTasks;
      }

      // Conditional execution based on user designation
      if (userDesignation == 'RSM' || userDesignation == 'SM' || userDesignation == 'NSM') {
        await addShopViewModel.fetchAndSaveHeadsShop();
        updateProgress();
        await shopVisitViewModel.serialCounterGetHeads();
        updateProgress();
        await attendanceViewModel.serialCounterGet();
        updateProgress();
        await attendanceOutViewModel.serialCounterGet();
        updateProgress();
        await locationViewModel.serialCounterGet();
        updateProgress();
      } else {
        await addShopViewModel.fetchAndSaveShop();
        updateProgress();
        await shopVisitViewModel.serialCounterGet();
        updateProgress();
        await Future.wait<void>([
          addShopViewModel.serialCounterGet(),
          shopVisitViewModel.serialCounterGet(),
          shopVisitDetailsViewModel.serialCounterGet(),
          recoveryFormViewModel.serialCounterGet(),
          returnFormViewModel.serialCounterGet(),
          returnFormDetailsViewModel.serialCounterGet(),
          attendanceViewModel.serialCounterGet(),
          attendanceOutViewModel.serialCounterGet(),
          orderMasterViewModel.serialCounterGet(),
          orderDetailsViewModel.serialCounterGet(),
          locationViewModel.serialCounterGet(),
        ]);
        updateProgress();

        // Execute other fetch and save operations concurrently
        await Future.wait<void>([
          productsViewModel.fetchAndSaveProducts(),
          orderMasterViewModel.fetchAndSaveOrderMaster(),
          orderDetailsViewModel.fetchAndSaveOrderDetails(),
          shopVisitDetailsViewModel.initializeProductData(),
          updateFunctionViewModel.checkAndSetInitializationDateTime(),
        ]);
        updateProgress();
      }

      debugPrint(
          "recoveryHighestSerial: $shopVisitHighestSerial, "
              "shopVisitDetailsHighestSerial: $shopVisitDetailsHighestSerial, "
              "orderMasterHighestSerial: $orderMasterHighestSerial, "
              "orderDetailsHighestSerial: $orderDetailsHighestSerial, "
              "returnDetailsHighestSerial: $returnDetailsHighestSerial, "
              "returnMasterHighestSerial: $returnMasterHighestSerial, "
              "attendanceInHighestSerial: $attendanceInHighestSerial, "
              "attendanceOutHighestSerial: $attendanceOutHighestSerial, "
              "locationHighestSerial: $locationHighestSerial, "
              "shopHighestSerial: $shopHighestSerial"
      );

      await loginViewModel.navigateToHomePage();
    } catch (e) {
      debugPrint('Error fetching data: $e');
      Get.snackbar('Error', 'Failed to fetch data: $e', snackPosition: SnackPosition.BOTTOM);
    } finally {
      setState(() {
        isLoading = false;
        isButtonDisabled = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return SafeArea(
      child: Scaffold(
        body: SizedBox(
          width: size.width,
          height: size.height,
          child: SingleChildScrollView(
            child: Stack(
              children: [
                _buildHeader(size.height * 0.5),
                Padding(
                  padding: EdgeInsets.only(top: size.height * 0.4),
                  child: _buildLoginForm(size),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(double height) {

    return Container(
      height: height,
      width: double.infinity,
      color: Colors.blue,
      child:  Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Welcome\n$companyName',
              style: TextStyle(
                fontSize: 32,
                fontFamily: "Poppins",
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 5),
            const Text(
              'Sign in to Continue',
              style: TextStyle(
                fontSize: 20,
                fontFamily: "Poppins",
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginForm(Size size) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Form(
            key: _formKey,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
              child: Column(
                children: [
                  SizedBox(height: size.height * 0.01),
                  CustomEditableMenuOption(
                    width: size.width * 1.0,
                    label: 'Employee ID',
                    initialValue: _emailController.text,
                    onChanged: (value) {
                      _emailController.text = value;
                    },
                    useBoxShadow: false,
                    icon: Icons.email,
                    iconColor: Colors.blue,
                    textAlign: TextAlign.left,
                    inputBorder: const UnderlineInputBorder(),
                  ),
                  CustomEditableMenuOption(
                    width: size.width * 1.0,
                    label: 'Password',
                    initialValue: _passwordController.text,
                    onChanged: (value) {
                      _passwordController.text = value;
                    },
                    useBoxShadow: false,
                    icon: Icons.lock,
                    iconColor: Colors.blue,
                    textAlign: TextAlign.left,
                    obscureText: !isPasswordVisible,
                    inputBorder: const UnderlineInputBorder(),
                  ),
                  SizedBox(height: size.height * 0.02),
                  _buildRememberMeRow(),
                  SizedBox(height: size.height * 0.02),
                  ValueListenableBuilder<double>(
                    valueListenable: _progressNotifier,
                    builder: (context, progress, _) {
                      return CustomButton(
                        height: size.height * 0.065,
                        width: size.width * 0.45,
                        onTap: isButtonDisabled ? null : _login,
                        buttonText: isLoading
                            ? 'Please wait... ${(progress * 100).toStringAsFixed(0)}%'
                            : 'Sign in',
                        padding: EdgeInsets.symmetric(horizontal: size.width * 0.01),
                        gradientColors: const [Colors.blue, Colors.blue],
                      );
                    },
                  ),
                  SizedBox(height: size.height * 0.03),
                  _buildSocialIcons(),
                  SizedBox(height: size.height * 0.1),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRememberMeRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Row(
        children: [
          Checkbox(
            value: isChecked,
            activeColor: kPrimaryColor,
            onChanged: (bool? newValue) {
              setState(() {
                isChecked = newValue!;
              });
            },
          ),
          const Text(
            'Remember Me',
            style: TextStyle(fontSize: 16, fontFamily: 'OpenSans'),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () {
              // Forgot password logic here
            },
            child: const Text(
              'Forgot password?',
              style: TextStyle(
                color: kPrimaryColor,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialIcons() {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // RoundedIcon(imageUrl: "assets/images/Google.jpg"),
        // SizedBox(width: 35),
        // RoundedIcon(imageUrl: "assets/images/fb.jpg"),
        // SizedBox(width: 35),
        // RoundedIcon(imageUrl: "assets/images/2504839.png"),
      ],
    );
  }
}