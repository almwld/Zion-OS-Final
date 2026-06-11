import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class GalleryApp extends StatefulWidget {
  const GalleryApp({super.key});

  @override
  State<GalleryApp> createState() => _GalleryAppState();
}

class _GalleryAppState extends State<GalleryApp> {
  final List<Map<String, dynamic>> _photos = [];
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;
  int _selectedCategory = 0;
  
  final List<String> _categories = ['All', 'Camera', 'Screenshots', 'Downloads', 'Albums'];
  
  // Simulated albums
  final List<Map<String, dynamic>> _albums = [
    {'name': 'Camera', 'count': 24, 'icon': Icons.camera_alt},
    {'name': 'Screenshots', 'count': 12, 'icon': Icons.screenshot},
    {'name': 'Downloads', 'count': 8, 'icon': Icons.download},
    {'name': 'Wallpapers', 'count': 15, 'icon': Icons.wallpaper},
    {'name': 'Social', 'count': 32, 'icon': Icons.people},
    {'name': 'Travel', 'count': 18, 'icon': Icons.flight},
  ];

  // Simulated photos (for demo)
  final List<Map<String, dynamic>> _demoPhotos = [
    {'name': 'IMG_20241201.jpg', 'size': '2.5 MB', 'date': '2024-12-01'},
    {'name': 'IMG_20241130.jpg', 'size': '1.8 MB', 'date': '2024-11-30'},
    {'name': 'IMG_20241129.jpg', 'size': '3.2 MB', 'date': '2024-11-29'},
    {'name': 'Screenshot_20241201.png', 'size': '0.5 MB', 'date': '2024-12-01'},
    {'name': 'IMG_20241128.jpg', 'size': '2.1 MB', 'date': '2024-11-28'},
    {'name': 'IMG_20241127.jpg', 'size': '4.0 MB', 'date': '2024-11-27'},
    {'name': 'IMG_20241126.jpg', 'size': '1.5 MB', 'date': '2024-11-26'},
    {'name': 'Screenshot_20241130.png', 'size': '0.8 MB', 'date': '2024-11-30'},
  ];

  @override
  void initState() {
    super.initState();
    _loadPhotos();
  }

  void _loadPhotos() {
    setState(() {
      _photos.addAll(_demoPhotos);
    });
  }

  Future<void> _takePhoto() async {
    try {
      final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
      if (photo != null) {
        setState(() {
          _photos.insert(0, {
            'name': photo.name,
            'size': 'New',
            'date': DateTime.now().toIso8601String().substring(0, 10),
            'path': photo.path,
          });
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Photo captured'), backgroundColor: Color(0xFF00BCD4)),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Camera not available'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _photos.insert(0, {
            'name': image.name,
            'size': 'New',
            'date': DateTime.now().toIso8601String().substring(0, 10),
            'path': image.path,
          });
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Image added'), backgroundColor: Color(0xFF00BCD4)),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to pick image'), backgroundColor: Colors.red),
      );
    }
  }

  void _deletePhoto(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Photo', style: TextStyle(color: Color(0xFF00BCD4))),
        content: const Text('Are you sure you want to delete this photo?', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel', style: TextStyle(color: Colors.white54))),
          TextButton(
            onPressed: () {
              setState(() {
                _photos.removeAt(index);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Photo deleted'), backgroundColor: Color(0xFF00BCD4)),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _viewPhoto(Map<String, dynamic> photo) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 300,
                decoration: BoxDecoration(
                  color: const Color(0xFF00BCD4).withOpacity(0.1),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: const Center(
                  child: Icon(Icons.image, size: 80, color: Color(0xFF00BCD4)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(photo['name'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('Size: ${photo['size']} • Date: ${photo['date']}', style: const TextStyle(color: Colors.white54, fontSize: 12)),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close),
                          label: const Text('Close'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00BCD4),
                            foregroundColor: Colors.black,
                          ),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton.icon(
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: photo['name']));
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Name copied'), backgroundColor: Color(0xFF00BCD4)),
                            );
                          },
                          icon: const Icon(Icons.copy),
                          label: const Text('Copy Name'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[800],
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Gallery', style: TextStyle(color: Color(0xFF00BCD4))),
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF00BCD4)),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.camera_alt, color: Color(0xFF00BCD4)),
            onPressed: _takePhoto,
            tooltip: 'Take photo',
          ),
          IconButton(
            icon: const Icon(Icons.photo_library, color: Color(0xFF00BCD4)),
            onPressed: _pickImage,
            tooltip: 'Pick from gallery',
          ),
        ],
      ),
      body: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            // Categories
            Container(
              height: 45,
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final isSelected = _selectedCategory == index;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedCategory = index),
                    child: Container(
                      margin: const EdgeInsets.only(right: 12),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF00BCD4) : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? Colors.transparent : const Color(0xFF00BCD4).withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        _categories[index],
                        style: TextStyle(
                          color: isSelected ? Colors.black : const Color(0xFF00BCD4),
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            
            // Albums Section (when selected)
            if (_selectedCategory == 4)
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1.2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: _albums.length,
                  itemBuilder: (context, index) {
                    final album = _albums[index];
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFF00BCD4).withOpacity(0.3)),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(album['icon'], color: const Color(0xFF00BCD4), size: 48),
                          const SizedBox(height: 12),
                          Text(
                            album['name'],
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '${album['count']} items',
                            style: const TextStyle(color: Colors.white54, fontSize: 12),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            
            // Photos Grid
            if (_selectedCategory != 4)
              Expanded(
                child: _photos.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.photo_library, size: 64, color: Colors.white24),
                            SizedBox(height: 16),
                            Text('No photos yet', style: TextStyle(color: Colors.white38)),
                            SizedBox(height: 8),
                            Text('Tap camera icon to take a photo', style: TextStyle(color: Colors.white24, fontSize: 12)),
                          ],
                        ),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: 1,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                        ),
                        itemCount: _photos.length,
                        itemBuilder: (context, index) {
                          final photo = _photos[index];
                          return GestureDetector(
                            onTap: () => _viewPhoto(photo),
                            onLongPress: () => _deletePhoto(index),
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF00BCD4), Color(0xFF006064)],
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Stack(
                                children: [
                                  const Center(
                                    child: Icon(Icons.image, color: Colors.white, size: 32),
                                  ),
                                  Positioned(
                                    bottom: 4,
                                    right: 4,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.6),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        photo['name'].split('.').last.toUpperCase(),
                                        style: const TextStyle(color: Colors.white70, fontSize: 8),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
          ],
        ),
      ),
    );
  }
}
