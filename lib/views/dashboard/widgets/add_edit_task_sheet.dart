import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../models/category_model.dart';
import '../../../models/priority_enum.dart';
import '../../../models/sub_task_model.dart';
import '../../../models/task_model.dart';
import '../../../providers/task_provider.dart';

/// Modal bottom sheet for creating or editing a task with inputs for title, description, category, priority, due date, and sub-tasks checklist builder.
class AddEditTaskSheet extends StatefulWidget {
  final TaskModel? existingTask;

  const AddEditTaskSheet({super.key, this.existingTask});

  @override
  State<AddEditTaskSheet> createState() => _AddEditTaskSheetState();
}

class _AddEditTaskSheetState extends State<AddEditTaskSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descController;
  final TextEditingController _subTaskInputController = TextEditingController();

  late PriorityLevel _selectedPriority;
  late String _selectedCategoryId;
  DateTime? _selectedDueDate;
  late List<SubTask> _subTasks;

  @override
  void initState() {
    super.initState();
    final task = widget.existingTask;
    _titleController = TextEditingController(text: task?.title ?? '');
    _descController = TextEditingController(text: task?.description ?? '');
    _selectedPriority = task?.priority ?? PriorityLevel.medium;
    _selectedCategoryId = task?.categoryId ?? 'personal';
    _selectedDueDate = task?.dueDate;
    _subTasks = task != null ? List.from(task.subTasks) : [];
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _subTaskInputController.dispose();
    super.dispose();
  }

  void _addSubTask() {
    final text = _subTaskInputController.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        _subTasks.add(SubTask(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: text,
        ));
        _subTaskInputController.clear();
      });
    }
  }

  void _removeSubTask(int index) {
    setState(() {
      _subTasks.removeAt(index);
    });
  }

  Future<void> _pickDueDate() async {
    final now = DateTime.now();
    final initialDate = _selectedDueDate ?? now;

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now.add(const Duration(days: 3650)),
    );

    if (pickedDate != null && mounted) {
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(initialDate),
      );

      setState(() {
        if (pickedTime != null) {
          _selectedDueDate = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        } else {
          _selectedDueDate = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            23,
            59,
          );
        }
      });
    }
  }

  void _saveTask() {
    if (_formKey.currentState!.validate()) {
      final provider = Provider.of<TaskProvider>(context, listen: false);

      if (widget.existingTask != null) {
        final updated = widget.existingTask!.copyWith(
          title: _titleController.text.trim(),
          description: _descController.text.trim(),
          priority: _selectedPriority,
          categoryId: _selectedCategoryId,
          dueDate: _selectedDueDate,
          subTasks: _subTasks,
        );
        provider.updateTask(updated);
      } else {
        final newTask = TaskModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: _titleController.text.trim(),
          description: _descController.text.trim(),
          createdAt: DateTime.now(),
          priority: _selectedPriority,
          categoryId: _selectedCategoryId,
          dueDate: _selectedDueDate,
          subTasks: _subTasks,
        );
        provider.addTask(newTask);
      }

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingTask != null;
    final viewInsets = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      constraints: BoxHeightConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      padding: EdgeInsets.fromLTRB(20, 20, 20, viewInsets + 20),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isEditing ? 'Edit Task' : 'New Task',
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 12),

              // Task Title
              TextFormField(
                controller: _titleController,
                autofocus: !isEditing,
                decoration: const InputDecoration(
                  labelText: 'Task Title *',
                  hintText: 'What needs to be done?',
                  prefixIcon: Icon(Icons.task_alt_rounded),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a task title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Description
              TextFormField(
                controller: _descController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Description (Optional)',
                  hintText: 'Add details or notes...',
                  prefixIcon: Icon(Icons.notes_rounded),
                ),
              ),
              const SizedBox(height: 16),

              // Category Selector
              const Text('Category', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _selectedCategoryId,
                decoration: const InputDecoration(prefixIcon: Icon(Icons.category_rounded)),
                items: TaskCategory.defaultCategories
                    .where((c) => c.id != 'all')
                    .map(
                      (cat) => DropdownMenuItem(
                        value: cat.id,
                        child: Row(
                          children: [
                            Icon(cat.icon, color: cat.color, size: 18),
                            const SizedBox(width: 8),
                            Text(cat.title),
                          ],
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedCategoryId = val);
                },
              ),
              const SizedBox(height: 16),

              // Priority Selector
              const Text('Priority Level', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 8),
              Row(
                children: PriorityLevel.values.map((p) {
                  final isSelected = _selectedPriority == p;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2.0),
                      child: ChoiceChip(
                        label: Text(
                          p.label,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected ? Colors.white : p.color,
                          ),
                        ),
                        selected: isSelected,
                        selectedColor: p.color,
                        onSelected: (_) => setState(() => _selectedPriority = p),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // Due Date Picker Button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Due Date & Time', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      const SizedBox(height: 4),
                      Text(
                        _selectedDueDate == null
                            ? 'No deadline set'
                            : DateFormatter.formatDueDate(_selectedDueDate),
                        style: TextStyle(
                          color: _selectedDueDate == null ? Colors.grey : Theme.of(context).primaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      if (_selectedDueDate != null)
                        IconButton(
                          icon: const Icon(Icons.clear_rounded, color: Colors.grey),
                          onPressed: () => setState(() => _selectedDueDate = null),
                        ),
                      OutlinedButton.icon(
                        onPressed: _pickDueDate,
                        icon: const Icon(Icons.calendar_month_rounded, size: 18),
                        label: Text(_selectedDueDate == null ? 'Set Date' : 'Change'),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Sub-tasks Builder
              const Text('Checklist / Sub-tasks', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 8),

              // Sub-task List Items
              ..._subTasks.asMap().entries.map((entry) {
                final index = entry.key;
                final subTask = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6.0),
                  child: Row(
                    children: [
                      const Icon(Icons.check_box_outline_blank_rounded, size: 20, color: Colors.grey),
                      const SizedBox(width: 8),
                      Expanded(child: Text(subTask.title)),
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline_rounded, color: Colors.redAccent, size: 20),
                        onPressed: () => _removeSubTask(index),
                      ),
                    ],
                  ),
                );
              }),

              // Sub-task Input Row
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _subTaskInputController,
                      decoration: const InputDecoration(
                        hintText: 'Add a sub-task step...',
                        isDense: true,
                        contentPadding: EdgeInsets.all(10),
                      ),
                      onSubmitted: (_) => _addSubTask(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    icon: const Icon(Icons.add_rounded),
                    onPressed: _addSubTask,
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // Save Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _saveTask,
                  icon: Icon(isEditing ? Icons.save_rounded : Icons.add_task_rounded),
                  label: Text(
                    isEditing ? 'Save Changes' : 'Create Task',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
class BoxHeightConstraints extends BoxConstraints {
  const BoxHeightConstraints({required super.maxHeight});
}
