import 'dart:ui';

import 'package:flutter/material.dart';

/// A widget that provides glass effect for a [child],
/// Since color and dimensions of Container have to be in same Container, the childWIdget
/// has to specify gradient and borders by itself
class GlassMorphismCover extends StatelessWidget {
  final Widget child;
  final BorderRadius borderRadius;
  final bool displayShadow;

  const GlassMorphismCover(
      {Key? key,
      required this.child,
      required this.borderRadius,
      this.displayShadow = true})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        boxShadow: [
          if (displayShadow)
            BoxShadow(
              blurRadius: 24,
              spreadRadius: 16,
              color: Colors.black.withOpacity(0.1),
            )
        ],
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 40.0,
            sigmaY: 40.0,
          ),
          child: Container(
            // This container creates the colored glass effect
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: borderRadius,
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1.5,
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
