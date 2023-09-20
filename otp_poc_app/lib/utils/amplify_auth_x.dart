import 'dart:convert';

import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify_flutter.dart';

import 'env_utils.dart';

final _logger = AmplifyLogger().createChild('Magic Link Auth');

final _client = AWSHttpClient();
final _plugin = Amplify.Auth.getPlugin(AmplifyAuthCognito.pluginKey);

const _codePlaceholder = '##code##';

extension OtpAuth on AuthCategory {
  /// Initiate sign in with otp by sending a code to [phoneNumber] or [email].
  Future<SignInResult> sendOtp({
    required String alias,
    required SendOtpOptions options,
  }) async {
    // if (options.flow != PasswordlessFlow.signIn) {
    //   await _createUser(alias);
    // }
    await _initCustomAuth(alias);
    _logger.info('Custom auth initiated. Sending OTP.');
    final res = await Amplify.Auth.confirmSignIn(
      confirmationValue: '__dummy__', // value will be ignored
      options: ConfirmSignInOptions(
        pluginOptions: CognitoConfirmSignInPluginOptions(
          clientMetadata: {
            'signInMethod': 'OTP',
          },
        ),
      ),
    );
    return res;
  }

  /// Sign a user in with a magic link.
  Future<SignInResult> confirmOtp({
    required String code,
    required String phone,
  }) async {
    await Amplify.asyncConfig;
    await _initCustomAuth(phone);
    _logger.info('Custom auth initiated. Signing in with otp.');
    return Amplify.Auth.confirmSignIn(
      confirmationValue: code,
      options: const ConfirmSignInOptions(
        pluginOptions: CognitoConfirmSignInPluginOptions(
          clientMetadata: {
            'signInMethod': 'OTP',
          },
        ),
      ),
    );
  }
}

/// Initiate a custom auth flow for [username].
Future<SignInResult> _initCustomAuth(String username) {
  print('initCustomAuth... $username');
  return Amplify.Auth.signIn(
    username: username,
    options: const SignInOptions(
      pluginOptions: CognitoSignInPluginOptions(
        authFlowType: AuthenticationFlowType.customAuthWithoutSrp,
      ),
    ),
  );
}

/// Attempts to create the user by calling the pre-auth lambda.
Future<void> _createUser(String username) async {
  print('createUser... $username');
  // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
  CognitoUserPoolConfig userPoolConfig = _plugin.stateMachine.expect();
  final body = utf8.encode(
    jsonEncode({
      'userPoolId': userPoolConfig.poolId,
      'region': userPoolConfig.region,
      'user': {
        'phone': username,
      }
    }),
  );
  final (_, _, _, uri) = await loadEnv();
  final request = AWSHttpRequest.post(uri, body: body);
  final op = _client.send(request);
  final response = await op.response;
  safePrint('createUser response: ${await response.decodeBody()}');
}

class SendOtpOptions {
  const SendOtpOptions({
    this.otpLength = 6,
    this.flow = PasswordlessFlow.signIn,
  });

  final int otpLength;

  /// Whether or not a new user should be created if one does not already exist.
  final PasswordlessFlow flow;
}

enum SignInCodeType { magicLink, otp }

enum PasswordlessFlow {
  // Used to initiate a passwordless sign in flow. If the user does not exist, an error will be returned.
  signIn,
  // Used to initiate a passwordless sign up flow. If the user already exists, an error will be returned.
  signUp,
  // Used to initiate a passwordless sign in OR sign up flow. If a user with the given username does not
  // already exist, the user will be created.
  signInOrSignUp,
}
