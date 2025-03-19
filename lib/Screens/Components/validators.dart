import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

class Validators {
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a password';
    } else if (value.length < 6) {
      return 'Password must be at least 6 characters long';
    }
    return null;
  }

  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    } else if (value != password) {
      return 'Passwords do not match';
    }
    return null;
  }

  static String? validateTextField(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return 'Please enter $fieldName';
    }
    return null;
  }
  static String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your phone number';
    } else if (!RegExp(r'^\d{4}-\d{7}$').hasMatch(value)) {
      return 'Phone number must be in format 0303-3899999';
    }
    return null;
  }
  static String? validateCNIC(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your CNIC number';
    } else if (!RegExp(r'^\d{5}-\d{7}-\d{1}$').hasMatch(value)) {
      return 'CNIC must be in format 12345-1234567-1';
    }
    return null;
  }



}


class PhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    // Remove all non-digit characters
    final digitsOnly = newValue.text.replaceAll(RegExp(r'\D'), '');

    final buffer = StringBuffer();
    for (int i = 0; i < digitsOnly.length && i < 11; i++) {
      buffer.write(digitsOnly[i]);
      if (i == 3 ) {
        buffer.write('-');
      }
    }

    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}


class CNICInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    String digitsOnly = newValue.text.replaceAll(RegExp(r'\D'), '');
    String formatted = '';

    if (digitsOnly.length >= 5) {
      formatted += digitsOnly.substring(0, 5) + '-';
      if (digitsOnly.length >= 12) {
        formatted += digitsOnly.substring(5, 12) + '-';
        formatted += digitsOnly.substring(12, digitsOnly.length > 13 ? 13 : digitsOnly.length);
      } else if (digitsOnly.length > 5) {
        formatted += digitsOnly.substring(5);
      }
    } else {
      formatted = digitsOnly;
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
