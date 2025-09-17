import '../entities/category_entity.dart';
import '../entities/feed_entity.dart';

abstract class HomeRepository {
  Future<List<CategoryEntity>> fetchCategories();
  Future<List<FeedEntity>> fetchHomeFeeds();
}
