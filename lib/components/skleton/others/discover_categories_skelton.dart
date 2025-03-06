import 'package:flutter/material.dart';

import '../../../constants.dart';
import '../skelton.dart';

class DiscoverActivitiesSkelton extends StatelessWidget {
  const DiscoverActivitiesSkelton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 10,
      itemBuilder: (context, index) => const DiscoverActivitySkelton(),
    );
  }
}

class DiscoverActivitySkelton extends StatelessWidget {
  const DiscoverActivitySkelton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(
          horizontal: defaultPadding, vertical: defaultPadding * 0.75),
      child: Row(
        children: [
          Skeleton(
            height: 32,
            width: 32,
            radious: 8,
          ),
          SizedBox(width: defaultPadding),
          Expanded(
            flex: 2,
            child: Skeleton(),
          ),
          Spacer(),
        ],
      ),
    );
  }
}
