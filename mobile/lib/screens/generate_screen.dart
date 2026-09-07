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
        appBar: AppBar(title: const Text('生成帖子')),
        body: ListView(padding: const EdgeInsets.all(16), children: [
          TextField(
            controller: _topic,
            decoration: const InputDecoration(
              labelText: '主题（可空，留空随机选 kampung 美食）',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _platform,
            items: const [
              DropdownMenuItem(value: 'both', child: Text('FB + IG')),
              DropdownMenuItem(value: 'facebook', child: Text('仅 Facebook')),
              DropdownMenuItem(value: 'instagram', child: Text('仅 Instagram')),
            ],
            onChanged: (v) => setState(() => _platform = v!),
            decoration: const InputDecoration(labelText: '发布平台', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: _busy ? null : _gen,
            icon: const Icon(Icons.auto_awesome),
            label: Text(_busy ? '生成中…' : '生成双语文案'),
          ),
          if (_result != null) ...[
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('来源: ${_result!['source'] ?? '-'}',
                        style: const TextStyle(color: Colors.grey)),
                    const SizedBox(height: 6),
                    Text('BM: ${_result!['caption_bm'] ?? ''}'),
                    const SizedBox(height: 6),
                    Text('EN: ${_result!['caption_en'] ?? ''}'),
                    const SizedBox(height: 6),
                    Text('主题: ${_result!['theme'] ?? ''}'),
                  ],
                ),
              ),
            ),
          ],
        ]),
      );
}
