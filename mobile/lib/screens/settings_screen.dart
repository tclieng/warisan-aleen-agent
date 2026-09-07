import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../api_client.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _url = TextEditingController();
  final _token = TextEditingController();
  Map<String, dynamic>? _status;
  bool _dry = true;

  @override
  void initState() {
    super.initState();
    _url.text = context.read<ApiClient>().baseUrl;
    _load();
  }

  void _load() async {
    try {
      final s = await context.read<ApiClient>().status();
      setState(() {
        _status = s;
        _dry = s['dry_run'] == true;
      });
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('设置')),
        body: ListView(padding: const EdgeInsets.all(16), children: [
          TextField(
            controller: _url,
            decoration: const InputDecoration(
              labelText: '后端地址',
              hintText: 'http://10.0.2.2:8000',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          FilledButton(onPressed: () {
            context.read<ApiClient>().setBaseUrl(_url.text);
            _load();
          }, child: const Text('保存并连接')),
          const Divider(height: 32),
          TextField(
            controller: _token,
            decoration: const InputDecoration(
              labelText: 'Meta Access Token（验证后填入）',
              border: OutlineInputBorder(),
            ),
            obscureText: true,
          ),
          const SizedBox(height: 8),
          FilledButton.icon(
            onPressed: () async {
              try {
                await context.read<ApiClient>().setToken(_token.text);
                _load();
                if (mounted) {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(const SnackBar(content: Text('Token 已保存')));
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
                }
              }
            },
            icon: const Icon(Icons.key),
            label: const Text('保存 Token'),
          ),
          const Divider(height: 32),
          SwitchListTile(
            title: const Text('演练模式 (DRY_RUN)'),
            subtitle: const Text('开启时不真正发帖，仅生成与预览'),
            value: _dry,
            onChanged: (v) async {
              try {
                await context.read<ApiClient>().setDryRun(v);
                setState(() => _dry = v);
              } catch (_) {}
            },
          ),
          if (_status != null) ...[
            const SizedBox(height: 12),
            Text('后端回报：', style: const TextStyle(fontWeight: FontWeight.bold)),
            Text('has_token=${_status!['has_token']}  model=${_status!['ollama_model']}  '
                'posts=${_status!['post_count']}'),
          ],
        ]),
      );
}
