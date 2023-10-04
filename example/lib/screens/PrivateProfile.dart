// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:jwt_decoder/jwt_decoder.dart';
//import 'package:websafe_svg/websafe_svg.dart';

// Project imports:
import 'package:fluttersolidencrypt/models/Constants.dart';
import 'package:fluttersolidencrypt/screens/ProfileInfo.dart';
import 'package:fluttersolidencrypt/components/Header.dart';
import 'package:fluttersolidencrypt/models/SolidApi.dart' as rest_api;
import 'package:solid_auth/solid_auth.dart';
import 'package:fluttersolidencrypt/models/GetRdfData.dart';
import 'package:solid_encrypt/solid_encrypt.dart';

class PrivateProfile extends StatefulWidget {
  final Map authData; // Authentication data
  final String webId; // User WebId
  EncryptClient encryptClient;

  PrivateProfile(
      {Key? key,
      required this.authData,
      required this.webId,
      required this.encryptClient})
      : super(key: key);

  @override
  State<PrivateProfile> createState() => _PrivateProfileState();
}

class _PrivateProfileState extends State<PrivateProfile> {
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

  Widget _loadedScreen(Object profInfo, String webId, String logoutUrl,
      Map authData, EncryptClient encryptClient) {
    // Read profile info from the turtle file
    PodProfile podProfile = PodProfile(profInfo.toString());

    String profPic =
        podProfile.getProfPicture(); // Get the url for profile picture
    String profName = podProfile.getProfName(); // Get name
    String profDob = podProfile.getPersonalInfo('bday'); // Get birthday
    String profOcc = podProfile.getPersonalInfo('role'); // Get occupation
    String profOrg =
        podProfile.getPersonalInfo('organization-name'); // Get organisation
    String profCoun = podProfile.getPersonalInfo('country-name'); // Get country
    String profReg = podProfile.getPersonalInfo('region'); // Get state
    String profAddId =
        podProfile.getAddressId('hasAddress'); // Get hasAddress flag

    // Set up correct profile picture url
    String picUrl = webId;
    if (profPic.contains('http')) {
      picUrl = profPic;
    } else {
      if (profPic != '') {
        picUrl = picUrl.replaceAll('card#me', profPic);
      } else {
        picUrl =
            'https://t4.ftcdn.net/jpg/00/64/67/63/360_F_64676383_LdbmhiNM6Ypzb3FM4PPuFP9rHe7ri8Ju.jpg';
      }
    }

    // Store profile data in a dictionary
    Map profData = {
      'name': profName,
      'picUrl': picUrl,
      'dob': profDob,
      'occ': profOcc,
      'org': profOrg,
      'loc': profCoun,
    };

    // Load profile info screen
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
                child: ProfileInfo(
                    profData: profData,
                    profType: 'private',
                    webId: webId,
                    authData: authData,
                    encryptClient: encryptClient)),
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

    var rsaInfo = authData['rsaInfo'];
    var rsaKeyPair = rsaInfo['rsa'];
    var publicKeyJwk = rsaInfo['pubKeyJwk'];

    String accessToken = authData['accessToken'];
    Map<String, dynamic> decodedToken = JwtDecoder.decode(accessToken);

    // Get profile
    String profCardUrl = webId.replaceAll('#me', '');
    String dPopToken =
        genDpopToken(profCardUrl, rsaKeyPair, publicKeyJwk, 'GET');

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
            future:
                rest_api.fetchPrvProfile(profCardUrl, accessToken, dPopToken),
            builder: (context, snapshot) {
              Widget returnVal;
              if (snapshot.connectionState == ConnectionState.done) {
                returnVal = _loadedScreen(snapshot.data!, webId, logoutUrl,
                    authData, widget.encryptClient);
              } else {
                returnVal = _loadingScreen();
              }
              return returnVal;
            }),
      ),
    );
  }
}
