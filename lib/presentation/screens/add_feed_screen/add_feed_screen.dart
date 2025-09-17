import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:noviindus_round_two_task/core/constants.dart';
import 'package:provider/provider.dart';

import '../../providers/add_feed_provider.dart';
import '../../../data/datasource/remote_api_service.dart';

import '../../../domain/entities/category_entity.dart';

import '../../../core/storage_service.dart';

class AddFeedScreen extends StatefulWidget {
  const AddFeedScreen({Key? key}) : super(key: key);

  @override
  State<AddFeedScreen> createState() {
    return _AddFeedScreenState();
  }
}

class _AddFeedScreenState extends State<AddFeedScreen> {
  final ImagePicker _picker = ImagePicker();
  List<CategoryEntity> _allCategories = <CategoryEntity>[];
  bool _loadingCategories = true;
  String? _categoriesError;

  late RemoteApiService _api;
  late StorageService _storage;

  static const double _videoPreviewHeight = 220.0;
  static const double _imagePreviewHeight = 120.0;

  @override
  void initState() {
    super.initState();
    _api = RemoteApiService();
    _storage = StorageService();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    setState(() {
      _loadingCategories = true;
      _categoriesError = null;
    });

    try {
      final Map<String, dynamic> res = await _api.getJson('category_list');
      final List<dynamic> raw =
          (res['categories'] as List<dynamic>?) ?? <dynamic>[];
      final List<CategoryEntity> list = raw.map((dynamic e) {
        final Map<String, dynamic> m = e as Map<String, dynamic>;
        final int id = m['id'] as int;
        final String title = (m['title'] as String?) ?? '';
        String image = "";
        return CategoryEntity(id: id, title: title, image: image);
      }).toList();

      setState(() {
        _allCategories = list;
        _loadingCategories = false;
      });
    } catch (e) {
      setState(() {
        _categoriesError = e.toString();
        _loadingCategories = false;
      });
    }
  }

  Future<void> _pickVideo() async {
    final XFile? picked = await _picker.pickVideo(source: ImageSource.gallery);
    if (picked != null) {
      Provider.of<AddFeedProvider>(
        context,
        listen: false,
      ).setVideo(picked.path);

      FocusScope.of(context).unfocus();
      setState(() {});
    }
  }

  Future<void> _pickImage() async {
    final XFile? picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      Provider.of<AddFeedProvider>(
        context,
        listen: false,
      ).setImage(picked.path);
      FocusScope.of(context).unfocus();
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final AddFeedProvider provider = Provider.of<AddFeedProvider>(context);

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: BackButton(),
          title: Text('Add Feeds'),
          actions: [
            TextButton(
              onPressed: provider.loading
                  ? null
                  : () async {
                      FocusScope.of(context).unfocus();
                      await provider.upload();
                      if (provider.state == AddFeedState.success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Uploaded successfully')),
                        );

                        provider.reset();
                        Navigator.pop(context);
                      } else if (provider.state == AddFeedState.error) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Upload failed: ${provider.errorMessage}',
                            ),
                          ),
                        );
                      }
                    },
              child: provider.loading
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text('Share Post', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: _pickVideo,
                child: Container(
                  height: _videoPreviewHeight,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.grey.shade700,
                      style: BorderStyle.solid,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: _buildVideoPreview(provider),
                ),
              ),
              const SizedBox(height: 12),

              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: _imagePreviewHeight,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade700),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: _buildImagePreview(provider),
                ),
              ),
              const SizedBox(height: 16),

              Text(
                'Add Description',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              const SizedBox(height: 8),
              TextField(
                maxLines: 4,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Write description...',
                  hintStyle: TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: Colors.black,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade700),
                  ),
                ),
                onChanged: (String v) {
                  Provider.of<AddFeedProvider>(
                    context,
                    listen: false,
                  ).setDescription(v);
                },
              ),
              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Categories',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  TextButton(
                    onPressed: _fetchCategories,
                    child: Text(
                      'Refresh',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              if (_loadingCategories)
                Center(child: CircularProgressIndicator())
              else if (_categoriesError != null)
                Text(
                  'Failed to load categories: $_categoriesError',
                  style: TextStyle(color: Colors.red),
                )
              else
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _allCategories.map((CategoryEntity c) {
                    final bool selected = provider.selectedCategoryIds.contains(
                      c.id,
                    );
                    return GestureDetector(
                      onTap: () {
                        provider.toggleCategory(c.id);
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: selected ? Colors.red : Colors.grey.shade900,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.grey.shade700),
                        ),
                        child: Text(
                          c.title,
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    );
                  }).toList(),
                ),

              const SizedBox(height: 24),

              if (provider.state == AddFeedState.error &&
                  provider.errorMessage != null)
                Text(
                  provider.errorMessage!,
                  style: TextStyle(color: Colors.red),
                ),

              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVideoPreview(AddFeedProvider provider) {
    if (provider.videoPath == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.video_collection, size: 36, color: Colors.grey),
            const SizedBox(height: 8),
            Text(
              'Select a video from Gallery',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    final File videoFile = File(provider.videoPath!);
    final String fileName = videoFile.path.split(Platform.pathSeparator).last;

    return Stack(
      alignment: Alignment.center,
      children: [
        Positioned.fill(child: Container(color: Colors.grey.shade900)),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.videocam, size: 40, color: Colors.white70),
            const SizedBox(height: 8),
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 300),
              child: Container(
                width: 300,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                ),

                child: Text(
                  fileName,
                  style: TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildImagePreview(AddFeedProvider provider) {
    if (provider.imagePath == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.image, size: 28, color: Colors.grey),
            const SizedBox(height: 6),
            Text('Add a Thumbnail', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    final File imageFile = File(provider.imagePath!);

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.file(
        imageFile,
        fit: BoxFit.cover,
        width: double.infinity,
        height: _imagePreviewHeight,
      ),
    );
  }
}
