import 'package:flutter/material.dart';

import '../application/global_search_service.dart';
import '../domain/search_result_record.dart';

class GlobalSearchScreen extends StatefulWidget {
  const GlobalSearchScreen({
    required this.searchService,
    required this.onSelect,
    super.key,
  });

  final GlobalSearchService searchService;
  final ValueChanged<SearchResultRecord> onSelect;

  @override
  State<GlobalSearchScreen> createState() => _GlobalSearchScreenState();
}

class _GlobalSearchScreenState extends State<GlobalSearchScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final results = widget.searchService.search(_controller.text);
    final grouped = <SearchObjectType, List<SearchResultRecord>>{};
    for (final result in results) {
      grouped.putIfAbsent(result.type, () => []).add(result);
    }

    return AlertDialog(
      title: const Text('Global search'),
      content: SizedBox(
        width: 640,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(labelText: 'Search MetaRix'),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 420,
              child: ListView(
                children: grouped.entries
                    .map(
                      (entry) => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(entry.key.label),
                          ...entry.value.map(
                            (result) => ListTile(
                              title: Text(result.title),
                              subtitle: Text(result.subtitle),
                              onTap: () {
                                widget.onSelect(result);
                                Navigator.of(context).pop();
                              },
                            ),
                          ),
                          const Divider(),
                        ],
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
