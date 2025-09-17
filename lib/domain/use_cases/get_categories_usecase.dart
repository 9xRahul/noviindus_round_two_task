import '../entities/category_entity.dart';
import '../repositories/home_repository.dart';

class GetCategoriesUseCase {
  final HomeRepository repository;
  GetCategoriesUseCase({required this.repository});

  Future<List<CategoryEntity>> fetchCategories() =>
      repository.fetchCategories();
}
