import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../api_client.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final api = context.watch<ApiClient>();
    return Scaffold(
      appBar: AppBar(title: const Text('Warisan Aleen · 概览')),
      body: RefreshIndicator(
        onRefresh: () async {
          (context as Element).markNeedsBuild();
          await Future.delayed(const Duration(milliseconds: 500));
        },
        child: FutureBuilder(
          future: api.status(),
          builder: (c, snap) {
            if (snap.connectionState != ConnectionState.done) {
              return ListView(children: const [
                SizedBox(height: 200),
                Center(child: CircularProgressIndicator()),
              ]);
            }
            if (snap.hasError) {
              return ListView(padding: const EdgeInsets.all(16), children: [
                const SizedBox(height: 80),
                const Icon(Icons.cloud_off, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                Text('后端未连接',
                    style: Theme.of(context).textTheme.titleMedium,
                    textAlign: TextAlign.center),
                const SizedBox(height: 8),
                Text('${snap.error}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.grey)),
                const SizedBox(height: 8),
                const Text('下拉刷新 · 在 设置 里修改 baseUrl',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey, fontSize: 12)),
              ]);
            }
            final s = snap.data as Map<String, dynamic>;
            final byStatus = (s['by_status'] ?? {}) as Map<String, dynamic>;
            return ListView(padding: const EdgeInsets.all(16), children: [
              _card('后端状态',
                  s['dry_run'] == true ? '演练模式 (DRY_RUN)' : '实发模式',
                  s['dry_run'] == true ? Colors.orange : Colors.green),
              _card('Access Token',
                  s['has_token'] == true ? '已配置' : '未配置 (待验证后补)',
                  s['has_token'] == true ? Colors.green : Colors.red),
              _card('内容模型', '${s['ollama_model'] ?? '-'}'),
              _card('帖子总数', '${s['post_count'] ?? 0}'),
              _card('状态分布',
                  byStatus.entries.map((e) => '${e.key}: ${e.value}').join('  ·  ')),
              const Divider(),
              const Text('资产', style: TextStyle(fontWeight: FontWeight.bold)),
              _card('FB Page ID', '${s['fb_page_id']}'),
              _card('IG Account ID', '${s['ig_account_id']}'),
              const SizedBox(height: 12),
              const Text(
                '下拉刷新状态',
                style: TextStyle(fontSize: 11, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ]);
          },
        ),
      ),
    );
  }

  Widget _card(String label, String value, [Color? c]) => Card(
        child: ListTile(
          title: Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          subtitle: Text(value, style: TextStyle(fontSize: 16, color: c)),
        ),
      );
}
