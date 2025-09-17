import 'dart:io';
import 'package:flutter/foundation.dart';
import '../../domain/use_cases/upload_feed_usecase.dart';
import '../../data/datasource/remote_api_service.dart';
import '../../data/repositories/add_feed_repository_impl.dart';
import '../../core/storage_service.dart';
import '../providers/home_provider.dart';
enum AddFeedState { initial, loading, success, error }

class AddFeedProvider extends ChangeNotifier {
  final UploadFeedUseCase uploadUseCase;
  final StorageService storage;
  AddFeedState _state = AddFeedState.initial;
  String? _errorMessage;

  String? videoPath;
  String? imagePath;
  String description = '';
  List<int> selectedCategoryIds = [];

  AddFeedProvider({required this.uploadUseCase, required this.storage});

  AddFeedState get state => _state;
  String? get errorMessage => _errorMessage;
  bool get loading => _state == AddFeedState.loading;

  void setVideo(String path) {
    videoPath = path;
    notifyListeners();
  }

  void setImage(String path) {
    imagePath = path;
    notifyListeners();
  }

  void setDescription(String desc) {
    description = desc;
    notifyListeners();
  }

  void toggleCategory(int id) {
    if (selectedCategoryIds.contains(id)) {
      selectedCategoryIds.remove(id);
    } else {
      selectedCategoryIds.add(id);
    }
    notifyListeners();
  }

  bool validate() {
    if (videoPath == null || videoPath!.isEmpty) {
      _errorMessage = 'Please select a video';
      return false;
    }
    if (imagePath == null || imagePath!.isEmpty) {
      _errorMessage = 'Please select a thumbnail image';
      return false;
    }
    if (description.trim().isEmpty) {
      _errorMessage = 'Please enter a description';
      return false;
    }
    if (selectedCategoryIds.isEmpty) {
      _errorMessage = 'Please select at least one category';
      return false;
    }
    _errorMessage = null;
    return true;
  }

  Future<void> upload() async {
    if (!validate()) {
      _state = AddFeedState.error;
      notifyListeners();
      return;
    }

    _state = AddFeedState.loading;
    notifyListeners();

    try {
      final res = await uploadUseCase.upload(
        videoPath: videoPath!,
        imagePath: imagePath!,
        desc: description.trim(),
        categories: selectedCategoryIds,
      );
      _state = AddFeedState.success;
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _state = AddFeedState.error;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  void reset() {
    _state = AddFeedState.initial;
    _errorMessage = null;
    videoPath = null;
    imagePath = null;
    description = '';
    selectedCategoryIds = [];
    notifyListeners();
  }
}
