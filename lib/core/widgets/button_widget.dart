// Button variants enum
import 'package:flutter/material.dart';
import 'package:phoshar/core/constants/app_colors.dart';
import 'package:phoshar/core/constants/app_spacing.dart';

// Button variants enum
enum ButtonVariant { primary, secondary, tertiary, outline }

// Reusable Custom Button Widget
class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonVariant variant;
  final double? width;
  final double height;
  final double fontSize;
  final FontWeight fontWeight;
  final Widget? icon;
  final bool isLoading;
  final bool enabled; // Add this parameter
  final double borderRadius;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.variant = ButtonVariant.primary,
    this.width,
    this.height = 56,
    this.fontSize = 18,
    this.fontWeight = FontWeight.w600,
    this.icon,
    this.isLoading = false,
    this.enabled = true, // Add this with default true
    this.borderRadius = AppRadius.large,
  });

  @override
  Widget build(BuildContext context) {
    // final bool isDisabled = onPressed == null || isLoading;
    final bool isDisabled =
        onPressed == null || isLoading || !enabled; // Update this line

    // Get colors based on variant
    Color backgroundColor;
    Color textColor;
    Color? borderColor;

    switch (variant) {
      case ButtonVariant.primary:
        backgroundColor = isDisabled
            ? Theme.of(context).primaryColor.withValues(alpha: 0.5)
            : Theme.of(context).primaryColor;
        textColor = Colors.white;
        borderColor = null;
        break;
      case ButtonVariant.secondary:
        backgroundColor = isDisabled ? Colors.grey.shade100 : Colors.white;
        textColor = isDisabled
            ? Colors.grey.shade400
            : Theme.of(context).primaryColor;
        borderColor = isDisabled
            ? Colors.grey.shade300
            : Theme.of(context).primaryColor;
        break;
      case ButtonVariant.tertiary:
        backgroundColor = isDisabled
            ? Colors.grey.shade100
            : Colors.grey.shade200;
        textColor = isDisabled ? Colors.grey.shade400 : Colors.black87;
        borderColor = null;
        break;
      case ButtonVariant.outline:
        backgroundColor = isDisabled
            ? AppColors.surface.withValues(alpha: 0.5)
            : AppColors.surface;
        textColor = isDisabled
            ? AppColors.textPrimary.withValues(alpha: 0.5)
            : AppColors.textPrimary;
        borderColor = isDisabled
            ? AppColors.divider.withValues(alpha: 0.5)
            : AppColors.divider;
        break;
    }

    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: icon != null
          ? ElevatedButton.icon(
              onPressed: isDisabled ? null : onPressed,
              style: _getButtonStyle(backgroundColor, borderColor),
              icon: isLoading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(textColor),
                      ),
                    )
                  : icon!,
              label: Text(
                text,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: fontWeight,
                  color: textColor,
                ),
              ),
            )
          : ElevatedButton(
              onPressed: isDisabled ? null : onPressed,
              style: _getButtonStyle(backgroundColor, borderColor),
              child: isLoading
                  ? SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(textColor),
                      ),
                    )
                  : Text(
                      text,
                      style: TextStyle(
                        fontSize: fontSize,
                        fontWeight: fontWeight,
                        color: textColor,
                      ),
                    ),
            ),
    );
  }

  ButtonStyle _getButtonStyle(Color backgroundColor, Color? borderColor) {
    return ElevatedButton.styleFrom(
      backgroundColor: backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        side: borderColor != null
            ? BorderSide(color: borderColor, width: 1)
            : BorderSide.none,
      ),
      elevation: 0,
      shadowColor: Colors.transparent,
      disabledBackgroundColor: backgroundColor,
    );
  }
}


/**
 * EXAMPLE USAGE
// Outline Button (new variant)
CustomButton(
  text: 'Register Account',
  variant: ButtonVariant.outline,
  fontSize: 16,
  fontWeight: FontWeight.w500,
  onPressed: () {
    Navigator.pushNamed(
      context,
      NavigationRoutes.authRegister.path,
    );
  },
)

// Primary Button
CustomButton(
  text: 'Continue',
  onPressed: () {},
)

// Secondary Button
CustomButton(
  text: 'Sign In',
  variant: ButtonVariant.secondary,
  onPressed: () {},
)

// Tertiary Button
CustomButton(
  text: 'Cancel',
  variant: ButtonVariant.tertiary,
  onPressed: () {},
)

// Outline Button with icon
CustomButton(
  text: 'Add New',
  variant: ButtonVariant.outline,
  icon: Icon(Icons.add, color: AppColors.textPrimary),
  onPressed: () {},
)

// Disabled Outline Button
CustomButton(
  text: 'Register Account',
  variant: ButtonVariant.outline,
  onPressed: null,
)

 * 
 */