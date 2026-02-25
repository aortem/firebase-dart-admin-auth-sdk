// ignore_for_file: public_member_api_docs, uri_does_not_exist, undefined_class, undefined_function, undefined_identifier, undefined_method, undefined_getter, creation_with_non_type, extends_non_class, super_formal_parameter_without_associated_named, undefined_super_member, override_on_non_overriding_member, non_type_as_type_argument, non_constant_list_element, unchecked_use_of_nullable_value

/// Defines the available persistence types for Firebase Auth.
class FirebasePersistence {
  /// Local persistence (tokens persisted in local storage).
  static const String local = 'local';

  /// Session persistence (tokens persisted in session storage).
  static const String session = 'session';

  /// No persistence (tokens not persisted).
  static const String none = 'none';
}
