import 'package:flutter/material.dart';
import 'package:noviindus_round_two_task/data/datasource/remote_api_service.dart';
import 'package:noviindus_round_two_task/data/repositories/home_repository_impl.dart';
import 'package:noviindus_round_two_task/domain/entities/category_entity.dart';
import 'package:noviindus_round_two_task/domain/use_cases/get_categories_usecase.dart';
import 'package:noviindus_round_two_task/domain/use_cases/get_home_feed_usecase.dart';
import 'package:noviindus_round_two_task/presentation/providers/home_provider.dart';
import 'package:noviindus_round_two_task/presentation/screens/add_feed_screen/add_feed_screen.dart';
import 'package:noviindus_round_two_task/presentation/screens/home_screen/widgets/feed_card_widget.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final RemoteApiService api = RemoteApiService();
    final HomeRepositoryImpl homeRepo = HomeRepositoryImpl(api: api);
    final GetCategoriesUseCase categoriesUseCase = GetCategoriesUseCase(
      repository: homeRepo,
    );
    final GetHomeFeedsUseCase feedsUseCase = GetHomeFeedsUseCase(
      repository: homeRepo,
    );

    final HomeProvider homeProvider = HomeProvider(
      getCategoriesUseCase: categoriesUseCase,
      getHomeFeedsUseCase: feedsUseCase,
    );

    homeProvider.loadAll();

    return ChangeNotifierProvider<HomeProvider>(
      create: (BuildContext providerContext) {
        return homeProvider;
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: buildAppBar(),
        body: buildBody(),
        floatingActionButton: buildFloatingButton(ctx: context),
      ),
    );
  }

  PreferredSizeWidget buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: Column(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hello Maria',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              Text(
                'Welcome back to Section',
                style: TextStyle(color: Color(0xFFD5D5D5), fontSize: 12),
              ),
            ],
          ),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 12.0),
          child: CircleAvatar(
            radius: 18,
            backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=3'),
          ),
        ),
      ],
    );
  }

  Widget buildBody() {
    return Consumer<HomeProvider>(
      builder: (BuildContext context, HomeProvider home, Widget? child) {
        if (home.loading == true) {
          return Center(child: CircularProgressIndicator());
        }

        if (home.state == HomeState.error) {
          String errorText = 'Unknown error';
          if (home.error != null) {
            errorText = home.error!;
          }
          return Center(
            child: Text(
              'Error: $errorText',
              style: TextStyle(color: Colors.white),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildCategoryList(home.categories),
            buildFeedList(home.feeds),
          ],
        );
      },
    );
  }

  Widget buildCategoryList(List<CategoryEntity> categories) {
    return SizedBox(
      height: 56,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (BuildContext context, int index) {
          return const SizedBox(width: 8);
        },
        itemBuilder: (BuildContext context, int index) {
          final CategoryEntity cat = categories[index];
          return _Category(title: cat.title);
        },
      ),
    );
  }

  Widget buildFeedList(List feeds) {
    return Expanded(
      child: ListView.builder(
        itemCount: feeds.length,
        itemBuilder: (BuildContext context, int index) {
          final dynamic feed = feeds[index];

          return FeedCardWidget(feed: feed);
        },
      ),
    );
  }

  Widget buildFloatingButton({required BuildContext ctx}) {
    return SizedBox(
      width: 60,
      height: 60,
      child: FloatingActionButton(
        backgroundColor: Colors.red,
        shape: CircleBorder(),
        child: Icon(Icons.add, color: Colors.white, size: 28),
        onPressed: () {
          Navigator.of(
            ctx,
          ).push(MaterialPageRoute(builder: (ctx) => AddFeedScreen()));
        },
      ),
    );
  }
}

class _Category extends StatelessWidget {
  final String title;

  const _Category({required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: Text(title, style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
