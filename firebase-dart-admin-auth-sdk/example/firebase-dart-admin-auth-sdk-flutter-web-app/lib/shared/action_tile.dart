// ignore_for_file: public_member_api_docs, uri_does_not_exist, undefined_class, undefined_function, undefined_identifier, undefined_method, undefined_getter, creation_with_non_type, extends_non_class, super_formal_parameter_without_associated_named, undefined_super_member, override_on_non_overriding_member, non_type_as_type_argument, non_constant_list_element, unchecked_use_of_nullable_value
import 'package:firebase/utils/extensions.dart';
import 'package:flutter/material.dart';

/// a tile button for actions.
class ActionTile extends StatelessWidget {
  /// The title of the tile.
  final String title;

  /// The callback to invoke when the tile is tapped.
  final VoidCallback onTap;

  /// Indicates whether an operation is currently in progress.
  final bool loading;

  /// Constructs the [ActionTile] widget.
  const ActionTile({
    super.key,
    required this.onTap,
    required this.title,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: 10.all,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.purple),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            loading
                ? const SizedBox(
                    height: 15,
                    width: 15,
                    child: CircularProgressIndicator(),
                  )
                : Text(title),
            const Icon(Icons.arrow_forward_ios, color: Colors.purple),
          ],
        ),
      ),
    );
  }
}
