import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:order_booking_app/screens/Components/custom_button.dart';
import 'package:order_booking_app/screens/signup_screen.dart';
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
  final _formKey = GlobalKey<FormState>();
  bool isChecked = true;
  bool isPasswordVisible = false;
  String? email;
  String? password;

  // Mocked registered users
  final List<String> _registeredUsers = ['test@example.com', 'user@example.com'];

  Future<bool> _checkIfUserExists(String email) async {
    await Future.delayed(const Duration(seconds: 1));
    return _registeredUsers.contains(email);
  }

  void _handleSignIn() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      bool userExists = await _checkIfUserExists(email!);
      if (!userExists) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account does not exist. Please sign up first.'),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        if (kDebugMode) {
          print('Login successful: Email: $email, Password: $password');
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
                  initialValue: '',
                  onChanged: (value) {
                    email = value;
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
                  initialValue: '',
                  onChanged: (value) {
                    password = value;
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
                 onTap: _handleSignIn,
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
