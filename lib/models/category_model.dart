class ActivityModel {
  final String title;
  final String? image, svgSrc;
  final List<ActivityModel>? subActivities;

  ActivityModel({
    required this.title,
    this.image,
    this.svgSrc,
    this.subActivities,
  });
}

final List<ActivityModel> demoActivitiesWithImage = [
  ActivityModel(title: "Woman’s", image: "https://i.imgur.com/5M89G2P.png"),
  ActivityModel(title: "Man’s", image: "https://i.imgur.com/UM3GdWg.png"),
  ActivityModel(title: "Kid’s", image: "https://i.imgur.com/Lp0D6k5.png"),
  ActivityModel(title: "Accessories", image: "https://i.imgur.com/3mSE5sN.png"),
];

final List<ActivityModel> demoActivities = [
  ActivityModel(
    title: "On sale",
    svgSrc: "assets/icons/Sale.svg",
    subActivities: [
      ActivityModel(title: "All Clothing"),
      ActivityModel(title: "New In"),
      ActivityModel(title: "Coats & Jackets"),
      ActivityModel(title: "Dresses"),
      ActivityModel(title: "Jeans"),
    ],
  ),
  ActivityModel(
    title: "Man’s & Woman’s",
    svgSrc: "assets/icons/Man&Woman.svg",
    subActivities: [
      ActivityModel(title: "All Clothing"),
      ActivityModel(title: "New In"),
      ActivityModel(title: "Coats & Jackets"),
    ],
  ),
  ActivityModel(
    title: "Kids",
    svgSrc: "assets/icons/Child.svg",
    subActivities: [
      ActivityModel(title: "All Clothing"),
      ActivityModel(title: "New In"),
      ActivityModel(title: "Coats & Jackets"),
    ],
  ),
  ActivityModel(
    title: "Accessories",
    svgSrc: "assets/icons/Accessories.svg",
    subActivities: [
      ActivityModel(title: "All Clothing"),
      ActivityModel(title: "New In"),
    ],
  ),
];
