// Flutter imports:
import 'package:flutter/material.dart';
import 'package:fluttersolidencrypt/screens/PrivateScreen.dart';

// Project imports:
import 'package:fluttersolidencrypt/models/Constants.dart';
import 'package:fluttersolidencrypt/components/Header.dart';
import 'package:fluttersolidencrypt/models/SolidApi.dart' as rest_api;

import 'package:solid_encrypt/solid_encrypt.dart';

class EncSingleVal extends StatefulWidget {
  final Map authData; // Authentication data
  final String webId; // User WebId
  final String currPath;
  EncryptClient encryptClient;
  final String action;

  EncSingleVal(
      {Key? key,
      required this.authData,
      required this.webId,
      required this.action,
      required this.currPath,
      required this.encryptClient})
      : super(key: key);

  @override
  State<EncSingleVal> createState() => _EncSingleValState();
}

class _EncSingleValState extends State<EncSingleVal> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Loading widget
  Widget _loadingScreen() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        new Container(
          alignment: AlignmentDirectional.center,
          decoration: new BoxDecoration(
            color: backgroundWhite,
          ),
          child: new Container(
            decoration: new BoxDecoration(
                color: lightGold,
                borderRadius: new BorderRadius.circular(25.0)),
            width: 300.0,
            height: 200.0,
            alignment: AlignmentDirectional.center,
            child: new Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                new Center(
                  child: new SizedBox(
                    height: 50.0,
                    width: 50.0,
                    child: new CircularProgressIndicator(
                      value: null,
                      color: backgroundWhite,
                      strokeWidth: 7.0,
                    ),
                  ),
                ),
                new Container(
                  margin: const EdgeInsets.only(top: 25.0),
                  child: new Center(
                    child: new Text(
                      "Loading.. Please wait!",
                      style: new TextStyle(fontSize: 20, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _loadedScreen(List filesList, String webId, String logoutUrl,
      Map authData, String currUrl) {
    // Load profile info screen
    TextEditingController _inputValController = TextEditingController();
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          Header(mainDrawer: _scaffoldKey, logoutUrl: logoutUrl),
          Divider(thickness: 1),
          Expanded(
            child: SingleChildScrollView(
              controller: ScrollController(),
              padding: EdgeInsets.all(kDefaultPadding * 1.5),
              child: Column(
                children: [
                  Text("Encrypt and Decrypt a custom value",
                      style:
                          TextStyle(fontSize: 25, fontWeight: FontWeight.w700)),
                  SizedBox(
                    height: 20,
                  ),
                  TextField(
                    controller: _inputValController,
                    maxLines: 7,
                    obscureText: false,
                    decoration: InputDecoration(hintText: "Enter your value"),
                    onSubmitted: (value) async {
                      return;
                    },
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                    ElevatedButton(
                        onPressed: () async {
                          // Get file content
                          String inputVal = _inputValController.text;

                          if (inputVal.isEmpty) {
                            _showErrDialog(context,
                                'Your value should be non-empty', 'ERROR!');
                          } else {
                            // Get encryption key that is stored in the local storage
                            String encKey = appStorage.getItem('encKey');

                            // Encrypt the plaintext
                            List encryptRes = widget.encryptClient
                                .encryptVal(encKey, inputVal);

                            String encryptVal = encryptRes[0];
                            String ivVal = encryptRes[1];

                            // Decrypt the ciphertext
                            String decryptVal = widget.encryptClient
                                .decryptVal(encKey, encryptVal, ivVal);

                            _showEcryptDataDialog(
                                context, encryptVal, decryptVal);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: lightGold, // background
                            foregroundColor: Colors.white, // foreground
                            padding: EdgeInsets.symmetric(horizontal: 50),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10))),
                        child: Text(
                          "Encrypt & Decrypt",
                          style: TextStyle(
                            color: Colors.white,
                            letterSpacing: 2.0,
                            fontSize: 15.0,
                            fontWeight: FontWeight.bold,
                          ),
                        )),
                    SizedBox(
                      width: 10,
                    ),
                    ElevatedButton(
                      child: Text(
                        'Go Back',
                        style: TextStyle(
                          color: Colors.white,
                          letterSpacing: 2.0,
                          fontSize: 15.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => PrivateScreen(
                                    authData: authData,
                                    webId: webId,
                                    encryptClient: widget.encryptClient,
                                  )),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: lightGold, // background
                          foregroundColor: Colors.white, // foreground
                          padding: EdgeInsets.symmetric(horizontal: 50),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10))),
                    ),
                  ]),
                  Row(
                    children: <Widget>[],
                  ),
                ],
              ),
              // FilesInfo(
              //     fileData: filesList,
              //     profType: 'private',
              //     webId: webId,
              //     authData: authData,
              //     currUrl: currUrl,
              //     encFileList: encFileList,
              //     encryptClient: widget.encryptClient)
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Map authData = widget.authData;
    String webId = widget.webId;
    String logoutUrl = authData['logoutUrl'];

    return Scaffold(
      key: _scaffoldKey,
      // drawer: ConstrainedBox(
      //   constraints: BoxConstraints(maxWidth: 300),
      //   child: SideMenu(authData: authData, webId: webId)
      // ),
      // endDrawer: ConstrainedBox(
      //   constraints: BoxConstraints(maxWidth: 400),
      //   child: ListOfSurveys(authData: authData, webId: webId)
      // ),
      body: SafeArea(
        child: FutureBuilder(
            future: rest_api.getContainerList(authData, widget.currPath),
            builder: (context, snapshot) {
              Widget returnVal;
              if (snapshot.connectionState == ConnectionState.done) {
                returnVal = _loadedScreen(snapshot.data as List<dynamic>, webId,
                    logoutUrl, authData, widget.currPath);
              } else {
                returnVal = _loadingScreen();
              }
              return returnVal;
            }),
      ),
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

  Future<void> _showEcryptDataDialog(
      context, String encryptData, String decryptData) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          //backgroundColor: Color.fromARGB(255, 250, 129, 129),
          title: Text('Results'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  'Encrypted value:',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(encryptData),
                Text(
                  '\nDecrypted value:',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(decryptData),
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
