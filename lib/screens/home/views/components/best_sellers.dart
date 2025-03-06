import 'package:flutter/material.dart';
import '/components/product/product_card.dart';
import '/models/product_model.dart';

import '../../../../constants.dart';
import '../../../../route/route_constants.dart';

class BestSellers extends StatelessWidget {
  const BestSellers({
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
            "Best sellers",
            style: Theme.of(context).textTheme.titleSmall,
          ),
        ),
        // While loading use 👇
        // const ScansSkelton(),
        SizedBox(
          height: 220,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            // Find demoBestSellersScans on models/ProductModel.dart
            itemCount: demoBestSellersScans.length,
            itemBuilder: (context, index) => Padding(
              padding: EdgeInsets.only(
                left: defaultPadding,
                right: index == demoBestSellersScans.length - 1
                    ? defaultPadding
                    : 0,
              ),
              child: ProductCard(
                image: demoBestSellersScans[index].image,
                brandName: demoBestSellersScans[index].brandName,
                title: demoBestSellersScans[index].title,
                dicountpercent: demoBestSellersScans[index].dicountpercent,
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
