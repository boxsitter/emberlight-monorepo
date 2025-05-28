import 'dart:async';

/// Base class for all form field descriptors.
abstract class FormFieldDescriptor<T> {
  final String label; // Display label for the form field
  final T? defaultValue;
  final bool isRequired;
  final FutureOr<String?> Function(T?)? validator; // Return null if valid, error message string if not.

  FormFieldDescriptor({
    required this.label,
    this.defaultValue,
    this.isRequired = true,
    this.validator,
  });
}

/// Describes a text input field.
class TextFormFieldDescriptor extends FormFieldDescriptor<String> {
  final String? hintText;
  final bool allowEmpty; // Specific to text, if isRequired is true, this might be redundant
  final bool isPassword; // To indicate if input should be obscured

  TextFormFieldDescriptor({
    required super.label,
    super.defaultValue,
    this.hintText,
    this.allowEmpty = false,
    this.isPassword = false,
    super.isRequired,
    super.validator, // Validator takes String? and returns FutureOr<String?>
  });
}

/// Describes a boolean input field (checkbox).
class BooleanFormFieldDescriptor extends FormFieldDescriptor<bool> {
  BooleanFormFieldDescriptor({
    required super.label,
    super.defaultValue = false,
    super.isRequired, // For a boolean, isRequired might mean it must be true, or just interacted with.
    // Typically, a checkbox is optional or defaults to false.
    super.validator, // Validator takes bool?
  });
}

/// Describes a single-choice selection field (dropdown/radio).
class SelectFormFieldDescriptor extends FormFieldDescriptor<String> {
  final List<String> options;
  final String Function(String value) optionLabelBuilder;

  SelectFormFieldDescriptor({
    required super.label,
    required this.options,
    required this.optionLabelBuilder,
    super.defaultValue,
    super.isRequired,
    super.validator,
  }) : assert(options.isNotEmpty, 'Options list cannot be empty for SelectFormField.');
}

/// Describes a multiple-choice selection field (checkboxes list).
class MultiSelectFormFieldDescriptor extends FormFieldDescriptor<List<String>> {
  final List<String> options;
  final String Function(String value) optionLabelBuilder;

  MultiSelectFormFieldDescriptor({
    required super.label,
    required this.options,
    required this.optionLabelBuilder,
    super.defaultValue,
    super.isRequired,
    super.validator,
  }) : assert(options.isNotEmpty, 'Options list cannot be empty for MultiSelectFormField.');
}

// Add other field types as needed, e.g., DatePickerFormFieldDescriptor, NumberFormFieldDescriptor etc.