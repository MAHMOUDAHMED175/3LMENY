// @dart=2.9

import 'dart:convert';
import 'package:ALMNEY/common/apidata.dart';
import 'package:ALMNEY/common/global.dart';
import 'package:ALMNEY/provider/home_data_provider.dart';
import 'package:ALMNEY/screens/bottom_navigation_screen.dart';
import 'package:ALMNEY/widgets/appbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:loading_overlay/loading_overlay.dart';
import 'package:provider/provider.dart';
import '../provider/currenciesProvider.dart';

class CurrencyScreen extends StatefulWidget {
  const CurrencyScreen({Key key}) : super(key: key);

  @override
  _CurrencyScreenState createState() => _CurrencyScreenState();
}

class _CurrencyScreenState extends State<CurrencyScreen> {
  String dropdownValue = 'USD';
  List<String> currencies = ['USD', 'INR'];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    CurrenciesProvider currenciesProvider =
        Provider.of<CurrenciesProvider>(context, listen: false);

    if (currenciesProvider.currencyList.isNotEmpty) {
      dropdownValue = currenciesProvider.defaultCurrency;
      currencies = currenciesProvider.currencyList;
    }

    print("Currency List :-> $currencies");

    if (selectedCurrency != null) dropdownValue = selectedCurrency;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(context, translate('Currency_')),
      body: LoadingOverlay(
        isLoading: isLoading,
        progressIndicator: CircularProgressIndicator(
          color: Colors.red,
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Card(
            elevation: 10.0,
            child: Container(
              height: 200,
              child: Column(
                children: [
                  SizedBox(height: 50),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        translate('Choose_Currency'),
                        style: TextStyle(
                          fontSize: 22.0,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      SizedBox(width: 20),
                      DropdownButton<String>(
                        value: dropdownValue,
                        icon: const Icon(Icons.arrow_drop_down_sharp),
                        onChanged: (String newValue) {
                          setState(() {
                            dropdownValue = newValue;
                          });
                        },
                        items: currencies
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(
                              value,
                              style: TextStyle(
                                fontSize: 18.0,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepOrange,
                    ),
                    onPressed: () async {
                      setState(() {
                        isLoading = true;
                      });
                      HomeDataProvider homeDataProvider =
                          Provider.of<HomeDataProvider>(context, listen: false);
                      String url = APIData.currencyRates + APIData.secretKey;
                      http.Response response = await http.post(
                        Uri.parse(url),
                        body: {
                          'currency_from':
                              homeDataProvider.homeModel.currency.currency,
                          'currency_to': dropdownValue,
                          'price': '1',
                        },
                      );
                      if (response.statusCode == 200) {
                        var body = jsonDecode(response.body);
                        print(
                            'Currency Rates API Response :-> ${response.body}');
                        selectedCurrency = dropdownValue;
                        print('Selected Currency :-> $selectedCurrency');

                        if (body['currency'] != null) {
                          selectedCurrencyRate = body['currency'];
                          selectedCurrencyRate =
                              double.parse(selectedCurrencyRate.toString())
                                  .round();
                          print(
                              'Selected Currency Rate :-> $selectedCurrencyRate');
                        } else {
                          await Fluttertoast.showToast(
                              msg:
                                  translate(translate("Currency_didnt_Change")),
                              toastLength: Toast.LENGTH_LONG,
                              gravity: ToastGravity.CENTER,
                              backgroundColor: Colors.red,
                              textColor: Colors.white,
                              fontSize: 16.0);
                          setState(() {
                            isLoading = false;
                          });
                          return;
                        }

                        storage.write(
                            key: 'selectedCurrency', value: selectedCurrency);
                        storage.write(
                            key: 'selectedCurrencyRate',
                            value: selectedCurrencyRate.toString());

                        await Fluttertoast.showToast(
                            msg: translate(
                                translate("Currency_changed_successfully")),
                            toastLength: Toast.LENGTH_LONG,
                            gravity: ToastGravity.CENTER,
                            backgroundColor: Colors.blue,
                            textColor: Colors.white,
                            fontSize: 16.0);
                      } else {
                        print(
                            'Currency Rates API Status Code :-> ${response.statusCode}');
                      }
                      setState(() {
                        isLoading = false;
                      });
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              MyBottomNavigationBar(pageInd: 0),
                        ),
                      ).then((value) => setState(() {}));
                    },
                    child: Text(
                      translate('Apply_'),
                      style: TextStyle(
                        fontSize: 18.0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
