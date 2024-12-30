import 'package:flutter/material.dart';

enum IconPosition { left, right }

class CustomEditableMenuOption extends StatefulWidget {
  final double? top;
  final double? left;
  final double? right;
  final double? bottom;
  final double? width;
  final double? height;
  final String label;
  final String initialValue;
  final ValueChanged<String> onChanged;
  final Color? borderColor;
  final IconData? icon;
  final double? iconSize;
  final Color? iconColor;
  final Color? iconBackgroundColor;
  final double spacing;
  final IconPosition iconPosition;
  final TextAlign textAlign;
  final bool obscureText; // Parameter for obscuring text
  final InputBorder? inputBorder; // Parameter for InputBorder
  final List<BoxShadow>? boxShadow; // Parameter for box shadow
  final bool useBoxShadow; // Parameter to control box shadow
  final FormFieldValidator<String>? validator; // Add validator parameter
  final TextInputType? keyboardType;

  const CustomEditableMenuOption({
    super.key,
    this.top,
    this.left,
    this.right,
    this.bottom,
    this.width,
    this.height,
    required this.label,
    required this.initialValue,
    required this.onChanged,
    this.borderColor,
    this.icon,
    this.iconSize = 24.0,
    this.iconColor,
    this.iconBackgroundColor,
    this.spacing = 5.0,
    this.iconPosition = IconPosition.left,
    this.textAlign = TextAlign.center,
    this.obscureText = false, // Default value for obscuring text
    this.inputBorder, // Initialize the new parameter
    this.boxShadow, // Initialize the new parameter
    this.useBoxShadow = true, // Initialize the new parameter with default value
    this.validator,
    this.keyboardType, // Initialize the validator
  });

  @override
  _CustomEditableMenuOptionState createState() =>
      _CustomEditableMenuOptionState();
}

class _CustomEditableMenuOptionState extends State<CustomEditableMenuOption> {
  late TextEditingController _controller;
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
    _obscureText = widget.obscureText;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final container = Container(
      width: widget.width ?? double.infinity,
      height: widget.height ?? 65.0,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: widget.useBoxShadow
            ? widget.boxShadow ??
            [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                offset: const Offset(3, 5),
                blurRadius: 6,
              ),
            ]
            : null, // Use the dynamic box shadow if enabled
        border: Border.all(
          color: widget.borderColor ?? Colors.transparent,
          width: 1.0,
        ),
      ),
      child: Row(
        children: widget.iconPosition == IconPosition.left
            ? _buildIconWithTextField()
            : _buildTextFieldWithIcon(),
      ),
    );

    if (widget.top != null || widget.left != null || widget.right != null || widget.bottom != null) {
      return Positioned(
        top: widget.top,
        left: widget.left,
        right: widget.right,
        bottom: widget.bottom,
        child: container,
      );
    }

    return container;
  }

  List<Widget> _buildIconWithTextField() {
    return [
      if (widget.icon != null) ...[
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
        SizedBox(width: widget.spacing),
      ],
      Expanded(
        child: TextFormField(
          controller: _controller,
          obscureText: _obscureText,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black,
          ),
          decoration: InputDecoration(
            labelText: widget.label,
            labelStyle: const TextStyle(
              color: Colors.grey,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            border: widget.inputBorder ?? InputBorder.none, // Use the dynamic input border
            contentPadding: const EdgeInsets.symmetric(vertical: 5),
            suffixIcon: widget.obscureText
                ? IconButton(
              icon: Icon(
                  _obscureText ? Icons.visibility : Icons.visibility_off),
              onPressed: () {
                setState(() {
                  _obscureText = !_obscureText;
                });
              },
            )
                : null,
          ),
          onChanged: widget.onChanged,
          validator: widget.validator, // Use the validator
        ),
      ),
    ];
  }

  List<Widget> _buildTextFieldWithIcon() {
    return [
      Expanded(
        child: TextFormField(
          controller: _controller,
          obscureText: _obscureText,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black,
          ),
          decoration: InputDecoration(
            labelText: widget.label,
            labelStyle: const TextStyle(
              color: Colors.grey,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            border: widget.inputBorder ?? InputBorder.none, // Use the dynamic input border
            contentPadding: const EdgeInsets.symmetric(vertical: 5),
            suffixIcon: widget.obscureText
                ? IconButton(
              icon: Icon(
                _obscureText ? Icons.visibility : Icons.visibility_off,
                color: Colors.blue,
              ),
              onPressed: () {
                setState(() {
                  _obscureText = !_obscureText;
                });
              },
            )
                : null,
          ),
          onChanged: widget.onChanged,
          validator: widget.validator, // Use the validator
        ),
      ),
      if (widget.icon != null) ...[
        SizedBox(width: widget.spacing),
        Container(
          decoration: BoxDecoration(
            color: widget.iconBackgroundColor ?? Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.all(8.0),
          child: Icon(
            widget.icon,
            size: widget.iconSize,
            color: widget.iconColor ?? Colors.black,
          ),
        ),
      ],
    ];
  }
}
