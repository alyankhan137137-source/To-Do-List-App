import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/task_template.dart';
import '../../../providers/task_provider.dart';

/// Bottom sheet selector for applying preset task routines.
class TemplatesSheet extends StatelessWidget {
  const TemplatesSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TaskProvider>(context, listen: false);

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.auto_awesome_rounded, color: Colors.purple),
                  SizedBox(width: 8),
                  Text(
                    'Quick Task Templates',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const Divider(),
          const SizedBox(height: 12),
          const Text(
            'Select a preset template to instantly populate your task list:',
            style: TextStyle(color: Colors.grey, fontSize: 13),
          ),
          const SizedBox(height: 16),
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: TaskTemplate.presets.length,
              itemBuilder: (ctx, index) {
                final template = TaskTemplate.presets[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: template.color.withValues(alpha: 0.15),
                      child: Icon(template.icon, color: template.color),
                    ),
                    title: Text(
                      template.title,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    subtitle: Text(
                      '${template.subTaskTitles.length} sub-tasks • ${template.description}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12),
                    ),
                    trailing: const Icon(Icons.add_circle_outline_rounded, color: Colors.purple),
                    onTap: () {
                      provider.applyTemplate(template);
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('${template.title} added to your tasks!')),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
