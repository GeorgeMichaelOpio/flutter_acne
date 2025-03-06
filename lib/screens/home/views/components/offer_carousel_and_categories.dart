import 'package:flutter/material.dart';
import '../../../../constants.dart';
import 'categories.dart';
import 'offers_carousel.dart';

class OffersCarouselAndActivities extends StatelessWidget {
  const OffersCarouselAndActivities({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const OffersCarousel(),
        const SizedBox(height: defaultPadding / 2),
        Padding(
          padding: const EdgeInsets.all(defaultPadding),
          child: Text(
            "Activities",
            style: Theme.of(context).textTheme.titleSmall,
          ),
        ),
        const Activities(),
      ],
    );
  }
}
