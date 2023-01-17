part of solid_encrypt;

//var http;

/// Encryption file/directory naming
String encKeyFileDir = 'encryption';
String encKeyFileName = 'enc-keys.ttl';
String encKeyFileLoc = '$encKeyFileDir/$encKeyFileName';

/// Predicates used in the library
String encKeyPred = 'http://yarrabah.net/predicates/terms#encKey';
String encValPred = 'http://yarrabah.net/predicates/terms#encVal';
String encFilePred = 'http://yarrabah.net/predicates/terms#encFiles';

/// Default body content of directory and file
String dirBody = '<> <http://purl.org/dc/terms/title> "Basic container" .';
String fileBoby = '<> <http://purl.org/dc/terms/title> "Basic resource" .';

class EncryptClient {
  Map authData = {};
  String webId = '';
  dynamic rsaInfo;
  dynamic rsaKeyPair;
  dynamic publicKeyJwk;
  dynamic accessToken;

  EncryptClient(this.authData, this.webId) {
    rsaInfo = authData['rsaInfo'];
    rsaKeyPair = rsaInfo['rsa'];
    publicKeyJwk = rsaInfo['pubKeyJwk'];
    accessToken = authData['accessToken'];
  }

  /// Set up encryption key by creating a directory and a ttl file to store the key
  Future<String> setupEncKey(String plainEncKey) async {
    String sha224Result =
        sha224.convert(utf8.encode(plainEncKey)).toString().substring(0, 32);
    String sha256Result =
        sha256.convert(utf8.encode(plainEncKey)).toString().substring(0, 32);

    /// Create a directory
    var dirCreateRes = await createItem(false, encKeyFileDir, dirBody);

    /// Create a ttl file to store the key
    String subUrl =
        webId.replaceAll('profile/card#me', '$encKeyFileDir/$encKeyFileName');
    String keyFileBody =
        '<$subUrl> <http://purl.org/dc/terms/title> "Encryption keys";' +
            '\n    <$encKeyPred> "$sha224Result";' +
            '\n    <$encFilePred> "".';
    var fileCreateRes = await createItem(true, encKeyFileName, keyFileBody,
        fileLoc: encKeyFileDir);

    if (fileCreateRes == 'ok' && dirCreateRes == 'ok') {
      /// Set encryption key in the local storage
      setEncKeyStorage(sha256Result);
      return fileCreateRes;
    } else {
      throw Exception('Failed to set up encryption key.');
    }
  }

  /// Check if an encryption key is setup
  Future<bool> checkEncSetup() async {
    /// Get encryption key file from URL
    try {
      await fetchFile(encKeyFileLoc);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Encrypt a file content
  /// The function takes all the content in a file and encrypt them using the key
  /// and store the ciphertext in the same file
  Future<void> encryptFile(String filePath, String fileName) async {
    /// Encryption file URL
    String encFileUrl =
        webId.replaceAll('profile/card#me', filePath + '/' + fileName);

    /// Get plaintext file content
    String fileContent = await fetchFile(filePath + '/' + fileName);

    /// Get encryption key that is stored in the local storage
    String encKey = appStorage.getItem('encKey');

    /// Encrypt the plaintext file content
    String encryptValStr = encryptVal(encKey, fileContent);

    /// Delete the existing file with plaintext and create a new file with ciphertext
    String delResponse = await deleteItem(false, filePath + '/' + fileName);

    if (delResponse == 'ok') {
      String dPopToken =
          genDpopToken(encFileUrl, rsaKeyPair, publicKeyJwk, 'PATCH');
      String insertQuery =
          genSparqlQuery('INSERT', '', encValPred, encryptValStr);
      String insertResponse =
          await runQuery(encFileUrl, dPopToken, insertQuery);

      if (insertResponse == 'ok') {
        /// Get the list of locations of files that are encrypted
        var keyInfo = await fetchFile(encKeyFileLoc);
        EncProfile keyFile = EncProfile(keyInfo.toString());
        String encFileHash = keyFile.getEncFileHash();

        String fileListStr = '';

        /// New list of locations
        if (encFileHash.isEmpty) {
          List fileList = ['$filePath/$fileName'];
          fileListStr = jsonEncode(fileList);
        } else {
          String encFilePlaintext = decryptVal(encKey, encFileHash);
          List fileList = jsonDecode(encFilePlaintext);
          fileList.add('$filePath/$fileName');
          fileListStr = jsonEncode(fileList);
        }

        /// Update the list of encrypted file locations in the server
        if (fileListStr.isNotEmpty) {
          String encKeyFileUrl =
              webId.replaceAll('profile/card#me', encKeyFileLoc);
          String fileListStrEnc = encryptVal(encKey, fileListStr);
          String dPopToken =
              genDpopToken(encKeyFileUrl, rsaKeyPair, publicKeyJwk, 'PATCH');

          String updateQuery = genSparqlQuery(
              'UPDATE', '', encFilePred, fileListStrEnc,
              prevObject: encFileHash);

          String updateResponse =
              await runQuery(encKeyFileUrl, dPopToken, updateQuery);

          if (updateResponse != 'ok') {
            throw Exception('Failed to update encrypted file locations.');
          }
        }
      } else {
        throw Exception('Failed to encrypt the file.');
      }
    } else {
      throw Exception('Failed to delete the file! Try again in a while.');
    }
  }

  /// Decrypt a file content
  /// The function takes ciphertext in an encrypted file, decrypt them using the key,
  /// and store the plaintext in the same file
  Future<void> decryptFile(String filePath, String fileName) async {
    /// Encrypted file URL
    //String encFileUrl = webId.replaceAll('profile/card#me', filePath + '/' + fileName);

    /// Get ciphertext file content
    String encFilePath = filePath + '/' + fileName;
    String fileContent = await fetchFile(encFilePath);
    EncProfile encFile = EncProfile(fileContent.toString());
    String encFileCont = encFile.getEncFileCont();

    /// Get encryption key that is stored in the local storage
    String encKey = appStorage.getItem('encKey');

    /// Decrypt the ciphertext
    String plainFileCont = decryptVal(encKey, encFileCont);

    /// Get the list of locations of files that are encrypted
    var keyInfo = await fetchFile(encKeyFileLoc);
    EncProfile keyFile = EncProfile(keyInfo.toString());
    String encFileHash = keyFile.getEncFileHash();
    String encFilePlaintext = decryptVal(encKey, encFileHash);
    List encFileList = jsonDecode(encFilePlaintext);

    /// Delete the encrypted file
    String delResponse = await deleteItem(true, encFilePath);

    /// Create new file with plaintext content
    String fileCreateRes =
        await createItem(true, fileName, plainFileCont, fileLoc: filePath);

    /// Update the list of encrypted files
    encFileList.remove(encFilePath);
    String newFileListStr = jsonEncode(encFileList);

    String encKeyFileUrl = webId.replaceAll('profile/card#me', encKeyFileLoc);
    String fileListStrEnc = encryptVal(encKey, newFileListStr);
    String dPopToken =
        genDpopToken(encKeyFileUrl, rsaKeyPair, publicKeyJwk, 'PATCH');
    String updateQuery = genSparqlQuery(
        'UPDATE', '', encFilePred, fileListStrEnc,
        prevObject: encFileHash);

    String updateResponse =
        await runQuery(encKeyFileUrl, dPopToken, updateQuery);

    if (delResponse != 'ok' ||
        fileCreateRes != 'ok' ||
        updateResponse != 'ok') {
      throw Exception('Failed to revoke encrypted file $encFilePath.');
    }
  }

  /// Update/change encryption key
  /// Need to re-encrypt all the encrypted files using the new key
  Future<String> updateEncKey(
      String plainPrevEncKey, String plainNewEncKey) async {
    /// Verify old encryption key before moving forward
    if (await verifyEncKey(plainPrevEncKey)) {
      /// Create hash values for old and new encrypted keys
      String newKeyHash = sha224
          .convert(utf8.encode(plainNewEncKey))
          .toString()
          .substring(0, 32);
      String newEncKey = sha256
          .convert(utf8.encode(plainNewEncKey))
          .toString()
          .substring(0, 32);
      String prevEncKey = sha256
          .convert(utf8.encode(plainPrevEncKey))
          .toString()
          .substring(0, 32);

      /// Get the previous key and the list of locations of files that are encrypted
      var keyInfo = await fetchFile(encKeyFileLoc);
      EncProfile keyFile = EncProfile(keyInfo.toString());

      String prevKeyHash = keyFile.getEncKeyHash();
      String encFileHash = keyFile.getEncFileHash();

      String encFilePlaintext = decryptVal(prevEncKey, encFileHash);
      List encFileList = jsonDecode(encFilePlaintext);

      /// Loop over each encrypted file and re-encrypt the content using
      /// new encryption key
      for (var i = 0; i < encFileList.length; i++) {
        String encFilePath = encFileList[i];
        var fileInfo = await fetchFile(encFilePath);
        EncProfile encFile = EncProfile(fileInfo.toString());
        String encFileCont = encFile.getEncFileCont();

        String plainFileCont = decryptVal(prevEncKey, encFileCont);
        String newEncFileCont = encryptVal(newEncKey, plainFileCont);

        String encFileUrl = webId.replaceAll('profile/card#me', encFilePath);
        String dPopToken =
            genDpopToken(encFileUrl, rsaKeyPair, publicKeyJwk, 'PATCH');

        String fileUpdateQuery = genSparqlQuery(
            'UPDATE', '', encValPred, newEncFileCont,
            prevObject: encFileCont);

        String fileContupdate =
            await runQuery(encFileUrl, dPopToken, fileUpdateQuery);

        if (fileContupdate == 'ok') {
          continue;
        } else {
          throw Exception('Failed to update encrypted file $encFilePath.');
        }
      }

      /// Update the encryption key hash with new key
      String encKeyUrl = webId.replaceAll('profile/card#me', encKeyFileLoc);
      String dPopToken =
          genDpopToken(encKeyUrl, rsaKeyPair, publicKeyJwk, 'PATCH');

      String updateQuery = genSparqlQuery('UPDATE', '', encKeyPred, newKeyHash,
          prevObject: prevKeyHash);

      String updateResponse = await runQuery(encKeyUrl, dPopToken, updateQuery);

      if (updateResponse == 'ok') {
        /// Update the list of locations of the encrypted files
        String encFileHashNew = encryptVal(newEncKey, encFilePlaintext);
        String dPopToken =
            genDpopToken(encKeyUrl, rsaKeyPair, publicKeyJwk, 'PATCH');

        String updateQuery = genSparqlQuery(
            'UPDATE', '', encFilePred, encFileHashNew,
            prevObject: encFileHash);
        String updateResponse =
            await runQuery(encKeyUrl, dPopToken, updateQuery);

        if (updateResponse == 'ok') {
          removeEncKeyStorage();

          /// Remove previous key from local storage
          setEncKeyStorage(newEncKey);

          /// Set new key to local storage
          return updateResponse;
        } else {
          throw Exception('Failed to update encrypted file locations.');
        }
      } else {
        throw Exception('Failed to update new encryption key.');
      }
    } else {
      throw Exception('Failed to verify the previous encryption key.');
    }
  }

  /// Revoke the encryption. All the encrypted files will be rewritten
  /// with their respective plaintext and the encryption key hashes will be
  /// deleted from the server.
  Future<String> revokeEnc(String plainPrevEncKey) async {
    /// Verify old encryption key before moving forward
    if (await verifyEncKey(plainPrevEncKey)) {
      /// Create hash values for encrypted key
      String encKey = sha256
          .convert(utf8.encode(plainPrevEncKey))
          .toString()
          .substring(0, 32);

      /// Get the list of locations of files that are encrypted
      List encFileList = await getEncFileList();

      /// Loop over each file, decrypt the encrypted values, and write the
      /// plaintext values to the file
      for (var i = 0; i < encFileList.length; i++) {
        String encFilePath = encFileList[i];
        var fileInfo = await fetchFile(encFilePath);
        EncProfile encFile = EncProfile(fileInfo.toString());
        String encFileCont = encFile.getEncFileCont();

        String plainFileCont = decryptVal(encKey, encFileCont);
        String fileName = encFilePath.split('/').last;

        List filePathList = encFilePath.split('/');
        filePathList.remove(filePathList.last);
        String fileDir = filePathList.join('/');

        String delResponse = await deleteItem(true, encFilePath);
        String fileCreateRes =
            await createItem(true, fileName, plainFileCont, fileLoc: fileDir);

        if (delResponse == 'ok' && fileCreateRes == 'ok') {
          continue;
        } else {
          throw Exception('Failed to revoke encrypted file $encFilePath.');
        }
      }

      /// Delete the file which stores the encryption keys
      String delKeyFileRes = await deleteItem(true, encKeyFileLoc);
      String delKeyDirRes = await deleteItem(false, encKeyFileDir + '/');

      if (delKeyFileRes == 'ok' && delKeyDirRes == 'ok') {
        return 'ok';
      } else {
        throw Exception('Failed to delete encryption key file.');
      }
    } else {
      throw Exception('Failed to verify encryption key.');
    }
  }

  /// Get a file content from the server
  Future<String> fetchFile(String fileLoc) async {
    String fileUrl = webId.replaceAll('profile/card#me', fileLoc);
    String dPopToken = genDpopToken(fileUrl, rsaKeyPair, publicKeyJwk, 'GET');

    final profResponse = await http.get(
      Uri.parse(fileUrl),
      headers: <String, String>{
        'Accept': '*/*',
        'Authorization': 'DPoP $accessToken',
        'Connection': 'keep-alive',
        'DPoP': dPopToken,
      },
    );

    if (profResponse.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      return profResponse.body;
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to fetch file content! Try again in a while.');
    }
  }

  /// Run a sparql query
  Future<String> runQuery(
      String queryUrl, String dPopToken, String query) async {
    final editResponse = await http.patch(
      Uri.parse(queryUrl),
      headers: <String, String>{
        'Accept': '*/*',
        'Authorization': 'DPoP $accessToken',
        'Connection': 'keep-alive',
        'Content-Type': 'application/sparql-update',
        'Content-Length': query.length.toString(),
        'DPoP': dPopToken,
      },
      body: query,
    );

    if (editResponse.statusCode == 200 ||
        editResponse.statusCode == 205 ||
        editResponse.statusCode == 201) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      return 'ok';
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to write profile data! Try again in a while.');
    }
  }

  /// Create a directory or a file
  Future<String> createItem(bool fileFlag, String itemName, String itemBody,
      {String? fileLoc}) async {
    String itemLoc = '';
    String itemSlug = '';
    String itemType = '';
    String contentType = '';

    /// Set up directory or file parameters
    if (fileFlag) {
      /// This is a file (resource)
      itemLoc = fileLoc!;
      itemSlug = itemName;
      contentType = 'text/turtle';
      itemType = '<http://www.w3.org/ns/ldp#Resource>; rel="type"';
    } else {
      /// This is a directory (container)
      itemSlug = itemName;
      contentType = 'application/octet-stream';
      itemType = '<http://www.w3.org/ns/ldp#BasicContainer>; rel="type"';
    }

    String encKeyUrl = webId.replaceAll('profile/card#me', itemLoc);
    String dPopToken =
        genDpopToken(encKeyUrl, rsaKeyPair, publicKeyJwk, 'POST');

    /// The POST request will create the item in the server
    final createResponse = await http.post(
      Uri.parse(encKeyUrl),
      headers: <String, String>{
        'Accept': '*/*',
        'Authorization': 'DPoP $accessToken',
        'Connection': 'keep-alive',
        'Content-Type': contentType,
        'Link': itemType,
        'Slug': itemSlug,
        'DPoP': dPopToken,
      },
      body: itemBody,
    );

    if (createResponse.statusCode == 200 || createResponse.statusCode == 201) {
      /// If the server did return a 200 OK response,
      /// then parse the JSON.
      return 'ok';
    } else {
      /// If the server did not return a 200 OK response,
      /// then throw an exception.
      throw Exception('Failed to create folder! Try again in a while.');
    }
  }

  /// Encrypt a plaintext value
  String encryptVal(String encKey, String plaintextVal) {
    final key = Key.fromUtf8(encKey);
    final iv = IV.fromLength(16);
    final encrypter = Encrypter(AES(key));

    final encryptVal = encrypter.encrypt(plaintextVal, iv: iv);
    String encryptValStr = encryptVal.base64.toString();

    return encryptValStr;
  }

  /// Decrypt a ciphertext value
  String decryptVal(String encKey, String encVal) {
    final key = Key.fromUtf8(encKey);
    final iv = IV.fromLength(16);
    final encrypter = Encrypter(AES(key));

    final ecc = Encrypted.from64(encVal);
    final plaintextVal = encrypter.decrypt(ecc, iv: iv);

    return plaintextVal;
  }

  /// Delete a file or a directory
  Future<String> deleteItem(bool fileFlag, String itemLoc) async {
    String contentType = '';

    /// Set up directory or file parameters
    if (fileFlag) {
      /// This is a file (resource)
      contentType = 'text/turtle';
    } else {
      /// This is a directory (container)
      contentType = 'application/octet-stream';
    }

    String encKeyUrl = webId.replaceAll('profile/card#me', itemLoc);
    String dPopToken =
        genDpopToken(encKeyUrl, rsaKeyPair, publicKeyJwk, 'DELETE');

    final createResponse = await http.delete(
      Uri.parse(encKeyUrl),
      headers: <String, String>{
        'Accept': '*/*',
        'Authorization': 'DPoP $accessToken',
        'Connection': 'keep-alive',
        'Content-Type': contentType,
        'DPoP': dPopToken,
      },
    );

    if (createResponse.statusCode == 200 || createResponse.statusCode == 205) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      return 'ok';
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to delete file! Try again in a while.');
    }
  }

  Future<List> getEncFileList() async {
    List encFileList;

    /// Get the encryption key
    String encKey = getEncKeyStorage();

    /// Get the list of locations of files that are encrypted
    var keyInfo = await fetchFile(encKeyFileLoc);

    EncProfile keyFile = EncProfile(keyInfo.toString());
    String encFileHash = keyFile.getEncFileHash();

    if (encFileHash.isEmpty) {
      encFileList = [];
    } else {
      String encFilePlaintext = decryptVal(encKey, encFileHash);
      encFileList = jsonDecode(encFilePlaintext);
    }

    return encFileList;
  }

  /// Encryption key verification with the hash value
  /// stored in the server
  Future<bool> verifyEncKey(String plaintextEncKey) async {
    String sha224Result = sha224
        .convert(utf8.encode(plaintextEncKey))
        .toString()
        .substring(0, 32);
    String sha256Result = sha256
        .convert(utf8.encode(plaintextEncKey))
        .toString()
        .substring(0, 32);

    var keyInfo = await fetchFile(encKeyFileLoc);
    EncProfile keyFile = EncProfile(keyInfo.toString());
    String encKeyHash = keyFile.getEncKeyHash();

    if (encKeyHash != sha224Result) {
      /// If the stored hash value is the same
      return false;
    } else {
      /// If not
      setEncKeyStorage(sha256Result);
      return true;
    }
  }

  /// Store the encryption key in the local storage
  void setEncKeyStorage(String encKey) {
    appStorage.setItem('encKey', encKey);
  }

  /// Check if encryption key is already stored in the
  /// local storage
  bool checkEncKeyStorage() {
    if (appStorage.getItem('encKey') != null) {
      return true;
    } else {
      return false;
    }
  }

  /// Get encryption key
  String getEncKeyStorage() {
    return appStorage.getItem('encKey');
  }

  /// Remove encryption key from the local storage
  void removeEncKeyStorage() {
    appStorage.deleteItem('encKey');
  }
}
