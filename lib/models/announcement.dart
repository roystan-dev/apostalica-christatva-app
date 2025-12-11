class Announcement {
  final int id;
  final String? imageUrl;
  final String? linkUrl;
  final String? buttonText;
  final int delaySeconds;
  final int maxViews;
  final int? buttonColor;

  Announcement({
    required this.id,
    this.imageUrl,
    this.linkUrl,
    this.buttonText,
    required this.delaySeconds,
    required this.maxViews,
    this.buttonColor,
  });

  factory Announcement.fromJson(Map<String, dynamic> json) {
    return Announcement(
      id: json["id"],
      imageUrl: json["image_url"],
      linkUrl: json["link_url"],
      buttonText: json["button_text"],
      delaySeconds: json["delay_seconds"],
      maxViews: json["max_views"],
      buttonColor: json["button_color"] != null
          ? int.tryParse(json["button_color"])
          : null,
    );
  }
}
