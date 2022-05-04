library solid_encrypt;

/// Dart imports:
import 'dart:async';
import 'dart:convert';

/// Package imports:
import 'package:solid_auth/solid_auth.dart';
import 'package:encrypt/encrypt.dart';
import 'package:crypto/crypto.dart';
import 'package:localstorage/localstorage.dart';

/// Project imports:
import 'package:solid_encrypt/src/rdf_data.dart';

part 'enc_client.dart';
part 'key_hash.dart';

/// Local storage instance
final LocalStorage appStorage = LocalStorage('app_storage');