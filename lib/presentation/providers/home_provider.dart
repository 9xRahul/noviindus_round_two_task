import 'package:flutter/foundation.dart';
import 'package:noviindus_round_two_task/domain/use_cases/get_home_feed_usecase.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/entities/feed_entity.dart';
import '../../domain/use_cases/get_categories_usecase.dart';

enum HomeState { initial, loading, loaded, error }

class HomeProvider extends ChangeNotifier {
  final GetCategoriesUseCase getCategoriesUseCase;
  final GetHomeFeedsUseCase getHomeFeedsUseCase;

  HomeState _state = HomeState.initial;
  String? _error;
  List<CategoryEntity> categories = [];
  List<FeedEntity> feeds = [];

  int? playingFeedId;

  HomeProvider({
    required this.getCategoriesUseCase,
    required this.getHomeFeedsUseCase,
  });

  HomeState get state {
    return _state;
  }

  String? get error {
    return _error;
  }

  bool get loading {
    if (_state == HomeState.loading) {
      return true;
    } else {
      return false;
    }
  }

  Future<void> loadAll() async {
    _setState(HomeState.loading);
    try {
      print("Loading categories...");
      var cats = await getCategoriesUseCase.fetchCategories();
      categories = cats;

      print("Loading feeds...");
      var f = await getHomeFeedsUseCase.getFeeds();
      feeds = f;

      _setState(HomeState.loaded);
      print("Loaded categories and feeds");
    } catch (e) {
      print("Error while loading: $e");
      _error = e.toString();
      _setState(HomeState.error);
    }
  }

  void setPlayingFeed(int? feedId) {
    print("setPlayingFeed called with $feedId");
    if (feedId == null) {
      playingFeedId = null;
    } else {
      playingFeedId = feedId;
    }
    notifyListeners();
  }

  void _setState(HomeState s) {
    _state = s;
    notifyListeners();
  }
}
