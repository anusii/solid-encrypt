<!-- 
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/guides/libraries/writing-package-pages). 

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-library-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/developing-packages). 
-->

# Solid Encrypt

Solid Encrypt is an implementation of data encryption which can be used 
to encrypt the content in turtle files stored in [Solid PODs](https://solidproject.org/).

The encryption of files works with both Android and Web based client 
applications. The main fucntionalities in the package include set up 
encryption keys, encrypt file content, change/update encryption keys, 
and revoke the encryption.

The strength of this package is that the encryption key is not stored in Solid server, but in local storage. Only the key checksum is saved in the Solid sever.

## Features

* Set up an encryption key for encrypting files in a Solid POD
* Encrypt content of a file in a Solid POD 
* Change the encryption key which will re-encrypt all the encrypted files in the POD
* Revoke the encryption completely which will decrypt all encrypted files and remove the encryption key

## Dependencies

To use the Solid Encrypt package you will also need the [Solid Auth](https://pub.dev/packages/solid_auth) package. This package uses authentication tokens provided by the Solid Auth package to read and write data from and to Solid PODs.

## Usage

To use this package add `solid_encrypt` as a dependency in your `pubspec.yaml` file. 
<!-- An example project that uses `solid_auth` can be found [here](https://github.com/anusii/solid_auth/tree/main/example).-->

### Getting authentication data required for the package

```dart
import 'package:solid_auth/solid_auth.dart';

// Example WebID
String _myWebId = 'https://charlieb.solidcommunity.net/profile/card#me';

// Authentication process for the Solid POD using Solid Auth package
var authData = await authenticate(...);

```

### Setting up an encryption key

```dart
import 'package:solid_auth/solid_encrypt.dart';

// Set up encryption client object
EncryptClient encryptClient = EncryptClient(authData, _myWebId);

// Set up encryption key
String encryptKey = 'my-enc-key';
await encryptClient.setupEncKey(encryptKey);

```

### Encrypting files

```dart
import 'package:solid_auth/solid_encrypt.dart';

// Set up encryption client object
EncryptClient encryptClient = EncryptClient(authData, _myWebId);

// Verify and store the encryption key in local storage
String encryptKey = 'my-enc-key';
await encryptClient.verifyEncKey(encryptKey);

// Encrypt files
String encryptFileLocation = 'private/medical-data';
String encryptFileName = 'vaccination_history.ttl'
await encryptClient.encryptFile(encryptFileLocation, encryptFileName);

```

### Update encryption key

```dart
import 'package:solid_auth/solid_encrypt.dart';

// Set up encryption client object
EncryptClient encryptClient = EncryptClient(authData, _myWebId);

// Define old and new encryption keys
String encryptKeyPrev = 'my-enc-key';
String encryptKeyNew = 'my-new-enc-key';

// Update encryption key
await encryptClient.updateEncKey(encryptKeyPrev, encryptKeyNew);

```

### Revoke encryption

```dart
import 'package:solid_auth/solid_encrypt.dart';

// Set up encryption client object
EncryptClient encryptClient = EncryptClient(authData, _myWebId);

// Define encryption keys
String encryptKey = 'my-enc-key';

// Revoke encryption
await encryptClient.revokeEnc(encryptKey);

```

<!-- 
## Getting started

TODO: List prerequisites and provide or point to information on how to
start using the package.

## Usage

TODO: Include short and useful examples for package users. Add longer examples
to `/example` folder. 

```dart
const like = 'sample';
```

## Additional information

TODO: Tell users more about the package: where to find more information, how to 
contribute to the package, how to file issues, what response they can expect 
from the package authors, and more. -->
