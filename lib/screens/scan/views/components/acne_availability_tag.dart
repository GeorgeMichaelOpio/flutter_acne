import 'package:flutter/material.dart';

import '../../../../constants.dart';

class AcneAvailabilityTag extends StatelessWidget {
  const AcneAvailabilityTag({super.key, required this.isAvailable});

  final bool isAvailable;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(defaultPadding / 2),
      decoration: BoxDecoration(
        color: isAvailable ? errorColor : successColor,
        borderRadius: const BorderRadius.all(Radius.circular(50)),
      ),
      child: Text(
        isAvailable ? "Acne Detected" : "Acne Not Detected",
        style: Theme.of(context).textTheme.labelSmall!.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
