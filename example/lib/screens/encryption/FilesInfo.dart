// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:fluttersolidencrypt/models/Constants.dart';
import 'package:fluttersolidencrypt/models/SolidApi.dart';
import 'package:fluttersolidencrypt/screens/PrivateScreen.dart';
import 'package:fluttersolidencrypt/screens/encryption/EncScreen.dart';
import 'package:solid_auth/solid_auth.dart';
import 'package:solid_encrypt/solid_encrypt.dart';

class FilesInfo extends StatelessWidget {
  final List fileData; // Profile data
  final Map authData; // Authentication related data
  final String profType; // Public or private
  final String webId;
  final String currUrl; // WebId of the user
  final List encFileList;
  EncryptClient encryptClient;

  FilesInfo(
      {Key? key,
      required this.fileData,
      required this.profType,
      required this.currUrl,
      required this.encFileList,
      required this.encryptClient,
      required this.authData,
      required this.webId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<String> containerList = fileData[0];
    List<String> resourceList = fileData[1];

    String homeUrl = webId.replaceAll('profile/card#me', '');
    String pathStr = currUrl.replaceAll(homeUrl, '');
    List pathList = pathStr.split('/');

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Expanded(
        //   child: Wrap(
        //   //direction: Axis.vertical,
        //   // alignment: WrapAlignment.center,
        //   // spacing:8.0,
        //   // runAlignment:WrapAlignment.center,
        //   // runSpacing: 8.0,
        //   // crossAxisAlignment: WrapCrossAlignment.center,
        //   // textDirection: TextDirection.rtl,
        //   // verticalDirection: VerticalDirection.up,
        //   children: <Widget>[
        //     Container(
        //       child: pathSelector('home', homeUrl, context)),

        //     Container(
        //       child: pathSelector('/', homeUrl, context)),
        //     Container(
        //       color: Colors.orange,
        //       width: 100,
        //       height: 100,
        //       child:Center(child: Text("W5",textScaleFactor: 2.5,))
        //     ),
        //   ],
        //       ),
        // ),

        Expanded(
          child: Column(
            children: [
              Row(children: [
                pathSelector('home', homeUrl, context),
                Text(
                  '/',
                  style: TextStyle(
                    color: lightGray,
                    letterSpacing: 2.0,
                    fontSize: 14.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                for (var i = 0; i < pathList.length; i++) ...[
                  if (pathList[i].isNotEmpty) ...[
                    pathSelector(
                        pathList[i],
                        currUrl.split(pathList[i])[0] + pathList[i] + '/',
                        context),
                    Text(
                      '/',
                      style: TextStyle(
                        color: lightGray,
                        letterSpacing: 2.0,
                        fontSize: 14.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ]
                ],

                // Expanded(
                //   child: new Container(
                //       margin: const EdgeInsets.only(left: 10.0, right: 0.0),
                //       child: Divider(
                //         color: lightGray,
                //         height: 36,
                //       )),
                // ),
              ]),
              SizedBox(
                height: 10,
              ),

              //profileMenuItem("CONTENT"),
              for (var i = 0; i < containerList.length; i++) ...[
                buildContainerRow(
                    containerList[i], currUrl, context, encFileList),
                SizedBox(
                  height: 10,
                ),
              ],

              profileMenuItem(""),
              for (var i = 0; i < resourceList.length; i++) ...[
                buildResourceRow(context, resourceList[i], resourceList[i],
                    currUrl, pathStr, encFileList, encryptClient),
                SizedBox(
                  height: 10,
                ),
              ],

              SizedBox(
                height: 20,
              ),
              Row(
                children: <Widget>[
                  Expanded(
                    child: ElevatedButton(
                      child: Text('Go Back'),
                      onPressed: () {
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
                      style: ElevatedButton.styleFrom(
                        backgroundColor: lightGold, // background
                        foregroundColor: Colors.white, // foreground
                      ),
                    ),
                  ),
                ],
              ),
              //
            ],
          ),
        ),
      ],
    );
  }

  TextButton pathSelector(
      String labeltxt, String newPath, BuildContext context) {
    return TextButton(
      child: Text(
        labeltxt,
        style: TextStyle(
          decoration: TextDecoration.underline,
          color: lightGray,
          letterSpacing: 2.0,
          fontSize: 12.0,
          fontWeight: FontWeight.bold,
        ),
      ),
      style: ElevatedButton.styleFrom(
        minimumSize: Size(20, 25),
      ),
      onPressed: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => EncScreen(
                    authData: authData,
                    webId: webId,
                    currPath: newPath,
                    encFileList: encFileList,
                    encryptClient: encryptClient,
                    action: 'encrypt',
                  )),
        );
      },
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

  // A container info row
  Column buildContainerRow(String containerName, String currPath,
      BuildContext context, List encFileList) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            RichText(
              text: TextSpan(
                children: [
                  WidgetSpan(
                    child: Icon(Icons.folder_open, size: 20),
                  ),
                  TextSpan(
                    text: " $containerName",
                    style: TextStyle(
                      color: titleAsh,
                      letterSpacing: 2.0,
                      fontSize: 14.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              child: Text('OPEN'),
              onPressed: () {
                String newPath = currPath + '$containerName/';

                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => EncScreen(
                            authData: authData,
                            webId: webId,
                            currPath: newPath,
                            encFileList: encFileList,
                            encryptClient: encryptClient,
                            action: 'encrypt',
                          )),
                );
              },
              style: ElevatedButton.styleFrom(
                minimumSize: Size(20, 25),
                backgroundColor: brickRed, // background
                foregroundColor: Colors.white, // foreground
              ),
            ),
          ],
        ),
      ],
    );
  }

  Column buildResourceRow(
      BuildContext context,
      String resourceName,
      String profName,
      String currUrl,
      String pathStr,
      List encFileList,
      EncryptClient encryptClient) {
    String filePath = pathStr + resourceName;
    bool encryptedFlag = false;

    if (pathStr.length > 0) {
      pathStr = pathStr.substring(0, pathStr.length - 1);
    }

    if (encFileList.contains(filePath)) {
      encryptedFlag = true;
    }

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            RichText(
              text: TextSpan(
                children: [
                  WidgetSpan(
                    child: Icon(Icons.insert_drive_file_outlined, size: 20),
                  ),
                  TextSpan(
                    text: " $resourceName",
                    style: TextStyle(
                      color: titleAsh,
                      letterSpacing: 2.0,
                      fontSize: 14.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            if (resourceName.contains('.ttl')) ...[
              Container(
                child: Row(
                  children: [
                    ElevatedButton(
                      child: Text('READ'),
                      onPressed: () async {
                        var rsaInfo = authData['rsaInfo'];
                        var rsaKeyPair = rsaInfo['rsa'];
                        var publicKeyJwk = rsaInfo['pubKeyJwk'];
                        String accessToken = authData['accessToken'];

                        // Get file content
                        String fileUrl = currUrl + resourceName;
                        String dPopToken = genDpopToken(
                            fileUrl, rsaKeyPair, publicKeyJwk, 'GET');
                        String fileInfo = await fetchPrvProfile(
                            fileUrl, accessToken, dPopToken);

                        displayFileContent(context, fileInfo);
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(20, 25),
                        primary: lightBlue, // background
                        onPrimary: Colors.white, // foreground
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    if (resourceName != 'enc-keys.ttl') ...[
                      if (encryptedFlag) ...[
                        ElevatedButton(
                          child: Text('DECRYPT'),
                          onPressed: () async {
                            await encryptClient.decryptFile(
                                pathStr, resourceName);
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
                          style: ElevatedButton.styleFrom(
                            minimumSize: Size(20, 25),
                            primary: lightGreen, // background
                            onPrimary: Colors.white, // foreground
                          ),
                        ),
                      ] else ...[
                        ElevatedButton(
                          child: Text('ENCRYPT'),
                          onPressed: () async {
                            //EncryptClient encryptClient1 = EncryptClient(authData, webId);
                            await encryptClient.encryptFile(
                                pathStr, resourceName);
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
                          style: ElevatedButton.styleFrom(
                            minimumSize: Size(20, 25),
                            primary: darkCopper, // background
                            onPrimary: Colors.white, // foreground
                          ),
                        ),
                      ]
                    ]
                  ],
                ),
              ),
            ]
          ],
        ),
      ],
    );
  }

  Future<void> displayFileContent(BuildContext context, String fileInfo) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('File content'),
          content: Container(
            height: 400,
            child: SingleChildScrollView(
              child: Expanded(
                child: Column(
                  children: [
                    Text(
                      fileInfo,
                      textAlign: TextAlign.left,
                      //overflow: TextOverflow.ellipsis,
                      //maxLines: 10,
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
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
          ],
        );
      },
    );
  }
}
