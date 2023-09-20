import 'package:flutter/material.dart';

/// A Filled button that displays a loading state
class LoadingFilledButton extends StatelessWidget {
  const LoadingFilledButton({
    super.key,
    this.isLoading = false,
    required this.onPressed,
    required this.child,
  });

  final bool isLoading;
  final void Function() onPressed;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: isLoading ? null : onPressed,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (isLoading)
            const SizedBox(
                height: 20, width: 20, child: CircularProgressIndicator()),
          if (!isLoading) child,
        ],
      ),
    );
  }
}
