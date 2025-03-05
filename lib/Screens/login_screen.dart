import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
// import 'package:connectivity/connectivity.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:order_booking_app/Models/return_form_model.dart';
import 'package:order_booking_app/Models/returnform_details_model.dart';
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
import 'package:order_booking_app/screens/Components/custom_button.dart';
import 'package:order_booking_app/screens/signup_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Databases/util.dart';
import '../components/under_part.dart';
import '../constants.dart';
import '../widgets/rounded_button.dart';
import '../widgets/rounded_icon.dart';
import 'components/custom_editable_menu_option.dart';
//padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  LoginViewModel loginViewModel =Get.put(LoginViewModel());

  final _formKey = GlobalKey<FormState>();
  bool isChecked = true;
  bool isPasswordVisible = false;
  // String? email;
  // String? password;
  bool _isLoading = false;
  String _loadingMessage = '';
  // // Mocked registered users
  // final List<String> _registeredUsers = ['B02', 'hamid2'];

  // Future<bool> _checkIfUserExists(String email) async {
  //   await Future.delayed(const Duration(seconds: 1));
  //   return _registeredUsers.contains(email);
  // }
  _login() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    bool isConnected = false;
    for (int i = 0; i < 20; i++) {
      var connectivityResult = await (Connectivity().checkConnectivity());
      if (connectivityResult != ConnectivityResult.none) {
        try {
          final result = await InternetAddress.lookup('example.com');
          if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
            isConnected = true;
            break;
          }
        } catch (_) {
          // Internet is not working
        }
      }
      await Future.delayed(Duration(seconds: 1));
    }

    if (!isConnected) {
      Get.snackbar('Error', 'No internet connection', snackPosition: SnackPosition.BOTTOM);
      return;
    }

    await prefs.setString('userId', _emailController.text.trim());
    user_id = prefs.getString('userId')!;

    bool success = await loginViewModel.login(
      _emailController.text,
      _passwordController.text,
    );

    if (success) {
      try {
        AddShopViewModel addShopViewModel = Get.put(AddShopViewModel());
        ProductsViewModel productsViewModel = Get.put(ProductsViewModel());
        ShopVisitViewModel shopVisitViewModel = Get.put(ShopVisitViewModel());
        ShopVisitDetailsViewModel shopVisitDetailsViewModel = Get.put(ShopVisitDetailsViewModel());
        OrderMasterViewModel orderMasterViewModel = Get.put(OrderMasterViewModel());
        OrderDetailsViewModel orderDetailsViewModel = Get.put(OrderDetailsViewModel());
        RecoveryFormViewModel recoveryFormViewModel = Get.put(RecoveryFormViewModel());
        ReturnFormModel returnFormModel = Get.put(ReturnFormModel());
        ReturnFormDetailsModel returnFormDetailsModel = Get.put(ReturnFormDetailsModel());
        AttendanceViewModel attendanceViewModel = Get.put(AttendanceViewModel());
        AttendanceOutViewModel attendanceOutViewModel = Get.put(AttendanceOutViewModel());
        LocationViewModel locationViewModel = Get.put(LocationViewModel());

        await addShopViewModel.fetchAndSaveShop();
        await productsViewModel.fetchAndSaveProducts();
        await shopVisitDetailsViewModel.initializeProductData();

        // If the above operations complete successfully, navigate to the home screen
        Future.delayed(Duration(milliseconds: 300), () {
          // Navigate to appropriate homepage based on user designation

              Get.offNamed('/home');


        });
      } catch (e) {
        Get.snackbar('Error', 'Failed to fetch products: $e', snackPosition: SnackPosition.BOTTOM);
      }
    } else {
      Get.snackbar('Error', 'Invalid user ID or password', snackPosition: SnackPosition.BOTTOM);
    }

    // setState(() {
    //   _isLoading = false;
    //   _loadingMessage = '';
    // });
  }

 _handleSignIn() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      bool userExists =  _login();
      if (!userExists) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account does not exist. Please sign up first..'),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        if (kDebugMode) {
          print('Login successful: Email: $_emailController, Password: $_passwordController');
        }
        // Navigate to the next screen or home page
      }
    }
  }

  @override
  Widget build(BuildContext context) {

    Size size = MediaQuery.of(context).size;
    return SafeArea(
      child: Scaffold(
        body: SizedBox(
          width: size.width,
          height: size.height,
          child: SingleChildScrollView(
            child: Stack(
              children: [
                // Background Header
                _buildHeader(size.height * 0.5),

                // Login Form
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
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text(
              'Welcome Back',
              textAlign: TextAlign.left,
              style: TextStyle(
                fontSize: 32,
                fontFamily: "Poppins",
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 5),
            Text(
              'Sign in to Continue',
              textAlign: TextAlign.left,
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
    Size size = MediaQuery.of(context).size;
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
            child: Padding(padding:  EdgeInsets.symmetric(horizontal: size.width * 0.05),
            child:  Column(

              children: [
                SizedBox(height: size.height * 0.01),
                CustomEditableMenuOption(
                  width: size.width*1.0,

                // height: size.height*0.1,
                 // bottom: size.height*0.9,
                 // bottom: size.height*0.1,
                  label: 'Email',
                  initialValue: _emailController.text,
                  onChanged: (value) {
                    _emailController.text = value;
                  },
                  useBoxShadow: false,
                  icon: Icons.email,

                  iconColor: Colors.blue,
                  textAlign: TextAlign.left,
                  inputBorder: const UnderlineInputBorder(
                 //   borderSide: BorderSide(color: Colors.grey, width: 1.0),
                  ),
                ),
                // SizedBox(height: size.height * 0.02),
                CustomEditableMenuOption(
                  width: size.width*1.0,
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
                  inputBorder: const UnderlineInputBorder(
                  //  borderSide: BorderSide(color: Colors.grey, width: 2.0),
                  ),
                ),SizedBox(height: size.height * 0.02),
                _buildRememberMeRow(),
                SizedBox(height: size.height * 0.02),
               CustomButton(
                 height: size.height*0.065,
                 width: size.width*0.45,
                 onTap: _login,
                 buttonText: "Sign In",
                 padding: EdgeInsets.symmetric(horizontal: size.width * 0.01) ,
                 gradientColors: const [Colors.blue,Colors.blue,],
               ),
                SizedBox(height: size.height * 0.03),
                UnderPart(
                  title: "Don't have an account?",
                  navigatorText: "Sign up here",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SignUpScreen()),
                    );
                  },
                ),
                SizedBox(height: size.height * 0.03),
                _buildSocialIcons(),
                SizedBox(height: size.height * 0.1),
              ],
            ),
          ),)
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
        RoundedIcon(imageUrl: "assets/images/Google.jpg"),

        SizedBox(width: 35),
        RoundedIcon(imageUrl: "assets/images/fb.jpg"),

        SizedBox(width: 35),
        RoundedIcon(imageUrl: "assets/images/2504839.png"),
      ],
    );
  }
}
