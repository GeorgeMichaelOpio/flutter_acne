import 'package:flutter/material.dart';
import '/components/product/product_card.dart';
import '/models/product_model.dart';
import '/route/route_constants.dart';

import '../../../constants.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // While loading use 👇
          //  BookMarksSlelton(),
          SliverPadding(
            padding: const EdgeInsets.symmetric(
                horizontal: defaultPadding, vertical: defaultPadding),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 200.0,
                mainAxisSpacing: defaultPadding,
                crossAxisSpacing: defaultPadding,
                childAspectRatio: 0.66,
              ),
              delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) {
                  return ProductCard(
                    image: demoRecentScans[index].image,
                    brandName: demoRecentScans[index].brandName,
                    title: demoRecentScans[index].title,
                    dicountpercent: demoRecentScans[index].dicountpercent,
                    press: () {
                      Navigator.pushNamed(context, productDetailsScreenRoute);
                    },
                  );
                },
                childCount: demoRecentScans.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
