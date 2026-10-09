import 'package:firebase_push_local_notification/core/utils/date_formatteres.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/validators.dart';
import '../../models/task_model.dart';
import '../../providers/task_provider.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_text_field.dart';
import '../../widgets/common/error_message.dart';
import '../../widgets/common/field_label.dart';
import '../../widgets/tasks/date_field.dart';
import '../../widgets/tasks/priority_selectors.dart';

/// One screen, two modes. Without a task it shows the "New Task" design,
/// with a task it shows the "Edit Task" design.
class AddEditTaskScreen extends StatefulWidget {
  const AddEditTaskScreen({super.key, this.task});

  final TaskModel? task;

  @override
  State<AddEditTaskScreen> createState() => _AddEditTaskScreenState();
}

class _AddEditTaskScreenState extends State<AddEditTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late DateTime _dueDate;
  late TaskPriority _priority;
  late bool _isCompleted;
  String? _course;
  bool _isSaving = false;
  String? _error;

  bool get _isEditing => widget.task != null;

  @override
  void initState() {
    super.initState();
    final task = widget.task;
    _titleController = TextEditingController(text: task?.title ?? '');
    _descriptionController =
        TextEditingController(text: task?.description ?? '');
    _dueDate = task?.dueDate ?? DateFormatters.dateOnly(DateTime.now());
    _priority = task?.priority ?? TaskPriority.medium;
    _isCompleted = task?.isCompleted ?? false;
    _course = task?.course;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  /// Edit mode: put every field back to the saved values.
  void _reset() {
    final task = widget.task!;
    _titleController.text = task.title;
    _descriptionController.text = task.description;
    setState(() {
      _dueDate = task.dueDate;
      _priority = task.priority;
      _isCompleted = task.isCompleted;
      _course = task.course;
      _error = null;
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _dueDate = DateFormatters.dateOnly(picked));
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _isSaving = true;
      _error = null;
    });

    final provider = context.read<TaskProvider>();
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();

    final String? error;
    if (_isEditing) {
      error = await provider.updateTask(
        widget.task!.copyWith(
          title: title,
          description: description,
          dueDate: _dueDate,
          priority: _priority,
          isCompleted: _isCompleted,
          course: _course,
          clearCourse: _course == null,
        ),
      );
    } else {
      error = await provider.addTask(
        title: title,
        description: description,
        dueDate: _dueDate,
        priority: _priority,
      );
    }

    if (!mounted) return;
    if (error == null) {
      Navigator.of(context).pop();
    } else {
      setState(() {
        _isSaving = false;
        _error = error;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _isEditing ? Colors.white : AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _Header(
              title: _isEditing ? 'Edit Task' : 'New Task',
              centered: !_isEditing,
              onBack: _isSaving ? null : () => Navigator.of(context).pop(),
              onReset: _isEditing && !_isSaving ? _reset : null,
              showReset: _isEditing,
            ),
            Expanded(
              child: CustomScrollView(
                slivers: [
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: _isEditing ? _editFields() : _newFields(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------- New Task layout ----------

  List<Widget> _newFields() {
    return [
      AppTextField(
        label: 'Title',
        controller: _titleController,
        hint: 'e.g. Complete Flutter Assignment',
        enabled: !_isSaving,
        maxLength: AppConstants.maxTitleLength,
        textInputAction: TextInputAction.next,
        validator: Validators.taskTitle,
      ),
      const SizedBox(height: 24),
      AppTextField(
        label: 'Notes',
        controller: _descriptionController,
        hint: 'Add details, links, or notes...',
        enabled: !_isSaving,
        maxLength: AppConstants.maxDescriptionLength,
        minLines: 4,
        maxLines: 6,
      ),
      const SizedBox(height: 24),
      DateField(
        label: 'Due Date',
        value: _dueDate,
        onTap: _isSaving ? () {} : _pickDate,
      ),
      const SizedBox(height: 24),
      const FieldLabel('Priority'),
      const SizedBox(height: 8),
      PriorityChipSelector(
        selected: _priority,
        onChanged: (p) {
          if (!_isSaving) setState(() => _priority = p);
        },
      ),
      if (_error != null) ...[
        const SizedBox(height: 16),
        ErrorMessage(message: _error!),
      ],
      const Spacer(),
      const SizedBox(height: 24),
      AppButton(label: 'Save Task', isLoading: _isSaving, onPressed: _save),
      _CancelButton(onPressed: _isSaving ? null : () => Navigator.of(context).pop()),
    ];
  }

  // ---------- Edit Task layout ----------

  List<Widget> _editFields() {
    final courses = <String>{
      ...AppConstants.courseBuckets,
      if (_course != null) _course!,
    }.toList();

    return [
      AppTextField(
        label: 'Task Title',
        uppercaseLabel: false,
        controller: _titleController,
        enabled: !_isSaving,
        maxLength: AppConstants.maxTitleLength,
        textInputAction: TextInputAction.next,
        validator: Validators.taskTitle,
        labelTrailing: ValueListenableBuilder<TextEditingValue>(
          valueListenable: _titleController,
          builder: (_, value, _) => Text(
            '${value.text.length}/${AppConstants.maxTitleLength}',
            style: AppTextStyles.counter,
          ),
        ),
        suffixIcon: IconButton(
          icon: const Icon(Icons.close, size: 20, color: AppColors.textHint),
          onPressed: _isSaving ? null : _titleController.clear,
        ),
      ),
      const SizedBox(height: 20),
      AppTextField(
        label: 'Description & Milestones',
        uppercaseLabel: false,
        controller: _descriptionController,
        enabled: !_isSaving,
        maxLength: AppConstants.maxDescriptionLength,
        minLines: 4,
        maxLines: 6,
      ),
      const SizedBox(height: 20),
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: DateField(
              label: 'Due Date',
              uppercaseLabel: false,
              iconFirst: true,
              value: _dueDate,
              onTap: _isSaving ? () {} : _pickDate,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: _courseDropdown(courses)),
        ],
      ),
      const SizedBox(height: 20),
      const FieldLabel('Priority', uppercase: false),
      const SizedBox(height: 8),
      PrioritySegmentedControl(
        selected: _priority,
        onChanged: (p) {
          if (!_isSaving) setState(() => _priority = p);
        },
      ),
      const SizedBox(height: 20),
      _completedCard(),
      if (_error != null) ...[
        const SizedBox(height: 16),
        ErrorMessage(message: _error!),
      ],
      const Spacer(),
      const SizedBox(height: 24),
      AppButton(
        label: 'Save Changes',
        backgroundColor: AppColors.dark,
        isLoading: _isSaving,
        leading: const Icon(Icons.check, color: Colors.white, size: 20),
        onPressed: _save,
      ),
      _CancelButton(onPressed: _isSaving ? null : () => Navigator.of(context).pop()),
    ];
  }

  Widget _courseDropdown(List<String> courses) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const FieldLabel('Course Bucket', uppercase: false),
        const SizedBox(height: 8),
        Container(
          height: AppSizes.buttonHeight,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppSizes.radius),
            border: Border.all(color: AppColors.border),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _course,
              isExpanded: true,
              hint: Text('None', style: AppTextStyles.hint),
              icon: const Icon(
                Icons.keyboard_arrow_down,
                color: AppColors.textSecondary,
              ),
              borderRadius: BorderRadius.circular(14),
              dropdownColor: Colors.white,
              style: AppTextStyles.input,
              onChanged:
                  _isSaving ? null : (value) => setState(() => _course = value),
              items: [
                DropdownMenuItem<String>(
                  value: null,
                  child: Text('None', style: AppTextStyles.hint),
                ),
                for (final course in courses)
                  DropdownMenuItem<String>(
                    value: course,
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.dark,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(course),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _completedCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radius),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Completed',
                  style: AppTextStyles.input.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text('Mark task as done', style: AppTextStyles.body),
              ],
            ),
          ),
          Switch(
            value: _isCompleted,
            onChanged:
                _isSaving ? null : (value) => setState(() => _isCompleted = value),
            thumbColor: const WidgetStatePropertyAll(Colors.white),
            activeTrackColor: AppColors.primary,
            inactiveTrackColor: AppColors.border,
            trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.title,
    required this.centered,
    required this.onBack,
    required this.onReset,
    required this.showReset,
  });

  final String title;
  final bool centered;
  final VoidCallback? onBack;
  final VoidCallback? onReset;
  final bool showReset;

  @override
  Widget build(BuildContext context) {
    final back = IconButton(
      icon: const Icon(Icons.arrow_back, color: Color(0xFF334155)),
      onPressed: onBack,
    );
    final titleText = Text(
      title,
      style: AppTextStyles.cardTitle.copyWith(fontSize: 18),
    );

    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: centered
          ? Stack(
              alignment: Alignment.center,
              children: [
                Align(alignment: Alignment.centerLeft, child: back),
                titleText,
              ],
            )
          : Row(
              children: [
                back,
                titleText,
                const Spacer(),
                if (showReset)
                  TextButton(
                    onPressed: onReset,
                    child: Text(
                      'Reset',
                      style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.w500,
                        color: AppColors.textHint,
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}

class _CancelButton extends StatelessWidget {
  const _CancelButton({required this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: TextButton(
        onPressed: onPressed,
        child: Text(
          'Cancel',
          style: AppTextStyles.body.copyWith(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}