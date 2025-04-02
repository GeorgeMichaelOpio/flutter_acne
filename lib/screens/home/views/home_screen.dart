import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../components/graph/graph.dart';
import '../../../scan_provider.dart';
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
            SliverToBoxAdapter(
              child: SpotsChart(
                scans: Provider.of<ScanProvider>(context, listen: false).scans,
              ),
            ),
            const SliverToBoxAdapter(child: RecentScans()),
          ],
        ),
      ),
    );
  }
}
