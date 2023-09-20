import 'package:flutter/material.dart';

/// A widget that displays a logo, a body, and an optional footer.
class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    super.key,
    required this.title,
    required this.builder,
    this.footer,
  });

  final String title;

  final Widget Function(BuildContext) builder;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
              child: Column(
                children: [
                  Container(
                    constraints: const BoxConstraints(maxWidth: 500),
                    child: Column(
                      children: [
                        Text(
                          title,
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        builder(context),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      persistentFooterButtons: footer != null ? [footer!] : null,
    );
  }
}
