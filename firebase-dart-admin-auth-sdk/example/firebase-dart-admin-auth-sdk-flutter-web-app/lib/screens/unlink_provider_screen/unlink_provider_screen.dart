// ignore_for_file: public_member_api_docs, uri_does_not_exist, undefined_class, undefined_function, undefined_identifier, undefined_method, undefined_getter, creation_with_non_type, extends_non_class, super_formal_parameter_without_associated_named, undefined_super_member, override_on_non_overriding_member, non_type_as_type_argument, non_constant_list_element, unchecked_use_of_nullable_value
import 'package:firebase/screens/unlink_provider_screen/unlink_provider_screen_view_model.dart';
import 'package:firebase/shared/shared.dart';
import 'package:firebase/utils/extensions.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// A screen for unlinking authentication providers.
class UnlinkProviderScreen extends StatelessWidget {
  /// Constructs the [UnlinkProviderScreen] widget.
  const UnlinkProviderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => UnlinkProviderScreenViewModel(),
      child: Consumer<UnlinkProviderScreenViewModel>(
        builder: (context, value, child) => Scaffold(
          body: Padding(
            padding: 20.horizontal,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Button(
                  loading: value.loading,
                  onTap: () => value.unLinkProvider('google.com'),
                  title: 'Google',
                ),
                20.vSpace,
                Button(
                  loading: value.loading,
                  onTap: () => value.unLinkProvider('apple.com'),
                  title: 'Apple',
                ),
                20.vSpace,
                Button(
                  loading: value.loading,
                  onTap: () => value.unLinkProvider('facebook.com'),
                  title: 'Facebook',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
