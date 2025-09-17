import '../../domain/entities/feed_entity.dart';

class FeedModel extends FeedEntity {
  FeedModel({
    required int id,
    required String description,
    required String thumbnail,
    required String video,
    int? userId,
    String? userName,
    String? userImage,
  }) : super(
         id: id,
         description: description,
         thumbnail: thumbnail,
         video: video,
         userId: userId,
         userName: userName,
         userImage: userImage,
       );

  factory FeedModel.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>?;
    final image = (json['image'] as String?) ?? '';
    return FeedModel(
      id: json['id'] as int,
      description: (json['description'] as String?) ?? '',
      thumbnail: image,
      video: (json['video'] as String?) ?? '',
      userId: user != null ? (user['id'] as int?) : null,
      userName: user != null ? (user['name'] as String?) : null,
      userImage: user != null ? (user['image'] as String?) : null,
    );
  }
}
