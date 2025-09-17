import '../entities/feed_entity.dart';
import '../repositories/home_repository.dart';

class GetHomeFeedsUseCase {
  final HomeRepository repository;
  GetHomeFeedsUseCase({required this.repository});

  Future<List<FeedEntity>> getFeeds() => repository.fetchHomeFeeds();
}
