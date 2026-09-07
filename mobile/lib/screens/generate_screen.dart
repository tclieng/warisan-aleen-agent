import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../api_client.dart';

class GenerateScreen extends StatefulWidget {
  const GenerateScreen({super.key});
  @override
  State<GenerateScreen> createState() => _GenerateScreenState();
}

class _GenerateScreenState extends State<GenerateScreen> {
  final _topic = TextEditingController();
  String _platform = 'both';
  bool _busy = false;
  Map<String, dynamic>? _result;

  void _gen() async {
    setState(() => _busy = true);
    try {
      final r = await context
          .read<ApiClient>()
          .generate(_topic.text, _platform);
      setState(() => _result = r);
    } catch (e) {
      setState(() => _result = {'error': '$e'});
    } finally {
      setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Generate Post')),
        body: ListView(padding: const EdgeInsets.all(16), children: [
          TextField(
            controller: _topic,
            decoration: const InputDecoration(
              labelText: 'Topic (optional — leave blank for random kampung dish)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _platform,
            items: const [
              DropdownMenuItem(value: 'both', child: Text('FB + Instagram')),
              DropdownMenuItem(value: 'facebook', child: Text('Facebook only')),
              DropdownMenuItem(value: 'instagram', child: Text('Instagram only')),
            ],
            onChanged: (v) => setState(() => _platform = v!),
            decoration: const InputDecoration(
              labelText: 'Platform',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: _busy ? null : _gen,
            icon: const Icon(Icons.auto_awesome),
            label: Text(_busy ? 'Generating...' : 'Generate Bilingual Post'),
          ),
          if (_result != null) ...[
            const SizedBox(height: 16),
            if (_result!.containsKey('error'))
              Card(
                color: Colors.red.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    'Error: ${_result!['error']}',
                    style: TextStyle(color: Colors.red.shade800),
                  ),
                ),
              )
            else
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Source: ${_result!['source'] ?? '-'}',
                        style: const TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Theme: ${_result!['theme'] ?? ''}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const Divider(),
                      const Text(
                        'Bahasa Malaysia:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(_result!['caption_bm'] ?? ''),
                      const Divider(),
                      const Text(
                        'English:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(_result!['caption_en'] ?? ''),
                    ],
                  ),
                ),
              ),
          ],
        ]),
      );
}
