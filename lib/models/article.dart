class Article {
  final int id;
  final String title;
  final String slug;
  final String description;
  final String content;
  final String author;
  final String date;
  final String? image;
  final String topicName;
  final String? topicDescription;

  Article({
    required this.id,
    required this.title,
    required this.slug,
    required this.description,
    required this.content,
    required this.author,
    required this.date,
    this.image,
    required this.topicName,
    this.topicDescription,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      id: int.parse(json['id'].toString()),
      title: json['title'] ?? '',
      slug: json['slug'] ?? '',
      description: json['description'] ?? '',
      content: json['content'] ?? '',
      author: json['author'] ?? '',
      date: json['date'] ?? '',
      image: json['image'],
      topicName: json['topic_name'] ?? '',
      topicDescription: json['topic_description'],
    );
  }
}
