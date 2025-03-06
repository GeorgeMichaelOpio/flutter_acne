import 'package:flutter/material.dart';

import '../../../constants.dart';
import 'secondary_product_skelton.dart';

class SeconderyScansSkelton extends StatelessWidget {
  const SeconderyScansSkelton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 114,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 4,
        itemBuilder: (context, index) => Padding(
          padding: EdgeInsets.only(
            left: defaultPadding,
            right: index == 3 ? defaultPadding : 0,
          ),
          child: const SeconderyProductSkelton(),
        ),
      ),
    );
  }
}
