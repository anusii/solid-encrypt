// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:fluttersolidauth/models/Responsive.dart';
import 'package:fluttersolidauth/screens/PrivateProfile.dart';
import 'package:fluttersolidauth/models/Constants.dart';
import 'package:solid_encrypt/solid_encrypt.dart';

class PrivateScreen extends StatelessWidget {
  Map authData; // Authentication data
  String webId; // User WebId
  EncryptClient encryptClient;
  PrivateScreen(
      {Key key,
      @required this.authData,
      @required this.webId,
      @required this.encryptClient})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Assign loading screen
    var loadingScreen = PrivateProfile(
        authData: authData, webId: webId, encryptClient: encryptClient);

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
