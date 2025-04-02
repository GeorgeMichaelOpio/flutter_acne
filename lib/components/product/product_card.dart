import 'package:flutter/material.dart';

import '../../constants.dart';
import '../network_image_with_loader.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.image,
    required this.brandName,
    required this.title,
    this.spots,
    required this.press,
  });

  final String image, brandName, title;
  final int? spots;
  final VoidCallback press;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: press,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(140, 160), // Reduced height from 180 to 160
        maximumSize: const Size(140, 160), // Reduced height from 180 to 160
        padding: const EdgeInsets.all(0),
        side: BorderSide(color: Colors.grey.shade200, width: 1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(defaultBorderRadious),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 0.85, // Slightly taller image area
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(defaultBorderRadious)),
                  child: NetworkImageWithLoader(image, radius: 0),
                ),
                if (spots != null && spots! > 0)
                  Positioned(
                    right: defaultPadding / 2,
                    top: defaultPadding / 2,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: defaultPadding / 2),
                      height: 20,
                      decoration: BoxDecoration(
                        color: errorColor,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 2,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          "$spots spots",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: defaultPadding / 2,
              vertical: defaultPadding / 3,
            ),
            child: SizedBox(
              width: double.infinity, // This makes the Column take full width
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.center, // Center children horizontally
                mainAxisSize: MainAxisSize.min, // Minimize vertical space
                children: [
                  SizedBox(
                    width: double.infinity, // Make Text take full width
                    child: Text(
                      brandName.toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign
                          .center, // Center text within available space
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                            fontSize: 10,
                            color: Colors.grey.shade600,
                            letterSpacing: 0.8,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  SizedBox(
                    width: double.infinity, // Make Text take full width
                    child: Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign
                          .center, // Center text within available space
                      style: Theme.of(context).textTheme.titleSmall!.copyWith(
                            fontSize: 12,
                            height: 1.2,
                            fontWeight: FontWeight.w600,
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white
                                    : Colors.black,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
