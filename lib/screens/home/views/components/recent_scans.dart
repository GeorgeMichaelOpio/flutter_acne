import 'package:flutter/material.dart';
import '../../../../components/product/product_card.dart';
import '/models/product_model.dart';
import '/route/screen_export.dart';

import '../../../../constants.dart';

class RecentScans extends StatelessWidget {
  const RecentScans({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: defaultPadding / 2),
        Padding(
          padding: const EdgeInsets.all(defaultPadding),
          child: Text(
            "Recent Scans",
            style: Theme.of(context).textTheme.titleSmall,
          ),
        ),
        // While loading use 👇
        // const ScansSkelton(),
        SizedBox(
          height: 220,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            // Find demoRecentScans on models/ScanModel.dart
            itemCount: demoRecentScans.length,
            itemBuilder: (context, index) => Padding(
              padding: EdgeInsets.only(
                left: defaultPadding,
                right: index == demoRecentScans.length - 1 ? defaultPadding : 0,
              ),
              child: ProductCard(
                image: demoRecentScans[index].image,
                brandName: demoRecentScans[index].brandName,
                title: demoRecentScans[index].title,
                dicountpercent: demoRecentScans[index].dicountpercent,
                press: () {
                  Navigator.pushNamed(
                    context,
                    productDetailsScreenRoute,
                    arguments: {
                      'isProductAvailable': index.isEven,
                    },
                  );
                },
              ),
            ),
          ),
        )
      ],
    );
  }
}
