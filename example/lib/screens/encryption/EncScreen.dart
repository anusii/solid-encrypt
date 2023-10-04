// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:fluttersolidencrypt/models/Responsive.dart';
import 'package:fluttersolidencrypt/screens/PrivateProfile.dart';
import 'package:fluttersolidencrypt/models/Constants.dart';
import 'package:fluttersolidencrypt/screens/encryption/EncProfile.dart';
import 'package:fluttersolidencrypt/screens/encryption/encSingleVal.dart';
import 'package:solid_encrypt/solid_encrypt.dart';

class EncScreen extends StatelessWidget {
  Map authData; // Authentication data
  String webId;
  String currPath;
  List encFileList;
  EncryptClient encryptClient;
  String action; // User WebId
  EncScreen(
      {Key? key,
      required this.authData,
      required this.webId,
      required this.currPath,
      required this.encFileList,
      required this.encryptClient,
      required this.action})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Assign loading screen
    var loadingScreen;
    if (action == 'encryptVal') {
      loadingScreen = EncSingleVal(
          authData: authData,
          webId: webId,
          currPath: currPath,
          action: action,
          encryptClient: encryptClient);
    } else {
      loadingScreen = EncProfile(
          authData: authData,
          webId: webId,
          currPath: currPath,
          encFileList: encFileList,
          action: action,
          encryptClient: encryptClient);
    }

    // Setup Scaffold to be responsive
    return Scaffold(
        body: Responsive(
      mobile: loadingScreen,
      tablet: Row(
        children: [
          Expanded(
            flex: 10,
            child: loadingScreen,
          ),
        ],
      ),
      desktop: Row(
        children: [
          Expanded(
            flex: screenWidth(context) < 1300 ? 10 : 8,
            child: loadingScreen,
          ),
        ],
      ),
    ));
  }
}
