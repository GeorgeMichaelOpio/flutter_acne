import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '/route/screen_export.dart';

import '../../../../constants.dart';

// For preview
class ActivityModel {
  final String name;
  final String? svgSrc, route;

  ActivityModel({
    required this.name,
    this.svgSrc,
    this.route,
  });
}

List<ActivityModel> demoActivities = [
  ActivityModel(name: "Scan", svgSrc: "assets/icons/scan.svg"),
  ActivityModel(name: "Previous Scans", svgSrc: "assets/icons/history.svg"),
];

class Activities extends StatelessWidget {
  const Activities({
    super.key,
  });

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
                  right:
                      index == demoActivities.length - 1 ? defaultPadding : 0),
              child: ActivityBtn(
                activitivities: demoActivities[index].name,
                svgSrc: demoActivities[index].svgSrc,
                isActive: index == 0,
                press: () {
                  if (demoActivities[index].route != null) {
                    Navigator.pushNamed(context, demoActivities[index].route!);
                  }
                },
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
    required this.activitivities,
    this.svgSrc,
    required this.isActive,
    required this.press,
  });

  final String activitivities;
  final String? svgSrc;
  final bool isActive;
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
              activitivities,
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
