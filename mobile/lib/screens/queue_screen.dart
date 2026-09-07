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

  String _statusLabel(String s) {
    switch (s) {
      case 'published':
        return 'Published';
      case 'pending_token':
        return 'Token Missing';
      case 'scheduled':
        return 'Scheduled';
      case 'draft':
        return 'Draft';
      default:
        return s;
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Post Queue'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _reload,
              tooltip: 'Refresh',
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () async {
            try {
              await context.read<ApiClient>().publishDue();
              _reload();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Due posts triggered')));
              }
            } catch (e) {
              if (mounted) {
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text('Error: $e')));
              }
            }
          },
          icon: const Icon(Icons.send),
          label: const Text('Publish Due'),
          tooltip: 'Publish all due posts now',
        ),
        body: FutureBuilder<List<dynamic>>(
          future: _future,
          builder: (c, snap) {
            if (snap.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snap.hasError) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.cloud_off, size: 64, color: Colors.grey),
                    const SizedBox(height: 12),
                    Text(
                      'Failed to load posts',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$snap.error',
                      style: const TextStyle(color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: _reload,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }
            final list = snap.data ?? [];
            if (list.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.inbox_outlined, size: 64, color: Colors.grey),
                    const SizedBox(height: 12),
                    Text(
                      'No posts yet',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Go to Generate to create your first post',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              );
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
                    title: Text(
                      '${p['title'] ?? '(No title)'}  [${p['platform'] ?? 'both'}]',
                    ),
                    subtitle: Text(
                      '${_statusLabel(status)}  ·  ${p['theme'] ?? ''}\n'
                      '${bm.isNotEmpty ? (bm.length > 70 ? '${bm.substring(0, 70)}...' : bm) : '(no caption)'}',
                    ),
                    isThreeLine: true,
                    trailing: (status == 'draft' || status == 'scheduled')
                        ? IconButton(
                            icon: const Icon(Icons.send),
                            tooltip: 'Publish now',
                            onPressed: () async {
                              try {
                                await context.read<ApiClient>().publish(p['id']);
                                _reload();
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Post published!')));
                                }
                              } catch (e) {
                                if (mounted) {
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(SnackBar(content: Text('Error: $e')));
                                }
                              }
                            },
                          )
                        : (status == 'pending_token'
                            ? const Tooltip(
                                message: 'Token missing — set in Settings',
                                child: Icon(Icons.warning_amber, color: Colors.orange),
                              )
                            : null),
                  ),
                );
              },
            );
          },
        ),
      );
}
