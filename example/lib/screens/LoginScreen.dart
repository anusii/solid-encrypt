// Flutter imports:
import 'package:flutter/material.dart';
import 'package:solid_encrypt/solid_encrypt.dart';

// Package imports:
import 'package:url_launcher/url_launcher.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

// Project imports:
import 'package:fluttersolidauth/models/Constants.dart';
import 'package:fluttersolidauth/screens/PrivateScreen.dart';
import 'package:fluttersolidauth/screens/PublicScreen.dart';
//import 'package:fluttersolidauth/models/RestAPI.dart';
//import 'package:solid_auth/solid_auth.dart';
import 'package:solid_auth/solid_auth.dart';

class LoginScreen extends StatelessWidget {
  // Sample web ID to check the functionality
  //var webIdController = TextEditingController()..text = 'https://charlieb.solidcommunity.net/profile/card#me';
  var webIdController = TextEditingController()
    ..text = 'https://solid.udula.net.au/charlie_bruegel/profile/card#me';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
            child: Container(
      decoration: screenWidth(context) < 1175
          ? BoxDecoration(
              image: DecorationImage(
                  image: AssetImage('assets/images/background.jpg'),
                  fit: BoxFit.cover))
          : null,
      child: Row(
        children: [
          screenWidth(context) < 1175
              ? Container()
              : Expanded(
                  flex: 7,
                  child: Container(
                    decoration: BoxDecoration(
                        image: DecorationImage(
                            image: AssetImage('assets/images/background.jpg'),
                            fit: BoxFit.cover)),
                  )),
          Expanded(
              flex: 5,
              child: Container(
                margin: EdgeInsets.symmetric(
                    horizontal: screenWidth(context) < 1175
                        ? screenWidth(context) < 750
                            ? screenWidth(context) * 0.05
                            : screenWidth(context) * 0.25
                        : screenWidth(context) * 0.05),
                child: SingleChildScrollView(
                  child: Card(
                    elevation: 5,
                    color: bgOffWhite,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                    child: Container(
                      height: 910,
                      padding: EdgeInsets.all(30),
                      child: Column(
                        children: [
                          Image.asset(
                            "assets/images/authentication-logo.png",
                            width: 400,
                          ),
                          SizedBox(
                            height: 0.0,
                          ),
                          Divider(height: 15, thickness: 2),
                          SizedBox(
                            height: 60.0,
                          ),
                          Text('FLUTTER SOID AUTHENTICATION',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                color: Colors.black,
                              )),
                          SizedBox(
                            height: 20.0,
                          ),
                          TextFormField(
                            controller: webIdController,
                            decoration: InputDecoration(
                              border: UnderlineInputBorder(),
                            ),
                          ),
                          SizedBox(
                            height: 20.0,
                          ),
                          createSolidLoginRow(context, webIdController),
                          SizedBox(
                            height: 20.0,
                          ),
                          Text('OR',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Colors.black,
                              )),
                          SizedBox(
                            height: 20.0,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Expanded(
                                  child: TextButton(
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.all(20),
                                  backgroundColor: lightGold,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => PublicScreen(
                                              webId: webIdController.text,
                                            )),
                                  );
                                },
                                child: Text(
                                  'READ PUBLIC INFO',
                                  style: TextStyle(
                                    color: Colors.white,
                                    letterSpacing: 2.0,
                                    fontSize: 15.0,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                              )),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              )),
        ],
      ),
    )));
  }

  // POD issuer registration page launch
  launchIssuerReg(String _issuerUri) async {
    var url = '$_issuerUri/register';

    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  // Create login row for SOLID POD issuer
  Row createSolidLoginRow(
      BuildContext context, TextEditingController _webIdTextController) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Expanded(
            child: TextButton(
          style: TextButton.styleFrom(
            padding: EdgeInsets.all(20),
            backgroundColor: exLightBlue,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onPressed: () async => launchIssuerReg(
              (await getIssuer(_webIdTextController.text)).toString()),
          child: Text(
            'GET A POD',
            style: TextStyle(
              color: titleAsh,
              letterSpacing: 2.0,
              fontSize: 15.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        )),
        SizedBox(
          width: 15.0,
        ),
        Expanded(
          child: TextButton(
            style: TextButton.styleFrom(
              padding: EdgeInsets.all(20),
              backgroundColor: lightGold,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () async {
              // Get issuer URI
              String _issuerUri = await getIssuer(_webIdTextController.text);

              // Define scopes. Also possible scopes -> webid, email, api
              final List<String> _scopes = <String>[
                'openid',
                'profile',
                'offline_access',
              ];

              // Authentication process for the POD issuer
              var authData =
                  await authenticate(Uri.parse(_issuerUri), _scopes, context);

              // Decode access token to get the correct webId
              String accessToken = authData['accessToken'];
              Map<String, dynamic> decodedToken =
                  JwtDecoder.decode(accessToken);
              String webId = decodedToken['webid'];

              EncryptClient encryptClient = EncryptClient(authData, webId);

              // Navigate to the profile through main screen
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => PrivateScreen(
                          authData: authData,
                          webId: webId,
                          encryptClient: encryptClient,
                        )),
              );
            },
            child: Text(
              'LOGIN',
              style: TextStyle(
                color: Colors.white,
                letterSpacing: 2.0,
                fontSize: 15.0,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
              ),
            ),
          ),
        ),
      ],
    );
  }
}
