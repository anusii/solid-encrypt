library solid_encrypt;

/// Dart imports:
import 'dart:async';
import 'dart:convert';

/// Package imports:
// import 'package:http/http.dart' as http;
// import 'package:solid_auth/src/openid/openid_client.dart';
// import 'package:solid_auth/src/jwt/dart_jsonwebtoken.dart';
// import 'package:uuid/uuid.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'package:fast_rsa/fast_rsa.dart';
import 'package:solid_auth/solid_auth.dart';
import 'package:encrypt/encrypt.dart';
import 'package:crypto/crypto.dart';
import 'package:localstorage/localstorage.dart';

/// Project imports:
import 'package:solid_encrypt/src/rdf_data.dart';
//import 'package:solid_auth/platform_info.dart';
//import 'package:solid_auth/src/openid/openid_client_io.dart' as oidc_mobile;
//import 'package:solid_auth/src/auth_manager/auth_manager_abstract.dart';

part 'enc_client.dart';
part 'key_hash.dart';

///Local storage instance
final LocalStorage APP_STORAGE = new LocalStorage('app_storage');