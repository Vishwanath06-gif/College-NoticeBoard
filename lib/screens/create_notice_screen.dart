import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import '../models/notice_model.dart';
import '../providers/auth_provider.dart';
import '../providers/notice_provider.dart';

class CreateNoticeScreen extends StatefulWidget {
  const CreateNoticeScreen({super.key});

  @override
  State<CreateNoticeScreen> createState() => _CreateNoticeScreenState();
}

class _CreateNoticeScreenState extends State<CreateNoticeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  NoticeCategory _selectedCategory = NoticeCategory.general;
  DateTime? _expiryDate;
  bool _isPinned = false;
  int _priority = 1;
  final List<PlatformFile> _attachments = [];
  bool _isLoading = false;
  bool _showPreview = false;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _pickFiles() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png', 'txt'],
    );

    if (result != null) {
      setState(() {
        _attachments.addAll(result.files);
      });
    }
  }

  void _removeAttachment(int index) {
    setState(() {
      _attachments.removeAt(index);
    });
  }

  Future<void> _selectExpiryDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null) {
      setState(() => _expiryDate = date);
    }
  }

  Future<void> _postNotice() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final noticeProvider = context.read<NoticeProvider>();
    final user = authProvider.user;

    if (user == null) return;

    setState(() => _isLoading = true);

    try {
      await noticeProvider.createNotice(
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
        category: _selectedCategory,
        authorId: user.uid,
        authorName: user.name,
        expiryDate: _expiryDate,
        isPinned: _isPinned,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Notice posted successfully!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final isAdmin = authProvider.isAdmin;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Post New Notice'),
        actions: [
          TextButton.icon(
            onPressed: () => setState(() => _showPreview = !_showPreview),
            icon: Icon(_showPreview ? Icons.edit : Icons.preview),
            label: Text(_showPreview ? 'Edit' : 'Preview'),
          ),
        ],
      ),
      body: _showPreview ? _buildPreview() : _buildForm(isAdmin),
    );
  }

  Widget _buildForm(bool isAdmin) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Notice Details',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Title *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.title),
                        hintText: 'Enter notice title',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a title';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<NoticeCategory>(
                      value: _selectedCategory,
                      decoration: const InputDecoration(
                        labelText: 'Category *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.category),
                      ),
                      items: NoticeCategory.values.map((category) {
                        return DropdownMenuItem(
                          value: category,
                          child: Text(
                            '${category.icon} ${category.displayName}',
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _selectedCategory = value);
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _contentController,
                      maxLines: 8,
                      decoration: const InputDecoration(
                        labelText: 'Content *',
                        border: OutlineInputBorder(),
                        alignLabelWithHint: true,
                        hintText: 'Enter notice content...',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter content';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Settings',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.calendar_today),
                      title: Text(
                        _expiryDate != null
                            ? 'Expires: ${DateFormat('MMM d, y').format(_expiryDate!)}'
                            : 'Set Expiry Date (Optional)',
                      ),
                      subtitle: const Text('Leave empty for no expiry'),
                      trailing: _expiryDate != null
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () =>
                                  setState(() => _expiryDate = null),
                            )
                          : null,
                      onTap: _selectExpiryDate,
                    ),
                    const Divider(),
                    const Text(
                      'Priority Level',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),
                    SegmentedButton<int>(
                      segments: const [
                        ButtonSegment(
                          value: 1,
                          label: Text('Normal'),
                          icon: Icon(Icons.circle_outlined),
                        ),
                        ButtonSegment(
                          value: 2,
                          label: Text('Medium'),
                          icon: Icon(Icons.circle),
                        ),
                        ButtonSegment(
                          value: 3,
                          label: Text('High'),
                          icon: Icon(Icons.warning_amber),
                        ),
                      ],
                      selected: {_priority},
                      onSelectionChanged: (Set<int> selection) {
                        setState(() => _priority = selection.first);
                      },
                    ),
                    if (isAdmin) ...[
                      const SizedBox(height: 16),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Pin this notice'),
                        subtitle: const Text(
                          'Pinned notices appear at the top',
                        ),
                        value: _isPinned,
                        onChanged: (value) => setState(() => _isPinned = value),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Attachments',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Add files like PDFs, images, or documents (Max 10MB each)',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: _pickFiles,
                      icon: const Icon(Icons.attach_file),
                      label: const Text('Add Files'),
                    ),
                    if (_attachments.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      ...List.generate(_attachments.length, (index) {
                        final file = _attachments[index];
                        return Card(
                          child: ListTile(
                            leading: Icon(_getFileIcon(file.name)),
                            title: Text(
                              file.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text(
                              '${(file.size / 1024).toStringAsFixed(1)} KB',
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () => _removeAttachment(index),
                            ),
                          ),
                        );
                      }),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _isLoading ? null : _postNotice,
              icon: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.send),
              label: Text(_isLoading ? 'Posting...' : 'Post Notice'),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildPreview() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _getCategoryColor(
                        _selectedCategory,
                      ).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${_selectedCategory.icon} ${_selectedCategory.displayName}',
                      style: TextStyle(
                        color: _getCategoryColor(_selectedCategory),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const Spacer(),
                  if (_isPinned)
                    const Icon(Icons.push_pin, color: Colors.orange),
                  if (_priority == 3)
                    const Icon(Icons.warning_amber, color: Colors.red),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                _titleController.text.isEmpty
                    ? 'Notice Title'
                    : _titleController.text,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const CircleAvatar(
                    radius: 16,
                    child: Icon(Icons.person, size: 20),
                  ),
                  const SizedBox(width: 8),
                  Text(context.read<AuthProvider>().user?.name ?? 'Author'),
                ],
              ),
              const Divider(height: 32),
              Text(
                _contentController.text.isEmpty
                    ? 'Notice content will appear here...'
                    : _contentController.text,
                style: const TextStyle(fontSize: 16, height: 1.6),
              ),
              if (_expiryDate != null) ...[
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.event_busy, color: Colors.grey),
                      const SizedBox(width: 12),
                      Text(
                        'Expires: ${DateFormat('MMMM d, y').format(_expiryDate!)}',
                      ),
                    ],
                  ),
                ),
              ],
              if (_attachments.isNotEmpty) ...[
                const SizedBox(height: 24),
                const Text(
                  'Attachments',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ..._attachments.map(
                  (f) => ListTile(
                    leading: Icon(_getFileIcon(f.name)),
                    title: Text(f.name),
                    dense: true,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  IconData _getFileIcon(String fileName) {
    final ext = fileName.split('.').last.toLowerCase();
    switch (ext) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
        return Icons.image;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'txt':
        return Icons.text_snippet;
      default:
        return Icons.insert_drive_file;
    }
  }

  Color _getCategoryColor(NoticeCategory category) {
    switch (category) {
      case NoticeCategory.academic:
        return Colors.blue;
      case NoticeCategory.events:
        return Colors.purple;
      case NoticeCategory.placements:
        return Colors.green;
      case NoticeCategory.general:
        return Colors.grey;
      case NoticeCategory.urgent:
        return Colors.red;
    }
  }
}
