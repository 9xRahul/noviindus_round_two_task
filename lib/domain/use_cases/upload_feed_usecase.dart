import '../../data/repositories/add_feed_repository_impl.dart';

class UploadFeedUseCase {
  final AddFeedRepositoryImpl repository;

  UploadFeedUseCase({required this.repository});

  Future<Map<String, dynamic>> upload({
    required String videoPath,
    required String imagePath,
    required String desc,
    required List<int> categories,
  }) {
    return repository.uploadFeed(
      videoPath: videoPath,
      imagePath: imagePath,
      desc: desc,
      categories: categories,
    );
  }
}
