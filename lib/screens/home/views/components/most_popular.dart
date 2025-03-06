import 'package:flutter/material.dart';
import '/components/product/secondary_product_card.dart';
import '/models/product_model.dart';

import '../../../../constants.dart';
import '../../../../route/route_constants.dart';

class MostPopular extends StatelessWidget {
  const MostPopular({
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
            "Most popular",
            style: Theme.of(context).textTheme.titleSmall,
          ),
        ),
        // While loading use 👇
        // SeconderyScansSkelton(),
        SizedBox(
          height: 114,
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
              child: SecondaryProductCard(
                image: demoPopularScans[index].image,
                brandName: demoPopularScans[index].brandName,
                title: demoPopularScans[index].title,
                price: demoPopularScans[index].price,
                priceAfetDiscount: demoPopularScans[index].priceAfetDiscount,
                dicountpercent: demoPopularScans[index].dicountpercent,
                press: () {
                  Navigator.pushNamed(context, productDetailsScreenRoute,
                      arguments: index.isEven);
                },
              ),
            ),
          ),
        )
      ],
    );
  }
}
