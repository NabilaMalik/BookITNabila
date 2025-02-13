import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';

class CustomDropdown extends StatefulWidget {
  final String label;
  final IconData icon;
  final List<String> items;
  final String? selectedValue;
  final ValueChanged<String?> onChanged;
  final String? Function(String?) validator;
  final InputBorder? inputBorder;
  final Color? borderColor;
  final Color? iconColor;
  final Color? iconBackgroundColor;
  final List<BoxShadow>? boxShadow;
  final bool useBoxShadow;
  final double? maxHeight;
  final double? maxWidth;
  final double? iconSize;
  final double? contentPadding;
  final TextStyle? textStyle;
  final double? width;
  final double? height;
  const CustomDropdown({
    super.key,
    required this.label,
    required this.icon,
    required this.items,
    required this.selectedValue,
    required this.onChanged,
    required this.validator,
    this.inputBorder,
    this.borderColor,
    this.iconColor,
    this.iconBackgroundColor,
    this.boxShadow,
    this.useBoxShadow = true,
    this.maxHeight,
    this.maxWidth,
    this.iconSize = 24.0,
    this.contentPadding = 16.0,
    //this.font
    this.textStyle,
    this.width,
    this.height,
  });

  @override
  _CustomDropdownState createState() => _CustomDropdownState();
}

class _CustomDropdownState extends State<CustomDropdown> {
  late String? _selectedValue;

  @override
  void initState() {
    super.initState();
    _selectedValue = widget.selectedValue;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 2),
        child: Container(
            width: widget.width ?? double.infinity,
            height: widget.height ?? 65.0,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(3),
              boxShadow: widget.useBoxShadow
                  ? widget.boxShadow ??
                  [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      offset: Offset(3, 5),
                      blurRadius: 6,
                    ),
                  ]
                  : null,
              border: Border.all(
                color: widget.borderColor ?? Colors.transparent,
                width: 1.0,
              ),
            ),
            child: Row(
              children: [
                if (widget.icon != null)
                  Container(
                    decoration: BoxDecoration(
                      color: widget.iconBackgroundColor ?? Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.all(5.0),
                    child: Icon(
                      widget.icon,
                      size: widget.iconSize,
                      color: widget.iconColor ?? Colors.black,
                    ),
                  ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: widget.contentPadding!),
                    child: FormField<String>(
                      validator: widget.validator,
                      builder: (FormFieldState<String> state) {
                        return InputDecorator(
                          decoration: InputDecoration(
                            labelText: _selectedValue == null ? widget.label : null,
                            border: widget.inputBorder ?? InputBorder.none,
                            errorText: state.hasError ? state.errorText : null,
                            contentPadding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: .0),
                            // contentPadding: EdgeInsets.symmetric(vertical: widget.contentPadding!),
                            floatingLabelBehavior: FloatingLabelBehavior.auto,
                          ),
                          isEmpty: _selectedValue == null,
                          child: DropdownButtonHideUnderline(
                            child: DropdownSearch<String>(
                              popupProps: PopupProps.bottomSheet(
                                showSearchBox: true,
                                itemBuilder: (context, item, isSelected) => Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    item,
                                    style: const TextStyle( color: Colors.black, fontSize: 15), // ✅ Set font size for dropdown items
                                  ),
                                ),
                              ),
                              items: widget.items,
                              selectedItem: _selectedValue,
                              dropdownDecoratorProps: DropDownDecoratorProps(
                                dropdownSearchDecoration: InputDecoration(

                                  //hintText: 'Select ${widget.label}',
                                  labelText: 'Select ${widget.label}',
                                  border: InputBorder.none,
                                ),
                              ),
                              dropdownBuilder: (context, selectedItem) => Text(
                                selectedItem ?? 'Select ${widget.label}',
                                style: const TextStyle(fontSize: 15,  color: Colors.black), // ✅ Set font size for selected item
                              ),
                              onChanged: (value) {
                                setState(() {
                                  _selectedValue = value;
                                  widget.onChanged(value);
                                });
                                state.didChange(value);
                              },
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