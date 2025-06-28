import 'package:flutter/material.dart';
import 'package:moniback/providers/store_provider.dart';
import 'package:moniback/utils/constants/app_colors.dart';
import 'package:moniback/utils/constants/app_images.dart';
import 'package:moniback/utils/functions/helper.dart';
import 'package:moniback/utils/widget/app_button.dart';
import 'package:moniback/utils/widget/back_button.dart';
import 'package:provider/provider.dart';

class PointConversion extends StatefulWidget {
  final token;
  final business;
  const PointConversion(
      {required this.token, required this.business, super.key});
  @override
  State<PointConversion> createState() => _PointConversionState();
}

class _PointConversionState extends State<PointConversion> {
  bool isLoading = false;
  final TextEditingController valueController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool isFormValid = false;

  void _validateForm() {
    setState(() {
      isFormValid = _formKey.currentState?.validate() ?? false;
    });
  }

  Future<void> convertPoint() async {
    final storeProvider = Provider.of<StoreProvider>(context, listen: false);
    if (isFormValid) {
      bool hasInternet = await HelperClass().hasInternetConnection();
      if (hasInternet) {
        setState(() {
          isLoading = true;
        });
        var resp = await storeProvider.getStoreCreditBalance(
            token: widget.token, key: widget.business["ContactKey"]);

        if (resp['success']) {
          print("got here");
          final Map<String, dynamic> request = {
            "ContactKey": widget.business["ContactKey"],
            "StoreCreditAccountId":
                resp["data"]["StoreCreditAccountId"].toString(),
            "LogoUri": widget.business["LogoUri"],
            "Name": widget.business["Name"],
            "AccountBalance": widget.business["AccountBalance"].toString(),
            "AccountBalanceString": widget.business["AccountBalanceString"],
            "Point": widget.business["Points"].toString(),
            "StoreCredit": widget.business["StoreCredit"].toString(),
            "StoreCreditString": widget.business["StoreCreditString"],
            "ExchangeRate": resp["data"]["ExchangeRate"].toString(),
            "ConvertValue": valueController.text,
            "CreditReceived": resp["data"]["CreditReceived"]?.toString(),
            "CurrencySymbol": resp["data"]["CurrencySymbol"],
            "DecimalPlace": resp["data"]["DecimalPlace"].toString(),
            "SymbolDisplay": resp["data"]["SymbolDisplay"].toString(),
          };

          var resp2 = await storeProvider.point2StoreCredit(
              token: widget.token, converDetails: request);
          setState(() {
            isLoading = false;
          });
          if (resp2) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Points Converted Successfully.')),
            );
            Navigator.pop(context, 'refresh');
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('An Error Occurred')),
            );
          }
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('No internet connection. Please try again later.')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please input points to be converted.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final storeProvider = Provider.of<StoreProvider>(context, listen: false);
    final size = MediaQuery.of(context).size;
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: AppColor.white, // Header color
          elevation: 0,
          leading: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: GoBackButtton(
                iconColor: AppColor.dark,
              )),
          title: Text(
            widget.business["Name"],
            style: TextStyle(
                color: AppColor.dark,
                fontSize: 24,
                fontWeight: FontWeight.w700),
          ),
          centerTitle: true,
        ),
        body: Container(
            color: AppColor.grey,
            child: Stack(
              children: [
                Column(
                  children: [
                    Stack(
                      children: [
                        Container(
                          height: size.height * 0.05,
                          color: AppColor.white,
                        ),
                        Center(
                          child: Container(
                              width: 100.0,
                              height: 100.0, // Height of the container
                              decoration: BoxDecoration(
                                color: Colors.white, // Background color
                                shape: BoxShape
                                    .circle, // Makes the container round
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.3),
                                    blurRadius: 8,
                                    offset:
                                        const Offset(0, 4), // Shadow position
                                  ),
                                ],
                              ),
                              child: ClipOval(
                                  child: FutureBuilder<ImageProvider>(
                                future: storeProvider.fetchImage(
                                    token: widget.token,
                                    url: widget.business["LogoUri"]),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return CircleAvatar(
                                      backgroundColor: Colors.grey[300],
                                      child: Icon(Icons.image),
                                    );
                                  } else if (snapshot.hasError) {
                                    return CircleAvatar(
                                      backgroundColor: Colors.red[300],
                                      child: Icon(Icons.error),
                                      radius: 50,
                                    );
                                  } else {
                                    return Image(
                                      image: snapshot.data!,
                                      width: size.height * 0.1,
                                      height: size.height * 0.1,
                                      fit: BoxFit.cover,
                                    );
                                  }
                                },
                              ))),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Container(
                      child: Column(
                        children: [
                          Container(
                              width: size.width * 0.9,
                              margin: const EdgeInsets.only(bottom: 20),
                              height: 100.0, // Height of the container
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12.0),
                                shape: BoxShape
                                    .rectangle, // Makes the container round
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.3),
                                    blurRadius: 8,
                                    offset:
                                        const Offset(0, 4), // Shadow position
                                  ),
                                ],
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Container(
                                      width: 80.0,
                                      height: 80.0, // Height of the container
                                      decoration: BoxDecoration(
                                        color: Colors.white, // Background color
                                        shape: BoxShape
                                            .circle, // Makes the container round
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.withOpacity(0.3),
                                            blurRadius: 6,
                                            offset: const Offset(
                                                0, 2), // Shadow position
                                          ),
                                        ],
                                      ),
                                      child: ClipOval(
                                        child: Image(
                                          image: AssetImage(AppImages.trophy),
                                          width: size.height * 0.1,
                                          height: size.height * 0.1,
                                          fit: BoxFit.cover,
                                        ),
                                      )),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Text("Loyalty points",
                                          textAlign: TextAlign.left,
                                          style: TextStyle(
                                              color: AppColor.dark,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500)),
                                      Text("${widget.business["Points"]}",
                                          style: TextStyle(
                                              color: AppColor.dark,
                                              fontSize: 24,
                                              fontWeight: FontWeight.w500)),
                                    ],
                                  ),
                                  SizedBox(
                                    width: size.width * 0.3,
                                  ),
                                ],
                              )),
                          Container(
                            child: Image(
                              image: AssetImage(AppImages.arrow_down),
                              width: 30,
                              fit: BoxFit.cover,
                            ),
                            width: size.width * 0.8,
                            margin: const EdgeInsets.only(bottom: 20),
                            alignment: Alignment.centerLeft,
                            height: 50.0,
                          ),
                          Center(
                            child: Container(
                                width: MediaQuery.of(context).size.width * 0.9,
                                padding: EdgeInsets.all(10.0),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.2),
                                      blurRadius: 10,
                                      offset: Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                        width: 80.0,
                                        height: 80.0, // Height of the container
                                        decoration: BoxDecoration(
                                          color:
                                              Colors.white, // Background color
                                          shape: BoxShape
                                              .circle, // Makes the container round
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  Colors.grey.withOpacity(0.3),
                                              blurRadius: 6,
                                              offset: const Offset(
                                                  0, 2), // Shadow position
                                            ),
                                          ],
                                        ),
                                        child: ClipOval(
                                          child: Image(
                                            image: AssetImage(AppImages.mobile),
                                            width: size.height * 0.1,
                                            height: size.height * 0.1,
                                            fit: BoxFit.cover,
                                          ),
                                        )),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                              "Convert points to store credits",
                                              textAlign: TextAlign.left,
                                              style: TextStyle(
                                                  color: AppColor.dark,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w500)),
                                          const SizedBox(height: 16),
                                          Row(
                                            children: [
                                              const Text(
                                                "N",
                                                style: TextStyle(
                                                  fontSize: 24,
                                                  color: AppColor.dark,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              SizedBox(width: 8),
                                              Expanded(
                                                child: Container(
                                                  height: 35,
                                                  decoration: BoxDecoration(
                                                    border: Border.all(
                                                        color: Colors.grey),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                  ),
                                                  child: Form(
                                                      key: _formKey,
                                                      onChanged: _validateForm,
                                                      child: TextFormField(
                                                        keyboardType:
                                                            TextInputType
                                                                .number,
                                                        controller:
                                                            valueController,
                                                        style: TextStyle(
                                                          color: Colors.black,
                                                          fontSize:
                                                              18, // Set font size to 18
                                                          fontWeight: FontWeight
                                                              .w500, // Set font weight to w500
                                                        ),
                                                        decoration:
                                                            InputDecoration(
                                                          border:
                                                              InputBorder.none,
                                                        ),
                                                        validator: (value) {
                                                          if (value == null ||
                                                              value
                                                                  .trim()
                                                                  .isEmpty) {
                                                            return 'This field cannot be empty';
                                                          }
                                                          return null; // Return null if validation passes
                                                        },
                                                      )),
                                                ),
                                              ),
                                              SizedBox(width: 8),
                                              Text(
                                                "= additional store credit",
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w500,
                                                  color: AppColor.dark,
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 16),
                                          Container(
                                            padding: EdgeInsets.all(16),
                                            width: size.width * 0.8,
                                            decoration: BoxDecoration(
                                              color: Colors.grey[200],
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                const Text.rich(
                                                  TextSpan(
                                                    children: [
                                                      TextSpan(
                                                        text:
                                                            "Store credit after conversion\n",
                                                        style: TextStyle(
                                                          fontSize: 9,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          color: AppColor.dark,
                                                        ),
                                                      ),
                                                      TextSpan(
                                                        text: "N0.00",
                                                        style: TextStyle(
                                                          fontSize: 24,
                                                          color: AppColor.dark,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                ElevatedButton(
                                                  onPressed: () {
                                                    convertPoint();
                                                  },
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        AppColor.primaryColor,
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                      vertical: 8,
                                                      horizontal: 16,
                                                    ),
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                    ),
                                                  ),
                                                  child: Text(
                                                    "Convert now",
                                                    style: TextStyle(
                                                      color: AppColor.dark,
                                                      fontSize: 11,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                )),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
                if (isLoading)
                  Container(
                    color: Colors.black.withOpacity(0.5),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppColor.primaryColor,
                      ),
                    ),
                  ),
              ],
            )));
  }
}
