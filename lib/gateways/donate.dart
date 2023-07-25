import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:provider/provider.dart';

import '../Widgets/appbar.dart';
import '../provider/home_data_provider.dart';

class Donate extends StatefulWidget {
  const Donate({Key key}) : super(key: key);

  @override
  _DonateState createState() => _DonateState();
}

class _DonateState extends State<Donate> {
  HomeDataProvider homeDataProvider;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    homeDataProvider = Provider.of<HomeDataProvider>(context);

    return Scaffold(
      appBar: customAppBar(context, translate("Donate_")),
      body: Container(
        child: InAppWebView(
          initialUrlRequest: URLRequest(
            url: Uri.tryParse(homeDataProvider.homeModel.settings.donationLink),
          ),
        ),
      ),
    );
  }
}
