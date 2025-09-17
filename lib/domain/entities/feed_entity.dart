class FeedEntity {
  final int id;
  final String description;
  final String thumbnail;
  final String video;
  final int? userId;
  final String? userName;
  final String? userImage;

  FeedEntity({
    required this.id,
    required this.description,
    required this.thumbnail,
    required this.video,
    this.userId,
    this.userName,
    this.userImage,
  });
}
