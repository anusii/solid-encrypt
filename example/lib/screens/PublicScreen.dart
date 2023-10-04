// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:fluttersolidencrypt/models/Responsive.dart';
import 'package:fluttersolidencrypt/screens/PublicProfile.dart';

class PublicScreen extends StatelessWidget {
  String webId;

  PublicScreen({Key? key, required this.webId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Navigate to public profile with a loading screen
    var loadingScreen = PublicProfile(webId: webId);
    return Scaffold(
        body: Responsive(
      mobile: loadingScreen,
      tablet: loadingScreen,
      desktop: loadingScreen,
    ));
  }
}
