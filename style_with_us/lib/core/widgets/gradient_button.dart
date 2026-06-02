import 'package:flutter/material.dart';
import '../theme/style_tokens.dart';

class GradientButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final List<Color>? gradientColors;

  const GradientButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.gradientColors,
  });

  @override
  Widget build(BuildContext context) {
    final isDisabled = onPressed == null || isLoading;
    final baseColors = gradientColors ?? const [primaryPurple, primaryPink];
    final colors = isDisabled
        ? [Colors.grey.shade400, Colors.grey.shade500]
        : baseColors;

    return SizedBox(
      height: 56,
      width: double.infinity,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: colors),
          borderRadius: BorderRadius.circular(radiusMedium),
          boxShadow: isDisabled ? null : floatingShadow,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isDisabled ? null : onPressed,
            borderRadius: BorderRadius.circular(radiusMedium),
            child: Center(
              child: isLoading
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.4,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      text,
                      style: buttonText.copyWith(
                        color: isDisabled ? Colors.white.withOpacity(0.7) : Colors.white,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

