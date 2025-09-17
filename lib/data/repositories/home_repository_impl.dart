import '../../domain/entities/category_entity.dart';
import '../../domain/entities/feed_entity.dart';
import '../../domain/repositories/home_repository.dart';
import '../models/category_model.dart';
import '../models/feed_model.dart';
import '../datasource/remote_api_service.dart';

class HomeRepositoryImpl implements HomeRepository {
  final RemoteApiService api;

  HomeRepositoryImpl({required this.api});

  @override
  Future<List<CategoryEntity>> fetchCategories() async {
    final res = await api.getJson('category_list');

    final list = (res['categories'] as List<dynamic>?) ?? [];
    return list
        .map((e) => CategoryModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<FeedEntity>> fetchHomeFeeds() async {
    final res = await api.getJson('home');
    final list = (res['results'] as List<dynamic>?) ?? [];
    return list
        .map((e) => FeedModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
