import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '/components/product/product_card.dart';
import '/route/route_constants.dart';
import '../../../auth_provider.dart';
import '../../../scan_provider.dart';
import '../../../constants.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch scans when the widget initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final scanProvider = Provider.of<ScanProvider>(context, listen: false);
      if (authProvider.isAuthenticated && scanProvider.scans.isEmpty) {
        scanProvider.fetchUserScans(authProvider.user!.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final scanProvider = Provider.of<ScanProvider>(context);
    Provider.of<AuthProvider>(context);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          if (scanProvider.isLoading && scanProvider.scans.isEmpty)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            ),
          if (scanProvider.error ==
              "Network error. Please check your internet connection")
            SliverFillRemaining(
              child: _ErrorWidget(
                  error:
                      "Network error. Please check your internet connection"),
            ),
          if (scanProvider.error == "No scans found for this user")
            SliverFillRemaining(
              child: _EmptyScansWidget(),
            ),
          if (!scanProvider.isLoading &&
              scanProvider.scans.isEmpty &&
              scanProvider.error.isEmpty)
            const SliverFillRemaining(
              child: Center(
                child: Text('No scan history found'),
              ),
            ),
          if (scanProvider.scans.isNotEmpty)
            SliverPadding(
              padding: const EdgeInsets.symmetric(
                horizontal: defaultPadding,
                vertical: defaultPadding,
              ),
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
                      image: scanProvider.scans[index].scannedImageUrl,
                      brandName: DateFormat('yyyy-MM-dd')
                          .format(scanProvider.scans[index].createdAt),
                      title: jsonDecode(
                          scanProvider.scans[index].prediction)['label'],
                      spots: scanProvider.scans[index].spots,
                      press: () {
                        Navigator.pushNamed(
                          context,
                          productDetailsScreenRoute,
                          arguments: {
                            'scanData': {
                              'id': scanProvider.scans[index].id,
                              'fileInfo': {
                                'url1':
                                    scanProvider.scans[index].originalImageUrl,
                                'url2':
                                    scanProvider.scans[index].scannedImageUrl
                              },
                              'prediction': jsonDecode(
                                  scanProvider.scans[index].prediction),
                              'spots': scanProvider.scans[index].spots,
                              'report': scanProvider.scans[index].report,
                            },
                          },
                        );
                      },
                    );
                  },
                  childCount: scanProvider.scans.length,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ErrorWidget extends StatelessWidget {
  final String error;

  const _ErrorWidget({required this.error});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.redAccent, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.red.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.redAccent, size: 40),
            const SizedBox(height: 10),
            Text(
              'Oops! Something went wrong',
              style: TextStyle(
                color: Colors.redAccent,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: const TextStyle(color: Colors.black54, fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyScansWidget extends StatelessWidget {
  const _EmptyScansWidget();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 250,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.folder_off,
            size: 60,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No scans found',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade700,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start a new scan to see results here.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade500,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
