import '../../domain/entities/category_entity.dart';
import '../../core/constants.dart';

class CategoryModel extends CategoryEntity {
  CategoryModel({required int id, required String title, required String image})
    : super(id: id, title: title, image: image);

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    final raw = json['image'] as String? ?? '';
    final imageUrl = "";
    return CategoryModel(
      id: json['id'] as int,
      title: (json['title'] as String?) ?? '',
      image: imageUrl,
    );
  }
}
