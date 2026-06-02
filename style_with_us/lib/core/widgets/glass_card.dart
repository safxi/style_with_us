import 'dart:ui';

import 'package:flutter/material.dart';
import '../theme/style_tokens.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final double blur;
  final double opacity;
  final EdgeInsetsGeometry? padding;

  const GlassCard({
    super.key,
    required this.child,
    this.blur = glassBlur,
    this.opacity = glassOpacity,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radiusLarge),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          decoration: BoxDecoration(
            color: glassBackground.withOpacity(opacity),
            borderRadius: BorderRadius.circular(radiusLarge),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1.5,
            ),
          ),
          child: padding != null ? Padding(padding: padding!, child: child) : child,
        ),
      ),
    );
  }
}

