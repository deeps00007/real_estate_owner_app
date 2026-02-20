import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/notification_service.dart';
import '../../core/firebase_service.dart';
import '../../core/imagekit_service.dart';

class SendNotificationScreen extends StatefulWidget {
  final String ownerId;

  const SendNotificationScreen({super.key, required this.ownerId});

  @override
  State<SendNotificationScreen> createState() => _SendNotificationScreenState();
}

class _SendNotificationScreenState extends State<SendNotificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  final _imageUrlController = TextEditingController();
  File? _imageFile;
  bool _isLoading = false;
  double _progress = 0.0;
  String _statusMessage = '';
  bool _isSending = false;
  // 'upload' = pick from gallery, 'url' = paste a URL
  String _imageMode = 'upload';

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      final file = File(picked.path);
      final sizeInBytes = await file.length();
      final sizeInMB = sizeInBytes / (1024 * 1024);

      if (sizeInMB > 1.5) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Image size must be less than 1.5MB'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      setState(() => _imageFile = file);
    }
  }

  Future<void> _sendBatchBroadcast() async {
    if (!_formKey.currentState!.validate()) return;

    // Hide keyboard
    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = true;
      _isSending = true;
      _progress = 0.0;
      _statusMessage = 'Preparing broadcast...';
    });

    try {
      String? imageUrl;
      // 1. Resolve image: upload file OR use URL directly
      if (_imageMode == 'upload' && _imageFile != null) {
        setState(() => _statusMessage = 'Uploading image...');
        final imageKitService = ImageKitService();
        imageUrl = await imageKitService.uploadImage(_imageFile!);
      } else if (_imageMode == 'url') {
        final url = _imageUrlController.text.trim();
        if (url.isNotEmpty) imageUrl = url;
      }

      setState(() => _statusMessage = 'Fetching users...');

      // 2. Fetch all users
      final users = await FirebaseService().getAllUsers();
      final totalUsers = users.length;

      if (totalUsers == 0) {
        throw 'No users found to broadcast to.';
      }

      setState(
        () => _statusMessage = 'Found $totalUsers users. Starting broadcast...',
      );

      int sentCount = 0;
      int successCount = 0;
      int failureCount = 0;

      // 3. Process in batches of 20
      const int batchSize = 20;
      for (var i = 0; i < totalUsers; i += batchSize) {
        if (!mounted) break;

        final end = (i + batchSize < totalUsers) ? i + batchSize : totalUsers;
        final batch = users.sublist(i, end);

        // Process batch concurrently
        final futures = batch.map((user) async {
          final uid = user['uid'];
          if (uid == null) return;

          try {
            final result = await NotificationService().sendNotification(
              title: _titleController.text.trim(),
              body: _bodyController.text.trim(),
              imageUrl: imageUrl,
              receiverId: uid,
            );
            if (result.startsWith('Success')) {
              successCount++;
            } else {
              failureCount++;
            }
          } catch (e) {
            failureCount++;
            print('Error sending to $uid: $e');
          }
        });

        await Future.wait(futures);

        sentCount += batch.length;

        setState(() {
          _progress = sentCount / totalUsers;
          _statusMessage =
              'Sent $sentCount of $totalUsers (Success: $successCount, Failed: $failureCount)';
        });

        // Small delay to be gentle on the backend/network
        await Future.delayed(const Duration(milliseconds: 500));
      }

      if (successCount > 0) {
        // Save notification to Firestore history
        await FirebaseService().saveNotification(
          title: _titleController.text.trim(),
          body: _bodyController.text.trim(),
          imageUrl: imageUrl,
        );
      }

      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Broadcast Complete'),
            content: Text(
              'Successfully sent: $successCount\nFailed: $failureCount',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _titleController.clear();
                  _bodyController.clear();
                  _imageUrlController.clear();
                  setState(() {
                    _imageFile = null;
                    _isLoading = false;
                    _isSending = false;
                    _progress = 0.0;
                    _statusMessage = '';
                  });
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
        setState(() {
          _isLoading = false;
          _isSending = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Broadcast Notification',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Batch Broadcast',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Sends to all users in batches of 20 to ensure reliability.',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              const SizedBox(height: 32),

              // Title Field
              TextFormField(
                controller: _titleController,
                enabled: !_isSending,
                decoration: InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter a title'
                    : null,
              ),
              const SizedBox(height: 20),

              // Body Field
              TextFormField(
                controller: _bodyController,
                enabled: !_isSending,
                maxLines: 5,
                decoration: InputDecoration(
                  labelText: 'Message Body',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter a message'
                    : null,
              ),
              const SizedBox(height: 20),

              // --- Image Mode Toggle ---
              Text(
                'Notification Image (Optional)',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 10),
              ToggleButtons(
                isSelected: [_imageMode == 'upload', _imageMode == 'url'],
                onPressed: _isSending
                    ? null
                    : (index) {
                        setState(() {
                          _imageMode = index == 0 ? 'upload' : 'url';
                          _imageFile = null;
                          _imageUrlController.clear();
                        });
                      },
                borderRadius: BorderRadius.circular(10),
                selectedColor: Colors.white,
                fillColor: const Color(0xFF0F2C59),
                color: Colors.grey[700],
                constraints: const BoxConstraints(minHeight: 40),
                children: const [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Icon(Icons.upload_file, size: 18),
                        SizedBox(width: 6),
                        Text('Upload Image'),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Icon(Icons.link, size: 18),
                        SizedBox(width: 6),
                        Text('Use URL'),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Upload Mode
              if (_imageMode == 'upload')
                GestureDetector(
                  onTap: _isSending ? null : _pickImage,
                  child: Container(
                    height: 150,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: _imageFile != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                Image.file(_imageFile!, fit: BoxFit.cover),
                                Positioned(
                                  right: 8,
                                  top: 8,
                                  child: InkWell(
                                    onTap: () =>
                                        setState(() => _imageFile = null),
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: const BoxDecoration(
                                        color: Colors.black54,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.close,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.add_photo_alternate_outlined,
                                size: 40,
                                color: Colors.grey,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Tap to pick from gallery',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                'Max 1.5MB',
                                style: TextStyle(
                                  color: Colors.grey[400],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),

              // URL Mode
              if (_imageMode == 'url') ...[
                TextFormField(
                  controller: _imageUrlController,
                  enabled: !_isSending,
                  decoration: InputDecoration(
                    labelText: 'Image URL',
                    hintText: 'https://example.com/image.jpg',
                    prefixIcon: const Icon(Icons.link),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                  keyboardType: TextInputType.url,
                ),
                const SizedBox(height: 8),
                Text(
                  'Paste a publicly accessible image URL. It must end in .jpg, .png, etc. and be reachable by FCM.',
                  style: TextStyle(fontSize: 12, color: Colors.orange[700]),
                ),
              ],

              const SizedBox(height: 40),

              // Progress Bar
              if (_isSending) ...[
                LinearProgressIndicator(
                  value: _progress,
                  backgroundColor: Colors.grey[200],
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Color(0xFF0F2C59),
                  ),
                  minHeight: 10,
                  borderRadius: BorderRadius.circular(5),
                ),
                const SizedBox(height: 10),
                Text(
                  _statusMessage,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // Send Button
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _isSending ? null : _sendBatchBroadcast,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F2C59),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 2,
                  ),
                  child: _isSending
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.send, color: Colors.white),
                            SizedBox(width: 12),
                            Text(
                              'Start Batch Broadcast',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
