// ignore: avoid_web_libraries_in_flutter
// import 'dart:html';

import 'package:amplify_authenticator/amplify_authenticator.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:otp_poc_app/utils/amplify_auth_x.dart';
import 'package:otp_poc_app/utils/auth_scaffold.dart';
import 'package:otp_poc_app/utils/loading_filled_button.dart';

final _logger = AmplifyLogger().createChild('ConfrimOtp');

/// The screen displayed when the user is in the Sign In state.
class ConfirmOtpScreen extends StatefulWidget {
  const ConfirmOtpScreen({super.key, required this.state});

  final AuthenticatorState state;

  @override
  State<ConfirmOtpScreen> createState() => _ConfirmOtpScreenState();
}

class _ConfirmOtpScreenState extends State<ConfirmOtpScreen> {
  bool isLoading = false;

  Future<void> ConfirmOtp(BuildContext context, String code) async {
    print('ConfirmOtpCode... $code');
    setState(() => isLoading = true);
    final snackbar = ScaffoldMessenger.of(context);

    try {
      SignInResult result = await Amplify.Auth.confirmOtp(
        code: code,
      );

      if (mounted) {
        print('ConfirmOtpCode result: $result');
        if (result.nextStep.additionalInfo["errorCode"] ==
            'CodeMismatchException') {
          showErrorSnackBar(snackbar, 'Incorrect code, try again!');
        } else {
          showInfoSnackBar(snackbar, 'Code verified successfully!');
        }
      }
    } on AmplifyException catch (e) {
      _logger.info('Could not sign in: $e');
      if (mounted) {
        showErrorSnackBar(snackbar, '${e.message}');
      }
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: 'Confirm your OTP',
      builder: (context) {
        return AuthenticatorForm(
          child: Column(
            children: [
              ConfirmSignInFormField.verificationCode(),
              LoadingFilledButton(
                onPressed: () => ConfirmOtp(
                  context,
                  widget.state.confirmationCode,
                ),
                isLoading: isLoading,
                child: const Text('Send OTP Link'),
              ),
              BackToSignInButton(),
            ],
          ),
        );
      },
    );
  }
}

enum SignInMethod {
  srp,
  magicLink,
  otp,
}

void showInfoSnackBar(ScaffoldMessengerState snackbar, String message) {
  snackbar.showSnackBar(SnackBar(
    backgroundColor: Colors.blue[800],
    content: Text(message),
  ));
}

void showErrorSnackBar(ScaffoldMessengerState snackbar, String message) {
  snackbar.showSnackBar(SnackBar(
    backgroundColor: Colors.red[900],
    content: Text(message),
  ));
}

class SignInMethodDivider extends StatelessWidget {
  const SignInMethodDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        SizedBox(height: 12),
        Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(child: Divider()),
            SizedBox(width: 8),
            Text('or'),
            SizedBox(width: 8),
            Expanded(child: Divider()),
          ],
        ),
        SizedBox(height: 12),
      ],
    );
  }
}
