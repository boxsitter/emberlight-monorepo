import 'package:ember_cli_utils/ember_cli_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class DynamicTextFormField extends StatelessWidget {
  final TextFormFieldDescriptor descriptor;
  final Function(String?) onSaved;
  final String? initialValue;

  const DynamicTextFormField({
    super.key,
    required this.descriptor,
    required this.onSaved,
    this.initialValue,
  });

  @override
  Widget build(BuildContext context) {
    return ShadInputFormField(
      label: Text(descriptor.label), // Assuming label is non-null as per FormFieldDescriptor
      initialValue: initialValue ?? descriptor.defaultValue ?? '',
      placeholder: descriptor.hintText == null ? null : Text(descriptor.hintText!),
      obscureText: descriptor.isPassword,
      validator: (value) {
        if (descriptor.isRequired && (value.isEmpty) && !descriptor.allowEmpty) {
          return '${descriptor.label} is required.';
        }
        if (descriptor.validator != null) {
          // Assuming synchronous validator for now, adapt if async
          final error = descriptor.validator!(value);
          if (error is String) return error;
        }
        return null;
      },
      onSaved: onSaved,
    );
  }
}

class DynamicBooleanFormField extends StatelessWidget {
  final BooleanFormFieldDescriptor descriptor;
  final Function(bool?) onSaved;
  final bool? initialValue;

  const DynamicBooleanFormField({
    super.key,
    required this.descriptor,
    required this.onSaved,
    this.initialValue,
  });

  @override
  Widget build(BuildContext context) {
    return ShadCheckboxFormField(
      initialValue: initialValue ?? descriptor.defaultValue ?? false, // Updated to use initialValue and descriptor.defaultValue
      inputLabel:  Text(descriptor.label),
      onSaved: onSaved,
    );
  }
}

class DynamicSelectFormField extends StatelessWidget {
  final SelectFormFieldDescriptor descriptor;
  final Function(String?) onSaved;

  const DynamicSelectFormField({
    super.key,
    required this.descriptor,
    required this.onSaved,
  });

  @override
  Widget build(BuildContext context) {
    return ShadSelectFormField<String>(
      label: Text(descriptor.label),
      allowDeselection: true,
      initialValue: descriptor.defaultValue is String ? descriptor.defaultValue : null,
      options: descriptor.options.map((opt) => ShadOption<String>(value: opt, child: Text(opt))).toList(),
      selectedOptionBuilder: (context, value) => Text(value),
      placeholder: Text('Select...'), // Use hintText for placeholder
      validator: (value) {
        if (descriptor.isRequired && value == null) {
          return '${descriptor.label} is required.';
        }
        if (descriptor.validator != null) {
          final error = descriptor.validator!(value);
          if (error is String) return error;
        }
        return null;
      },
      onSaved: onSaved,
    );
  }
}

class DynamicMultiSelectFormField extends StatelessWidget {
  final MultiSelectFormFieldDescriptor descriptor;
  final Function(List<String>?) onSaved; // Changed signature for multi-select

  const DynamicMultiSelectFormField({
    super.key,
    required this.descriptor,
    required this.onSaved,
  });

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Display the label similar to other Shadcn form fields
        Text(descriptor.label, style: theme.textTheme.small),
        const SizedBox(height: 8), // Consistent spacing
        FormField<List<String>>(
          onSaved: onSaved,
          validator: (List<String>? value) {
            if (descriptor.isRequired && (value == null || value.isEmpty)) {
              return '${descriptor.label} is required.';
            }
            // Note: descriptor.validator is (dynamic Function(dynamic)?).
            // It's not directly compatible with validating a List<String>.
            // For minimal compatibility and correctness, we only handle isRequired here.
            // If you need to apply the descriptor.validator, it would require
            // adapting it or using a specific validator for lists in your descriptor.
            return null;
          },
          builder: (FormFieldState<List<String>> field) {
            final hasError = field.errorText != null;
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShadSelect<String>.multiple(
                  options: descriptor.options
                      .map((opt) => ShadOption<String>(value: opt, child: Text(opt)))
                      .toList(),
                  onChanged: (List<String> values) {
                    field.didChange(values); // Update FormFieldState
                  },
                  selectedOptionsBuilder: (context, currentValue) {
                    if (currentValue.isEmpty) {
                      return Text(
                        'Select multiple...',
                        style: TextStyle(color: theme.colorScheme.mutedForeground), // Mimic placeholder style
                      );
                    }
                    return Text(currentValue.join(', '));
                  },
                  placeholder: Text('Select multiple...'),
                  closeOnSelect: false, // Keep dropdown open for multiple selections
                ),
                if (hasError)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      field.errorText!,
                      style: theme.textTheme.small.copyWith(color: theme.colorScheme.destructive),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}