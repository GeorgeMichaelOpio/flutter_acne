import 'package:flutter/material.dart';
import '../../../../components/product/product_card.dart';
import '/route/route_constants.dart';

import '/components/Banner/M/banner_m_with_counter.dart';
import '../../../../constants.dart';
import '../../../../models/product_model.dart';

class FlashSale extends StatelessWidget {
  const FlashSale({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // While loading show 👇
        // const BannerMWithCounterSkelton(),
        BannerMWithCounter(
          duration: const Duration(hours: 8),
          text: "Super Flash Sale \n50% Off",
          press: () {},
        ),
        const SizedBox(height: defaultPadding / 2),
        Padding(
          padding: const EdgeInsets.all(defaultPadding),
          child: Text(
            "Flash sale",
            style: Theme.of(context).textTheme.titleSmall,
          ),
        ),
        // While loading show 👇
        // const ScansSkelton(),
        SizedBox(
          height: 220,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            // Find demoFlashSaleScans on models/ProductModel.dart
            itemCount: demoFlashSaleScans.length,
            itemBuilder: (context, index) => Padding(
              padding: EdgeInsets.only(
                left: defaultPadding,
                right:
                    index == demoFlashSaleScans.length - 1 ? defaultPadding : 0,
              ),
              child: ProductCard(
                image: demoFlashSaleScans[index].image,
                brandName: demoFlashSaleScans[index].brandName,
                title: demoFlashSaleScans[index].title,
                dicountpercent: demoFlashSaleScans[index].dicountpercent,
                press: () {
                  Navigator.pushNamed(context, productDetailsScreenRoute,
                      arguments: index.isEven);
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}
