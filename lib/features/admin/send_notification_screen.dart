import 'package:flutter/material.dart';
import '../../core/notification_service.dart';
import '../../core/firebase_service.dart';

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
  bool _isLoading = false;
  double _progress = 0.0;
  String _statusMessage = '';
  bool _isSending = false;

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  Future<void> _sendBatchBroadcast() async {
    if (!_formKey.currentState!.validate()) return;

    // Hide keyboard
    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = true;
      _isSending = true;
      _progress = 0.0;
      _statusMessage = 'Fetching users...';
    });

    try {
      // 1. Fetch all users
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

      // 2. Process in batches of 20
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
                  setState(() {
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
