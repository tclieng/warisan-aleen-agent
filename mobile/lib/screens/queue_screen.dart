import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../api_client.dart';

class QueueScreen extends StatefulWidget {
  const QueueScreen({super.key});
  @override
  State<QueueScreen> createState() => _QueueScreenState();
}

class _QueueScreenState extends State<QueueScreen> {
  late Future<List<dynamic>> _future;

  @override
  void initState() {
    super.initState();
    _future = context.read<ApiClient>().posts();
  }

  void _reload() => setState(() => _future = context.read<ApiClient>().posts());

  Color _statusColor(String s) => s == 'published'
      ? Colors.green
      : s == 'pending_token'
          ? Colors.red
          : s == 'scheduled'
              ? Colors.blue
              : Colors.grey;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('帖子队列'),
          actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: _reload)],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            try {
              await context.read<ApiClient>().publishDue();
              _reload();
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('已触发发布到点帖子')));
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
            }
          },
          tooltip: '发布到点帖子',
          child: const Icon(Icons.send),
        ),
        body: FutureBuilder<List<dynamic>>(
          future: _future,
          builder: (c, snap) {
            if (snap.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snap.hasError) return Center(child: Text('$snap.error'));
            final list = snap.data ?? [];
            if (list.isEmpty) {
              return const Center(child: Text('暂无帖子，去“生成”页创建'));
            }
            return ListView.builder(
              itemCount: list.length,
              itemBuilder: (_, i) {
                final p = list[i] as Map<String, dynamic>;
                final status = p['status'] ?? '';
                final bm = (p['caption_bm'] ?? '').toString();
                return Card(
                  child: ListTile(
                    leading: Icon(Icons.circle, color: _statusColor(status), size: 14),
                    title: Text('${p['title'] ?? '(无标题)'}  [${p['platform']}]'),
                    subtitle: Text(
                        '${p['theme'] ?? ''} · $status\n${bm.length > 60 ? bm.substring(0, 60) : bm}'),
                    isThreeLine: true,
                    trailing: (status == 'draft' || status == 'scheduled')
                        ? IconButton(
                            icon: const Icon(Icons.send),
                            onPressed: () async {
                              try {
                                await context.read<ApiClient>().publish(p['id']);
                                _reload();
                              } catch (e) {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(SnackBar(content: Text('$e')));
                              }
                            },
                          )
                        : null,
                  ),
                );
              },
            );
          },
        ),
      );
}
