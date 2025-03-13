import 'package:flutter/material.dart';
import '../../../constants.dart';
import 'components/acne_images.dart';
import 'components/acne_info.dart';
import 'components/acne_list_tile.dart';

class AcneDetailsScreen extends StatelessWidget {
  const AcneDetailsScreen({
    super.key,
    this.isProductAvailable = true,
    this.scanData,
  });

  final bool isProductAvailable;
  final Map<String, dynamic>? scanData;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              floating: true,
            ),
            const AcneImages(
              images: [productDemoImg1, productDemoImg2],
            ),
            ProductInfo(
              brand: "LIPSY LONDON",
              title: "Sleeveless Ruffle",
              isAvailable: isProductAvailable,
              description:
                  "A cool gray cap in soft corduroy. Watch me.' By buying cotton products from Lindex, you're supporting more responsibly...",
            ),
            AcneListTile(
              svgSrc: "assets/icons/Scan.svg",
              title: "Scan Details",
              press: () {},
            ),
            AcneListTile(
              svgSrc: "assets/icons/treatment.svg",
              title: "Recommended Treatment",
              press: () {},
            ),
            const SliverToBoxAdapter(
              child: SizedBox(height: defaultPadding),
            )
          ],
        ),
      ),
    );
  }
}
