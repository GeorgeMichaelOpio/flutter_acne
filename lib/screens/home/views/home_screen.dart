import 'package:flutter/material.dart';
import 'components/offer_carousel_and_activities.dart';
import 'components/recent_scans.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            const SliverToBoxAdapter(child: OffersCarouselAndActivities()),
            const SliverToBoxAdapter(child: RecentScans()),
          ],
        ),
      ),
    );
  }
}
