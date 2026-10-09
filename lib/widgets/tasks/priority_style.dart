import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../models/task_model.dart';

extension TaskPriorityStyle on TaskPriority {
  Color get dotColor => switch (this) {
        TaskPriority.low => AppColors.lowDot,
        TaskPriority.medium => AppColors.mediumDot,
        TaskPriority.high => AppColors.highDot,
      };

  Color get backgroundColor => switch (this) {
        TaskPriority.low => AppColors.lowBg,
        TaskPriority.medium => AppColors.mediumBg,
        TaskPriority.high => AppColors.highBg,
      };

  Color get borderColor => switch (this) {
        TaskPriority.low => AppColors.lowBorder,
        TaskPriority.medium => AppColors.mediumBorder,
        TaskPriority.high => AppColors.highBorder,
      };

  Color get textColor => switch (this) {
        TaskPriority.low => AppColors.lowText,
        TaskPriority.medium => AppColors.mediumText,
        TaskPriority.high => AppColors.highText,
      };
}