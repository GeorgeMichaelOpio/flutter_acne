import 'package:flutter/material.dart';
import '../../../../components/product/product_card.dart';
import '/models/product_model.dart';
import '/route/screen_export.dart';

import '../../../../constants.dart';

class PopularScans extends StatelessWidget {
  const PopularScans({
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
            "Popular products",
            style: Theme.of(context).textTheme.titleSmall,
          ),
        ),
        // While loading use 👇
        // const ScansSkelton(),
        SizedBox(
          height: 220,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            // Find demoPopularScans on models/ProductModel.dart
            itemCount: demoPopularScans.length,
            itemBuilder: (context, index) => Padding(
              padding: EdgeInsets.only(
                left: defaultPadding,
                right:
                    index == demoPopularScans.length - 1 ? defaultPadding : 0,
              ),
              child: ProductCard(
                image: demoPopularScans[index].image,
                brandName: demoPopularScans[index].brandName,
                title: demoPopularScans[index].title,
                dicountpercent: demoPopularScans[index].dicountpercent,
                press: () {
                  Navigator.pushNamed(
                    context,
                    productDetailsScreenRoute,
                    arguments: {
                      'isProductAvailable': index.isEven,
                      'showSaveButton': index.isEven,
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
