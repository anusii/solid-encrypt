// Flutter imports:
import 'package:flutter/material.dart';
import 'package:fluttersolidencrypt/screens/encryption/FilesInfo.dart';

// Project imports:
import 'package:fluttersolidencrypt/models/Constants.dart';
import 'package:fluttersolidencrypt/components/Header.dart';
import 'package:fluttersolidencrypt/models/SolidApi.dart' as rest_api;
import 'package:solid_encrypt/solid_encrypt.dart';

class EncProfile extends StatefulWidget {
  final Map authData; // Authentication data
  final String webId; // User WebId
  final String currPath;
  final List encFileList;
  EncryptClient encryptClient;
  final String action;

  EncProfile(
      {Key? key,
      required this.authData,
      required this.webId,
      required this.action,
      required this.encFileList,
      required this.currPath,
      required this.encryptClient})
      : super(key: key);

  @override
  State<EncProfile> createState() => _EncProfileState();
}

class _EncProfileState extends State<EncProfile> {
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
      Map authData, String currUrl, List encFileList) {
    // List<String> containerList = filesList[0];
    // List<String> resourceList = filesList[1];

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
                child: FilesInfo(
                    fileData: filesList,
                    profType: 'private',
                    webId: webId,
                    authData: authData,
                    currUrl: currUrl,
                    encFileList: encFileList,
                    encryptClient: widget.encryptClient)),
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
                    logoutUrl, authData, widget.currPath, widget.encFileList);
              } else {
                returnVal = _loadingScreen();
              }
              return returnVal;
            }),

        // Container(
        //   color: Colors.white,
        //   child: Column(
        //     children: [
        //       Header(mainDrawer: _scaffoldKey),
        //       Divider(thickness: 1),
        //       Expanded(
        //         child: SingleChildScrollView(
        //           padding: EdgeInsets.all(kDefaultPadding*1.5),
        //             child: screenWidth(context) > 1250 ?
        //               ProfileDesktop(profName:'Anushka Vidanage')
        //               : ProfileMobile(profName:'Anushka Vidanage')
        //         ),
        //       )
        //     ],
        //   ),
        // ),
      ),
    );
  }
}
