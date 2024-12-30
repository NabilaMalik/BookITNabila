import 'package:flutter/material.dart';
import 'custom_editable_menu_option.dart';

class CustomButton extends StatelessWidget {
  final double? top;
  final double? left;
  final double? right;
  final double? bottom;
  final double? width;
  final double? height;
  final dynamic buttonText;
  final TextStyle? textStyle;
  final VoidCallback onTap;
  final double borderRadius;
  final List<Color> gradientColors;
  final List<BoxShadow>? boxShadow;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final IconData? icon;
  final double? iconSize;
  final Color? iconColor;
  final Color? iconBackgroundColor;
  final double spacing;
  final IconPosition iconPosition;
  final TextAlign textAlign;
  final Color? borderColor; // New parameter for border color

  const CustomButton({
    super.key,
    this.top,
    this.left,
    this.right,
    this.bottom,
    this.width,
    this.height,
    this.buttonText,
    required this.onTap,
    this.textStyle,
    this.borderRadius = 20.0,
    this.gradientColors = const [Color(0xFF00C853), Color(0xFF64DD17)],
    this.boxShadow,
    this.margin,
    this.padding,
    this.icon,
    this.iconSize = 24.0,
    this.iconColor,
    this.iconBackgroundColor,
    this.spacing = 8.0,
    this.iconPosition = IconPosition.left,
    this.textAlign = TextAlign.center,
    this.borderColor, // Initialize the border color
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width ?? MediaQuery.of(context).size.width * 0.9,
        height: height ?? 60.0,
        margin: margin,
        padding: padding ?? const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: boxShadow ?? [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              offset: const Offset(0, 4),
              blurRadius: 8,
            ),
          ],
          border: Border.all(
            color: borderColor ?? Colors.transparent, // Use the border color parameter
            width: 2.0, // Set the border width
          ),
        ),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: iconPosition == IconPosition.left
                ? _buildIconWithTextLeft()
                : _buildIconWithTextRight(),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildIconWithTextLeft() {
    return [
      if (icon != null) ...[
        if (iconBackgroundColor != null)
          Container(
            width: 58,
            height: 48,
            decoration: BoxDecoration(
              color: iconBackgroundColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10),
                bottomLeft: Radius.circular(10),
                topRight: Radius.circular(10),
                bottomRight: Radius.circular(10),
              ),
            ),
            child: Icon(
              icon,
              size: iconSize,
              color: iconColor ?? Colors.black,
            ),
          )
        else
          Icon(
            icon,
            size: iconSize,
            color: iconColor ?? Colors.black,
          ),
        SizedBox(width: spacing),
      ],
      if (buttonText != null)
        Expanded(
          child: Text(
            buttonText,
            textAlign: textAlign,
            style: textStyle ??
                const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
    ];
  }

  List<Widget> _buildIconWithTextRight() {
    return [
      if (buttonText != null)
        Expanded(
          child: Text(
            buttonText,
            textAlign: textAlign,
            style: textStyle ??
                const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
      SizedBox(width: spacing),
      if (icon != null) ...[
        if (iconBackgroundColor != null)
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: iconBackgroundColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10),
                bottomLeft: Radius.circular(10),
                topRight: Radius.circular(10),
                bottomRight: Radius.circular(10),
              ),
            ),
            child: Icon(
              icon,
              size: iconSize,
              color: iconColor ?? Colors.black,
            ),
          )
        else
          Icon(
            icon,
            size: iconSize,
            color: iconColor ?? Colors.black,
          ),
      ],
    ];
  }
}


