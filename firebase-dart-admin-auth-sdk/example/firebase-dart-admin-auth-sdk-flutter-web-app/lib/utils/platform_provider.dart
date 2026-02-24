// ignore_for_file: public_member_api_docs, uri_does_not_exist, undefined_class, undefined_function, undefined_identifier, undefined_method, undefined_getter, creation_with_non_type, extends_non_class, super_formal_parameter_without_associated_named, undefined_super_member, override_on_non_overriding_member, non_type_as_type_argument, non_constant_list_element, unchecked_use_of_nullable_value
import 'dart:io';

String getPlatformId() {
  if (Platform.isAndroid) {
    return 'google.com';
  }
  if (Platform.isIOS) {
    return 'apple.com';
  }
  return 'google.com';
}
