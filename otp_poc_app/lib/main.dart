import 'dart:convert';

import 'package:amplify_authenticator/amplify_authenticator.dart';
import 'package:flutter/material.dart';
// Amplify Flutter Packages
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:otp_poc_app/screens/confirm_otp_screen.dart';
import 'package:otp_poc_app/screens/sign_in_screen.dart';
import 'package:otp_poc_app/utils/auth_scaffold.dart';
import 'package:otp_poc_app/utils/env_utils.dart';

// Generated in previous step
// import 'amplifyconfiguration.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  @override
  initState() {
    super.initState();
    _configureAmplify();
  }

  Future<void> _configureAmplify() async {
    // Add any Amplify plugins you want to use
    final authPlugin = AmplifyAuthCognito();
    await Amplify.addPlugin(authPlugin);

    final (poolId, appClientId, region, _) = await loadEnv();

    final configJson = AmplifyConfig(
      auth: AuthConfig.cognito(
        authenticationFlowType: AuthenticationFlowType.customAuthWithoutSrp,
        usernameAttributes: const [CognitoUserAttributeKey.email],
        userPoolConfig: CognitoUserPoolConfig(
          poolId: poolId,
          appClientId: appClientId,
          region: region,
        ),
      ),
    ).toJson();

    try {
      await Amplify.configure(jsonEncode(configJson));
    } on AmplifyAlreadyConfiguredException {
      safePrint(
          "Tried to reconfigure Amplify; this can occur when your app restarts on Android.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Authenticator(
      authenticatorBuilder: (context, state) {
        switch (state.currentStep) {
          case AuthenticatorStep.signIn:
            return SignInScreen(state: state);
          case AuthenticatorStep.signUp:
            return AuthScaffold(
              title: 'Sign Up',
              builder: (p0) => SignUpForm(),
              footer: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Already have an account?'),
                  TextButton(
                    onPressed: () => state.changeStep(
                      AuthenticatorStep.signIn,
                    ),
                    child: const Text('Sign In'),
                  ),
                ],
              ),
            );
          case AuthenticatorStep.confirmSignInCustomAuth:
            return ConfirmOtpScreen(
              state: state,
            );
          case AuthenticatorStep.confirmSignUp:
            return AuthScaffold(
              title: 'Confirm Your Account',
              builder: (p0) => ConfirmSignUpForm(),
            );
          case AuthenticatorStep.resetPassword:
            return AuthScaffold(
              title: 'Reset Your Passsword',
              builder: (p0) => ResetPasswordForm(),
            );
          case AuthenticatorStep.confirmResetPassword:
            return AuthScaffold(
              title: 'Enter Your Code',
              builder: (p0) => const ConfirmResetPasswordForm(),
            );
          default:
            return null;
        }
      },
      child: MaterialApp(
        title: 'Amplify Demo',
        theme: ThemeData.dark(),
        builder: Authenticator.builder(),
        home: const Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Amplify Demo'),
                SignOutButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
