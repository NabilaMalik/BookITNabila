import 'package:flutter/material.dart';
import 'package:flutter_searchable_dropdown/flutter_searchable_dropdown.dart';

class CustomDropdown extends StatelessWidget {
  final String label;
  final IconData icon;
  final List<String> items;
  final String? selectedValue;
  final ValueChanged<String?> onChanged;
  final String? Function(String?) validator;

  const CustomDropdown({
    Key? key,
    required this.label,
    required this.icon,
    required this.items,
    required this.selectedValue,
    required this.onChanged,
    required this.validator,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FormField<String>(
            validator: validator,
            builder: (FormFieldState<String> state) {
              return InputDecorator(
                decoration: InputDecoration(
                  labelText: selectedValue == null ? label : null,
                  prefixIcon: Icon(icon, color: Colors.blue),
                  border: const OutlineInputBorder(),
                  errorText: state.hasError ? state.errorText : null,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12.0,
                    vertical: 10.0,
                  ),
                  floatingLabelBehavior: FloatingLabelBehavior.auto, // Ensures label floats when selected
                ),
                isEmpty: selectedValue == null,
                child: DropdownButtonHideUnderline(
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
              );
            },
          ),
        ],
      ),
    );
  }
}
