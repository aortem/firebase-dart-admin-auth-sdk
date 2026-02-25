// ignore_for_file: public_member_api_docs, uri_does_not_exist, undefined_class, undefined_function, undefined_identifier, undefined_method, undefined_getter, creation_with_non_type, extends_non_class, super_formal_parameter_without_associated_named, undefined_super_member, override_on_non_overriding_member, non_type_as_type_argument, non_constant_list_element, unchecked_use_of_nullable_value
import 'package:flutter/material.dart';

/// A custom button widget.
class Button extends StatelessWidget {
  /// The title of the button.
  final String? title;

  /// The callback to invoke when the button is tapped.
  final VoidCallback onTap;

  /// Indicates whether an operation is currently in progress.
  final bool loading;

  /// Constructs the [Button] widget.
  const Button({
    super.key,
    required this.onTap,
    required this.title,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      onPressed: onTap,
      color: Colors.purple,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      textColor: Colors.white,
      textTheme: ButtonTextTheme.normal,
      child: loading
          ? const SizedBox(
              height: 15,
              width: 15,
              child: CircularProgressIndicator(color: Colors.white),
            )
          : Text(title ?? ''),
    );
  }
}
