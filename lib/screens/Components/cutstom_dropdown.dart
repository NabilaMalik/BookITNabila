import 'package:flutter/material.dart';
import 'package:flutter_searchable_dropdown/flutter_searchable_dropdown.dart';

class CustomDropdown extends StatelessWidget {
  final String label;
  final IconData icon;
  final List<String> items;
  final String? selectedValue;
  final ValueChanged<String?> onChanged;
  final String? Function(String?) validator;
  final InputBorder? inputBorder; // Parameter for InputBorder
  final Color? borderColor;
  final Color? iconColor;
  final Color? iconBackgroundColor;
  final List<BoxShadow>? boxShadow; // Parameter for box shadow
  final bool useBoxShadow; // Parameter to control box shadow
  final double? maxHeight; // Parameter for optional max height
  final double? maxWidth;  // Parameter for optional max width
  final double? iconSize; // Parameter for icon size
  final double? contentPadding; // Parameter for content padding

  const CustomDropdown({
    Key? key,
    required this.label,
    required this.icon,
    required this.items,
    required this.selectedValue,
    required this.onChanged,
    required this.validator,
    this.inputBorder, // Initialize the inputBorder parameter
    this.borderColor,
    this.iconColor,
    this.iconBackgroundColor,
    this.boxShadow, // Initialize the box shadow parameter
    this.useBoxShadow = true, // Initialize with default value
    this.maxHeight, // Initialize the maxHeight parameter
    this.maxWidth,  // Initialize the maxWidth parameter
    this.iconSize = 24.0, // Initialize the iconSize parameter
    this.contentPadding = 16.0, // Initialize the contentPadding parameter
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Container(
        width: maxWidth ?? double.infinity,
        height: maxHeight ?? 65.0,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: useBoxShadow
              ? boxShadow ??
              [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  offset: Offset(3, 5),
                  blurRadius: 6,
                ),
              ]
              : null,
          border: Border.all(
            color: borderColor ?? Colors.transparent,
            width: 1.0,
          ),
        ),
        child: Row(
          children: [
            if (icon != null)
              Container(
                decoration: BoxDecoration(
                  color: iconBackgroundColor ?? Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.all(5.0),
                child: Icon(
                  icon,
                  size: iconSize,
                  color: iconColor ?? Colors.black,
                ),
              ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: contentPadding!),
                child: FormField<String>(
                  validator: validator,
                  builder: (FormFieldState<String> state) {
                    return InputDecorator(
                      decoration: InputDecoration(
                        labelText: selectedValue == null ? label : null,
                        border: inputBorder ?? InputBorder.none,
                        errorText: state.hasError ? state.errorText : null,
                        contentPadding: EdgeInsets.symmetric(vertical: contentPadding!),
                        floatingLabelBehavior: FloatingLabelBehavior.auto,
                      ),
                      isEmpty: selectedValue == null,
                      child: DropdownButtonHideUnderline(
                        child: Container(
                          constraints: BoxConstraints(
                            maxWidth: maxWidth ?? double.infinity,
                            maxHeight: maxHeight ?? 65.0,
                          ),
                          child: SearchableDropdown.single(
                            items: items.map((item) {
                              return DropdownMenuItem<String>(
                                value: item,
                                child: Text(item),
                              );
                            }).toList(),
                            value: selectedValue,
                            searchHint: Text('Search $label'),
                            onChanged: (value) {
                              state.didChange(value);
                              onChanged(value);
                            },
                            isExpanded: true,
                            displayClearIcon: true,
                            menuBackgroundColor: Colors.white,
                            style: const TextStyle(fontSize: 16, color: Colors.black),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
