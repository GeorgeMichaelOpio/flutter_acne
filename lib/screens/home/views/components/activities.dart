import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '/route/screen_export.dart';
import '../../../../constants.dart';

class ActivityModel {
  final String name;
  final String? svgSrc;
  final Function(BuildContext)? press;

  ActivityModel({
    required this.name,
    this.svgSrc,
    this.press,
  });
}

final List<ActivityModel> demoActivities = [
  ActivityModel(
    name: "Scan",
    svgSrc: "assets/icons/scan.svg",
    press: (BuildContext context) async {
      print("Scan");
      try {
        final cameras = await availableCameras();
        final firstCamera = cameras.first;
        Navigator.pushNamed(
          context,
          cameraScreenRoute,
          arguments: <String, dynamic>{
            'cameras': cameras,
            'initialCamera': firstCamera,
          },
        );
      } catch (e) {
        print("Error getting cameras: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Could not access camera: $e")),
        );
      }
    },
  ),
  ActivityModel(
    name: "Previous Scans",
    svgSrc: "assets/icons/history.svg",
    press: (BuildContext context) {
      // Add navigation for previous scans here if needed
      print("Previous Scans pressed");
    },
  ),
];

class Activities extends StatelessWidget {
  const Activities({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          ...List.generate(
            demoActivities.length,
            (index) => Padding(
              padding: EdgeInsets.only(
                left: index == 0 ? defaultPadding : defaultPadding / 2,
                right: index == demoActivities.length - 1 ? defaultPadding : 0,
              ),
              child: ActivityBtn(
                activity: demoActivities[index].name,
                svgSrc: demoActivities[index].svgSrc,
                press: () => demoActivities[index].press?.call(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ActivityBtn extends StatelessWidget {
  const ActivityBtn({
    super.key,
    required this.activity,
    this.svgSrc,
    required this.press,
  });

  final String activity;
  final String? svgSrc;
  final VoidCallback press;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: press,
      borderRadius: const BorderRadius.all(Radius.circular(30)),
      child: Container(
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
        decoration: BoxDecoration(
          color: Colors.transparent,
          border: Border.all(color: Theme.of(context).dividerColor),
          borderRadius: const BorderRadius.all(Radius.circular(30)),
        ),
        child: Row(
          children: [
            if (svgSrc != null)
              SvgPicture.asset(
                svgSrc!,
                height: 20,
                colorFilter: ColorFilter.mode(
                  Theme.of(context).iconTheme.color!,
                  BlendMode.srcIn,
                ),
              ),
            if (svgSrc != null) const SizedBox(width: defaultPadding / 2),
            Text(
              activity,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).textTheme.bodyLarge!.color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
