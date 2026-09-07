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
        appBar: AppBar(title: const Text('Settings')),
        body: ListView(padding: const EdgeInsets.all(16), children: [
          // --- Backend URL section ---
          Text(
            'Backend Connection',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _url,
            decoration: const InputDecoration(
              labelText: 'Backend URL',
              hintText: 'http://10.0.2.2:8000  (emulator)',
              helperText: 'Real device: use your PC LAN IP (e.g. http://192.168.1.x:8000)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          FilledButton(
            onPressed: () {
              context.read<ApiClient>().setBaseUrl(_url.text);
              _load();
              ScaffoldMessenger.of(context)
                  .showSnackBar(const SnackBar(content: Text('Backend URL saved')));
            },
            child: const Text('Save & Connect'),
          ),

          const Divider(height: 32),

          // --- Token section ---
          Text(
            'Meta Access Token',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 4),
          const Text(
            'Paste your long-lived Meta Page Access Token here after completing '
            'Business Verification and Advanced Access for pages_manage_posts.',
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _token,
            decoration: const InputDecoration(
              labelText: 'Access Token',
              hintText: 'Paste token after Meta verification is approved',
              border: OutlineInputBorder(),
            ),
            obscureText: true,
            maxLines: 1,
          ),
          const SizedBox(height: 8),
          FilledButton.icon(
            onPressed: () async {
              try {
                await context.read<ApiClient>().setToken(_token.text);
                _load();
                if (mounted) {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(const SnackBar(content: Text('Token saved')));
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text('Error: $e')));
                }
              }
            },
            icon: const Icon(Icons.key),
            label: const Text('Save Token'),
          ),

          const Divider(height: 32),

          // --- Dry run toggle ---
          SwitchListTile(
            title: const Text('Dry Run Mode'),
            subtitle: const Text('Generate posts only — never publish to Meta'),
            value: _dry,
            onChanged: (v) async {
              try {
                await context.read<ApiClient>().setDryRun(v);
                setState(() => _dry = v);
              } catch (_) {}
            },
          ),

          const Divider(height: 32),

          // --- Status readout ---
          if (_status != null) ...[
            Text(
              'Backend Status',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            _statusRow(
              'Token',
              _status!['has_token'] == true ? 'Configured' : 'Not set',
              _status!['has_token'] == true ? Colors.green : Colors.red,
            ),
            _statusRow(
              'Mode',
              _status!['dry_run'] == true ? 'Dry Run' : 'Live',
              _status!['dry_run'] == true ? Colors.orange : Colors.green,
            ),
            _statusRow('Model', _status!['ollama_model'] ?? '-', Colors.grey),
            _statusRow('Total Posts', '${_status!['post_count'] ?? 0}', Colors.grey),
            _statusRow('FB Page ID', '${_status!['fb_page_id']}', Colors.grey),
            _statusRow('IG Account ID', '${_status!['ig_account_id']}', Colors.grey),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _load,
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh Status'),
            ),
          ],
        ]),
      );

  Widget _statusRow(String label, String value, Color dotColor) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Icon(Icons.circle, color: dotColor, size: 10),
            const SizedBox(width: 8),
            Text('$label: ', style: const TextStyle(fontWeight: FontWeight.w500)),
            Expanded(child: Text(value)),
          ],
        ),
      );
}
