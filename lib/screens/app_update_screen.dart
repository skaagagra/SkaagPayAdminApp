import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../services/api_service.dart';

class UploadUpdateScreen extends StatefulWidget {
  const UploadUpdateScreen({super.key});

  @override
  State<UploadUpdateScreen> createState() => _UploadUpdateScreenState();
}

class _UploadUpdateScreenState extends State<UploadUpdateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _versionNameController = TextEditingController();
  final _versionCodeController = TextEditingController();
  final _releaseNotesController = TextEditingController();
  bool _isForceUpdate = false;
  String? _selectedFilePath;
  bool _isLoading = false;

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.any, // Changed to any because some systems don't recognize .apk uniquely
      // allowedExtensions: ['apk'], 
    );

    if (result != null) {
      setState(() {
        _selectedFilePath = result.files.single.path;
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _selectedFilePath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields and select an APK')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final success = await ApiService().uploadApk(
      versionName: _versionNameController.text,
      versionCode: int.parse(_versionCodeController.text),
      filePath: _selectedFilePath!,
      releaseNotes: _releaseNotesController.text,
      isForceUpdate: _isForceUpdate,
    );

    setState(() => _isLoading = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Update uploaded successfully')),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to upload update')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Upload New Version')),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _versionNameController,
                    decoration: const InputDecoration(labelText: 'Version Name (e.g. 1.0.1)'),
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _versionCodeController,
                    decoration: const InputDecoration(labelText: 'Version Code (Integer, e.g. 2)'),
                    keyboardType: TextInputType.number,
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _releaseNotesController,
                    decoration: const InputDecoration(labelText: 'Release Notes'),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  CheckboxListTile(
                    title: const Text('Force Update?'),
                    value: _isForceUpdate,
                    onChanged: (v) => setState(() => _isForceUpdate = v!),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: _pickFile,
                        child: const Text('Select APK'),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _selectedFilePath != null 
                            ? 'Selected: ${_selectedFilePath!.split('/').last}' 
                            : 'No file selected',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.blueAccent,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Upload Update'),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }
}
