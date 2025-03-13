import 'package:animations/animations.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '/constants.dart';
import '/route/screen_export.dart';
import 'theme/provider/theme_provider.dart';

class EntryPoint extends StatefulWidget {
  const EntryPoint({super.key});

  @override
  State<EntryPoint> createState() => _EntryPointState();
}

class _EntryPointState extends State<EntryPoint> {
  List<CameraDescription> cameras = [];
  CameraDescription? firstCamera;

  @override
  void initState() {
    super.initState();
    initializeCameras();
  }

  Future<void> initializeCameras() async {
    cameras = await availableCameras();
    firstCamera = cameras.first;
    setState(() {});
  }

  final List _pages = const [
    HomeScreen(),
    HistoryScreen(),
    ProfileScreen(),
  ];
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    SvgPicture svgIcon(String src, {Color? color}) {
      return SvgPicture.asset(
        src,
        height: 24,
        colorFilter: ColorFilter.mode(
            color ?? Colors.grey, // Default unselected color
            BlendMode.srcIn),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        leading: const SizedBox(),
        leadingWidth: 0,
        centerTitle: false,
        title: SvgPicture.asset(
          "assets/logo/acne.svg",
          colorFilter: ColorFilter.mode(
              Theme.of(context).iconTheme.color!, BlendMode.srcIn),
          height: 50,
          width: 200,
        ),
        actions: [
          IconButton(
            onPressed: () => Navigator.pushNamed(
              context,
              cameraScreenRoute,
              arguments: <String, dynamic>{
                'cameras': cameras,
                'initialCamera': firstCamera,
              },
            ),
            icon: SvgPicture.asset(
              "assets/icons/scan.svg",
              height: 24,
              colorFilter: ColorFilter.mode(
                  Theme.of(context).textTheme.bodyLarge!.color!,
                  BlendMode.srcIn),
            ),
          ),
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, _) {
              return IconButton(
                icon: Icon(
                  themeProvider.isDark ? Icons.light_mode : Icons.dark_mode,
                  color: Theme.of(context).iconTheme.color,
                ),
                onPressed: () => themeProvider.toggleTheme(),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Scrollable content area
          Positioned.fill(
            child: PageTransitionSwitcher(
              duration: defaultDuration,
              transitionBuilder: (child, animation, secondAnimation) {
                return FadeThroughTransition(
                  animation: animation,
                  secondaryAnimation: secondAnimation,
                  child: child,
                );
              },
              child: _pages[_currentIndex],
            ),
          ),

          // Floating navigation bar
          Positioned(
            left: 50,
            right: 50,
            bottom: 20,
            child: Consumer<ThemeProvider>(// Wrap with Consumer
                builder: (context, themeProvider, _) {
              return Container(
                decoration: BoxDecoration(
                  color: themeProvider.isDark ? Colors.black : Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: BottomNavigationBar(
                    currentIndex: _currentIndex,
                    onTap: (index) => setState(() => _currentIndex = index),
                    type: BottomNavigationBarType.fixed,
                    selectedItemColor: primaryColor,
                    unselectedItemColor: Colors.grey,
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    selectedFontSize: 12,
                    items: [
                      BottomNavigationBarItem(
                        icon: svgIcon("assets/icons/home.svg",
                            color: Colors.grey),
                        activeIcon: svgIcon("assets/icons/home.svg",
                            color: primaryColor),
                        label: "Home",
                      ),
                      BottomNavigationBarItem(
                        icon: svgIcon("assets/icons/history.svg",
                            color: Colors.grey),
                        activeIcon: svgIcon("assets/icons/history.svg",
                            color: primaryColor),
                        label: "History",
                      ),
                      BottomNavigationBarItem(
                        icon: svgIcon("assets/icons/Profile.svg",
                            color: Colors.grey),
                        activeIcon: svgIcon("assets/icons/Profile.svg",
                            color: primaryColor),
                        label: "Profile",
                      ),
                    ],
                  ),
                ),
              );
            }),
          )
        ],
      ),
    );
  }
}
