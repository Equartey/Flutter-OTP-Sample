// ignore: avoid_web_libraries_in_flutter
// import 'dart:html';

import 'package:amplify_authenticator/amplify_authenticator.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:otp_poc_app/utils/amplify_auth_x.dart';
import 'package:otp_poc_app/utils/auth_scaffold.dart';
import 'package:otp_poc_app/utils/loading_filled_button.dart';

final _logger = AmplifyLogger().createChild('SignInScreen');

/// The screen displayed when the user is in the Sign In state.
class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key, required this.state});

  final AuthenticatorState state;

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  bool isLoading = false;
  SignInMethod signInMethod = SignInMethod.otp;

  Future<void> confirmSignInOTP(
      BuildContext context, String destination) async {
    print('confirmSignInOTP... $destination');
    setState(() => isLoading = true);
    final snackbar = ScaffoldMessenger.of(context);

    try {
      final result = await Amplify.Auth.sendOtp(
        destination: destination,
        options: SendOtpOptions(
          flow: PasswordlessFlow.signInOrSignUp,
          deliveryMedium: OtpDeliveryMedium.SMS,
        ),
      );

      if (mounted) {
        print(result);
        final destination = result.nextStep.additionalInfo["destination"];
        showInfoSnackBar(snackbar, 'A code has been sent to $destination');
      }
    } on AmplifyException catch (e) {
      _logger.info('Could not sign in: $e');
      if (mounted) {
        showErrorSnackBar(snackbar, 'Unable to sign in ${e.message}');
      }
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: 'Sign In',
      builder: (context) {
        if (signInMethod == SignInMethod.srp) {
          return Column(
            children: [
              SignInForm(),
              const SignInMethodDivider(),
              OutlinedButton(
                onPressed: () {
                  setState(() => signInMethod = SignInMethod.magicLink);
                },
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Sign in with magic link'),
                  ],
                ),
              ),
            ],
          );
        }
        return AuthenticatorForm(
          child: Column(
            children: [
              SignUpFormField.phoneNumber(required: true),
              LoadingFilledButton(
                onPressed: () async {
                  await confirmSignInOTP(
                    context,
                    widget.state.getAttribute(
                      CognitoUserAttributeKey.phoneNumber,
                    )!,
                  );
                  widget.state.changeStep(
                    AuthenticatorStep.confirmSignInCustomAuth,
                  );
                },
                isLoading: isLoading,
                child: const Text('Send OTP Link'),
              ),
              const SignInMethodDivider(),
              OutlinedButton(
                onPressed: () {
                  setState(() => signInMethod = SignInMethod.srp);
                },
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Sign in with password'),
                  ],
                ),
              ),
            ],
          ),
        );
      },
      footer: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Don\'t have an account?'),
          TextButton(
            onPressed: () => widget.state.changeStep(
              AuthenticatorStep.signUp,
            ),
            child: const Text('Sign Up'),
          ),
        ],
      ),
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
