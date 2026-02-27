// ignore_for_file: public_member_api_docs, uri_does_not_exist, undefined_class, undefined_function, undefined_identifier, undefined_method, undefined_getter, creation_with_non_type, extends_non_class, super_formal_parameter_without_associated_named, undefined_super_member, override_on_non_overriding_member, non_type_as_type_argument, non_constant_list_element, unchecked_use_of_nullable_value
import 'package:flutter/material.dart';

/// Extension on [num] for easier UI layout.
extension NumExtension on num {
  /// Returns [EdgeInsets] with horizontal padding.
  EdgeInsets get horizontal {
    return EdgeInsets.symmetric(horizontal: toDouble());
  }

  /// Returns [EdgeInsets] with vertical padding.
  EdgeInsets get vertical {
    return EdgeInsets.symmetric(vertical: toDouble());
  }

  /// Returns [EdgeInsets] with all-side padding.
  EdgeInsets get all {
    return EdgeInsets.symmetric(horizontal: toDouble(), vertical: toDouble());
  }

  /// Returns a [SizedBox] with width equal to this number.
  SizedBox get hSpace {
    return SizedBox(width: toDouble());
  }

  /// Returns a [SizedBox] with height equal to this number.
  SizedBox get vSpace {
    return SizedBox(height: toDouble());
  }
}
