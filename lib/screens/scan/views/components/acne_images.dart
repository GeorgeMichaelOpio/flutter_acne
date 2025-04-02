import 'dart:io';

import 'package:flutter/material.dart';
import '/components/network_image_with_loader.dart';

import '../../../../constants.dart';

class AcneImages extends StatefulWidget {
  const AcneImages({
    super.key,
    required this.images,
  });

  final List<String> images;

  @override
  State<AcneImages> createState() => _AcneImagesState();
}

class _AcneImagesState extends State<AcneImages> {
  late PageController _controller;

  int _currentPage = 0;

  @override
  void initState() {
    _controller =
        PageController(viewportFraction: 0.9, initialPage: _currentPage);
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool isUrl(String path) {
    return Uri.tryParse(path)?.hasScheme ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: AspectRatio(
        aspectRatio: 1,
        child: Stack(
          children: [
            PageView.builder(
              controller: _controller,
              onPageChanged: (pageNum) {
                setState(() {
                  _currentPage = pageNum;
                });
              },
              itemCount: widget.images.length,
              itemBuilder: (context, index) {
                final imagePath = widget.images[index];

                return Padding(
                  padding: const EdgeInsets.only(right: defaultPadding),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.all(
                      Radius.circular(defaultBorderRadious * 2),
                    ),
                    child: isUrl(imagePath)
                        ? NetworkImageWithLoader(imagePath)
                        : Image.file(File(imagePath), fit: BoxFit.cover),
                  ),
                );
              },
            ),
            if (widget.images.length > 1)
              Positioned(
                height: 20,
                bottom: 24,
                right: MediaQuery.of(context).size.width * 0.15,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: defaultPadding * 0.75,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    borderRadius: const BorderRadius.all(Radius.circular(50)),
                  ),
                  child: Row(
                    children: List.generate(
                      widget.images.length,
                      (index) => Padding(
                        padding: EdgeInsets.only(
                            right: index == (widget.images.length - 1)
                                ? 0
                                : defaultPadding / 4),
                        child: CircleAvatar(
                          radius: 3,
                          backgroundColor: Theme.of(context)
                              .textTheme
                              .bodyLarge!
                              .color!
                              .withOpacity(index == _currentPage ? 1 : 0.2),
                        ),
                      ),
                    ),
                  ),
                ),
              )
          ],
        ),
      ),
    );
  }
}
