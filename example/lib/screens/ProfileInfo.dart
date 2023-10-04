// Flutter imports:
import 'package:flutter/material.dart';
import 'package:fluttersolidencrypt/screens/PrivateScreen.dart';
import 'package:solid_encrypt/solid_encrypt.dart';

// Project imports:
import 'package:fluttersolidencrypt/models/Constants.dart';
import 'package:fluttersolidencrypt/screens/encryption/EncScreen.dart';

class ProfileInfo extends StatelessWidget {
  final Map profData; // Profile data
  final Map? authData; // Authentication related data
  final String profType; // Public or private
  final String? webId; // WebId of the user
  EncryptClient? encryptClient;

  ProfileInfo(
      {Key? key,
      required this.profData,
      required this.profType,
      this.encryptClient,
      this.authData,
      this.webId})
      : super(key: key);

  TextEditingController _passPhraseController = TextEditingController();
  TextEditingController _repeatPassPhraseController = TextEditingController();
  TextEditingController _encKeyPlaintextController = TextEditingController();

  Future<void> _displayPassPhraseInputDialog(
      BuildContext context, EncryptClient encryptClient) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Setup your secret key value'),
          content: Container(
            height: 100,
            child: Column(
              children: [
                TextField(
                  controller: _passPhraseController,
                  obscureText: true,
                  decoration: InputDecoration(
                      hintText: "Secret key value (case sensitive)"),
                  //onSubmitted: (value) async {

                  // },
                ),
                TextField(
                  controller: _repeatPassPhraseController,
                  obscureText: true,
                  decoration:
                      InputDecoration(hintText: "Repeat your secret key"),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('CANCEL'),
              onPressed: () {
                //APP_STORAGE.deleteItem('encKey');
                Navigator.pop(context);
              },
            ),
            // TextButton(
            //   child: Text('CREATE'),
            //   onPressed: () async {
            //     APP_STORAGE.deleteItem('encKey');

            //     String sha256Result = sha256
            //         .convert(utf8.encode('test-key'))
            //         .toString()
            //         .substring(0, 32);
            //     APP_STORAGE.setItem('encKey', sha256Result);

            //     EncryptClient encryptClient = EncryptClient(authData, webId);

            //     // Create key
            //     //encryptClient.setupEncKey('test-key');

            //     /// Encrypt files
            //     //await encryptClient.encryptFile('encryption-test', 'test_data.ttl');
            //     //await encryptClient.encryptFile('encryption-test', 'test_data2.ttl');

            //     /// Update key
            //     //await encryptClient.updateEncKey('test-key', 'test-key1');

            //     /// Revoke encryption
            //     //await encryptClient.revokeEnc('test-key');

            //     print('ok');
            //   },
            // ),
            TextButton(
              child: Text('SUBMIT'),
              onPressed: () async {
                String passPhrase = _passPhraseController.text;
                String repPassPhrase = _repeatPassPhraseController.text;

                if (passPhrase != repPassPhrase) {
                  _showErrDialog(
                      context, 'Secret key values do not match.', 'ERROR!');
                } else {
                  if (passPhrase.isEmpty && repPassPhrase.isEmpty) {
                    _showErrDialog(context,
                        'Please enter a valid secret key value.', 'ERROR!');
                  } else {
                    // Create key
                    await encryptClient.setupEncKey(passPhrase);
                    Navigator.pop(context);
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<dynamic> _encKeyVerification(BuildContext context,
      EncryptClient encryptClient, bool keyResetFlag) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Encryption key verification!'),
          content: Container(
            height: 100,
            child: Column(
              children: [
                TextField(
                  controller: _encKeyPlaintextController,
                  obscureText: true,
                  decoration:
                      InputDecoration(hintText: "Enter your encryption key"),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('CANCEL'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: Text('SUBMIT'),
              onPressed: () async {
                String encKeyPlaintext = _encKeyPlaintextController.text;
                bool keyVerifyFlag =
                    await encryptClient.verifyEncKey(encKeyPlaintext);

                if (keyVerifyFlag) {
                  if (keyResetFlag) {
                    encryptClient.revokeEnc(encKeyPlaintext);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => PrivateScreen(
                                authData: authData!,
                                webId: webId!,
                                encryptClient: encryptClient,
                              )),
                    );
                  } else {
                    List encFileList = [];
                    encFileList = await encryptClient.getEncFileList();
                    String currPath = webId!.replaceAll('profile/card#me', '');
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => EncScreen(
                                authData: authData!,
                                webId: webId!,
                                currPath: currPath,
                                encFileList: encFileList,
                                encryptClient: encryptClient,
                                action: 'encrypt',
                              )),
                    );
                  }
                } else {
                  _showErrDialog(context, 'Wrong encryption key.', 'ERROR!');
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            children: [
              Stack(
                children: [
                  Container(
                    width: 130,
                    height: 130,
                    decoration: BoxDecoration(
                        border: Border.all(
                          width: 4,
                          color: Theme.of(context).scaffoldBackgroundColor,
                        ),
                        boxShadow: [
                          BoxShadow(
                              spreadRadius: 2,
                              blurRadius: 10,
                              color: Colors.black.withOpacity(0.1),
                              offset: Offset(0, 10))
                        ],
                        shape: BoxShape.circle,
                        image: DecorationImage(
                            fit: BoxFit.cover,
                            image: NetworkImage(profData['picUrl']))),
                  ),
                ],
              ),
              // Display profile data
              SizedBox(
                height: 50,
              ),
              profileMenuItem("BASIC INFORMATION"),
              SizedBox(
                height: 20,
              ),
              buildLabelRow('Name', profData['name']),
              buildLabelRow('Birthday', profData['dob']),
              buildLabelRow('Country', profData['loc']),
              //
              profileMenuItem("WORK"),
              SizedBox(
                height: 20,
              ),
              buildLabelRow('Occupation', profData['occ']),
              buildLabelRow('Organisation', profData['org']),

              SizedBox(
                height: 20,
              ),
              Row(
                children: <Widget>[
                  Expanded(
                    child: ElevatedButton(
                      child: Text('Set Encryption Key'),
                      onPressed: () async {
                        bool checkEncKey = await encryptClient!.checkEncSetup();

                        if (!checkEncKey) {
                          _displayPassPhraseInputDialog(
                              context, encryptClient!);
                        } else {
                          _showErrDialog(context, 'Encryption key already set!',
                              'WARNING!');
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: lightGold, // background
                        foregroundColor: Colors.white, // foreground
                      ),
                    ),
                  ),
                  SizedBox(width: 5),
                  Expanded(
                    child: ElevatedButton(
                      child: Text('Reset Encryption'),
                      onPressed: () async {
                        bool checkEncKey = await encryptClient!.checkEncSetup();

                        if (checkEncKey) {
                          _encKeyVerification(context, encryptClient!, false);
                        } else {
                          _showErrDialog(
                              context, 'No encryption key is set!', 'WARNING!');
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: lightGold, // background
                        foregroundColor: Colors.white, // foreground
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 5,
              ),
              Row(
                children: <Widget>[
                  Expanded(
                    child: ElevatedButton(
                      child: Text('Encrypt/Decrypt Files'),
                      onPressed: () async {
                        bool checkEncKey = await encryptClient!.checkEncSetup();

                        if (checkEncKey) {
                          if (encryptClient!.checkEncKeyStorage()) {
                            List encFileList = [];
                            encFileList = await encryptClient!.getEncFileList();
                            String currPath =
                                webId!.replaceAll('profile/card#me', '');
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => EncScreen(
                                        authData: authData!,
                                        webId: webId!,
                                        currPath: currPath,
                                        encFileList: encFileList,
                                        encryptClient: encryptClient!,
                                        action: 'encrypt',
                                      )),
                            );
                          } else {
                            _encKeyVerification(context, encryptClient!, false);
                          }
                        } else {
                          _showErrDialog(context,
                              'Setup an encryption key first.', 'ERROR!');
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: lightGold, // background
                        foregroundColor: Colors.white, // foreground
                      ),
                    ),
                  ),
                  SizedBox(width: 5),
                  Expanded(
                    child: ElevatedButton(
                      child: Text('Encrypt/Decrypt Values'),
                      onPressed: () async {
                        bool checkEncKey = await encryptClient!.checkEncSetup();

                        if (checkEncKey) {
                          if (encryptClient!.checkEncKeyStorage()) {
                            List encFileList = [];
                            encFileList = await encryptClient!.getEncFileList();
                            String currPath =
                                webId!.replaceAll('profile/card#me', '');
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => EncScreen(
                                        authData: authData!,
                                        webId: webId!,
                                        currPath: currPath,
                                        encFileList: encFileList,
                                        encryptClient: encryptClient!,
                                        action: 'encryptVal',
                                      )),
                            );
                          } else {
                            _encKeyVerification(context, encryptClient!, false);
                          }
                        } else {
                          _showErrDialog(context,
                              'Setup an encryption key first.', 'ERROR!');
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: lightGold, // background
                        foregroundColor: Colors.white, // foreground
                      ),
                    ),
                  ),
                  // SizedBox(width:5),
                  // Expanded(
                  //   child: ElevatedButton(
                  //     child: Text('Decrypt Files'),
                  //     onPressed: () => null,
                  //     style: ElevatedButton.styleFrom(
                  //       primary: lightGold, // background
                  //       onPrimary: Colors.white, // foreground
                  //     ),
                  //   ),
                  // ),
                ],
              ),

              //
            ],
          ),
        ),
      ],
    );
  }

  // A menu item
  Row profileMenuItem(String title) {
    return Row(children: <Widget>[
      Text(
        title,
        style: TextStyle(
          color: lightGray,
          letterSpacing: 2.0,
          fontSize: 12.0,
          fontWeight: FontWeight.bold,
        ),
      ),
      Expanded(
        child: new Container(
            margin: const EdgeInsets.only(left: 10.0, right: 0.0),
            child: Divider(
              color: lightGray,
              height: 36,
            )),
      ),
    ]);
  }

  // A profile info row
  Column buildLabelRow(String labelName, String profName) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              '$labelName:',
              style: TextStyle(
                color: titleAsh,
                letterSpacing: 2.0,
                fontSize: 14.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              profName,
              style: TextStyle(
                color: Colors.grey[800],
                letterSpacing: 2.0,
                fontSize: 14.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        SizedBox(
          height: 30,
        )
      ],
    );
  }

  Future<void> _showErrDialog(context, String errMsg, String errTypeStr) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          //backgroundColor: Color.fromARGB(255, 250, 129, 129),
          title: Text(errTypeStr),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(errMsg),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
