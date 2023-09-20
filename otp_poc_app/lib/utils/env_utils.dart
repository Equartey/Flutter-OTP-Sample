import 'package:flutter_dotenv/flutter_dotenv.dart';
// ignore: depend_on_referenced_packages
import 'package:async/async.dart';

typedef Env = (
  String poolId,
  String appClientId,
  String region,
  Uri preInitiateAuthEndpoint
);
AsyncMemoizer<Env> envMemo = AsyncMemoizer<Env>();

Future<Env> loadEnv() async {
  return envMemo.runOnce(() async {
    await dotenv.load();
    final poolId = dotenv.env['USER_POOL_ID'];
    final appClientId = dotenv.env['APP_CLIENT_ID'];
    final preInitiateAuthEndpoint = dotenv.env['PRE_INITIATE_AUTH_ENDPOINT'];
    if (poolId == null ||
        appClientId == null ||
        preInitiateAuthEndpoint == null) {
      throw StateError(
        'User Pool ID or App Client ID unknown. '
        'Make sure your .env file contains USER_POOL_ID and APP_CLIENT_ID',
      );
    }
    final region = poolId.split('_')[0];
    return (poolId, appClientId, region, Uri.parse(preInitiateAuthEndpoint));
  });
}
