import 'package:flutter/material.dart';
import 'package:moniback/modules/store/point_conversion.dart';
import 'package:moniback/providers/store_provider.dart';
import 'package:moniback/utils/constants/app_colors.dart';
import 'package:moniback/utils/constants/app_images.dart';
import 'package:moniback/utils/widget/app_button.dart';
import 'package:moniback/utils/widget/back_button.dart';
import 'package:provider/provider.dart';

class Store extends StatefulWidget {
  final token;
  final contactKey;
  const Store({required this.token, required this.contactKey, super.key});
  @override
  State<Store> createState() => _StoreState();
}

class _StoreState extends State<Store> {
  int activeTabIndex = 0;
  final TextEditingController searchController = TextEditingController();
  bool isLoading = false;
  late Future<Map<String, dynamic>> _storesFuture;

  void _load() async {
    setState(() {
      isLoading = true;
    });
    final storeProvider = Provider.of<StoreProvider>(context, listen: false);

    try {
      // Perform the API calls concurrently
      _storesFuture =
          storeProvider.getStore(token: widget.token, key: widget.contactKey);

      setState(() {
        isLoading = false;
      });
    } catch (error) {
      // Handle errors here
      print('Error fetching data: $error');
    }
  }

  @override
  void initState() {
    super.initState();

    _load();
  }

  @override
  Widget build(BuildContext context) {
    final storeProvider = Provider.of<StoreProvider>(context, listen: false);
    final size = MediaQuery.of(context).size;

    return FutureBuilder<Map<String, dynamic>>(
      future: _storesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            color: Colors.white.withOpacity(0.5),
            child: const Center(
              child: CircularProgressIndicator(
                color: AppColor.primaryColor,
              ),
            ),
          );
        } else if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text("No business found"));
        }

        final business = snapshot.data!;
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
                business["Name"],
                style: TextStyle(
                    color: AppColor.dark,
                    fontSize: 24,
                    fontWeight: FontWeight.w700),
              ),
              centerTitle: true,
            ),
            body: Container(
              color: AppColor.grey,
              child: Column(
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
                              shape:
                                  BoxShape.circle, // Makes the container round
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4), // Shadow position
                                ),
                              ],
                            ),
                            child: ClipOval(
                                child: FutureBuilder<ImageProvider>(
                              future: storeProvider.fetchImage(
                                  token: widget.token,
                                  url: business["LogoUri"]),
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
                  Column(
                    children: [
                      Container(
                          width: size.width * 0.9,
                          margin: const EdgeInsets.only(bottom: 20),
                          height: 100.0, // Height of the container
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12.0),
                            shape:
                                BoxShape.rectangle, // Makes the container round
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4), // Shadow position
                              ),
                            ],
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                                      image: AssetImage(AppImages.wallet),
                                      width: size.height * 0.1,
                                      height: size.height * 0.1,
                                      fit: BoxFit.cover,
                                    ),
                                  )),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text("Account balance",
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                          color: AppColor.dark,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500)),
                                  Text(business["AccountBalanceString"],
                                      style: const TextStyle(
                                          color: AppColor.dark,
                                          fontSize: 24,
                                          fontWeight: FontWeight.w500)),
                                ],
                              ),
                              SizedBox(
                                width: size.width * 0.3,
                                child: AppButton(
                                    title: 'Convert',
                                    color: AppColor.primaryColor,
                                    textColor: AppColor.dark,
                                    onTap: () {}),
                              ),
                            ],
                          )),
                      Container(
                          width: size.width * 0.9,
                          margin: const EdgeInsets.only(bottom: 20),
                          height: 100.0, // Height of the container
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12.0),
                            shape:
                                BoxShape.rectangle, // Makes the container round
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4), // Shadow position
                              ),
                            ],
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text("Loyalty points",
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                          color: AppColor.dark,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500)),
                                  Text("${business['Points']} Points",
                                      style: const TextStyle(
                                          color: AppColor.dark,
                                          fontSize: 24,
                                          fontWeight: FontWeight.w500)),
                                ],
                              ),
                              SizedBox(
                                width: size.width * 0.3,
                                child: AppButton(
                                    title: 'Convert',
                                    color: AppColor.primaryColor,
                                    textColor: AppColor.dark,
                                    onTap: () async {
                                      final result = await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                PointConversion(
                                                  business: business,
                                                  token: widget.token,
                                                )),
                                      );

                                      if (result == 'refresh') {
                                        setState(() {
                                          _load(); // re-trigger the FutureBuilder
                                        });
                                      }
                                    }),
                              ),
                            ],
                          )),
                      Container(
                          width: size.width * 0.9,
                          margin: const EdgeInsets.only(bottom: 20),
                          height: 100.0, // Height of the container
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12.0),
                            shape:
                                BoxShape.rectangle, // Makes the container round
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4), // Shadow position
                              ),
                            ],
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                                      image: AssetImage(AppImages.mobile),
                                      width: size.height * 0.1,
                                      height: size.height * 0.1,
                                      fit: BoxFit.cover,
                                    ),
                                  )),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text("Store Credit",
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                          color: AppColor.dark,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500)),
                                  Text("${business['StoreCredit']}",
                                      style: const TextStyle(
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
                          width: size.width * 0.9,
                          margin: const EdgeInsets.only(bottom: 20),
                          height: 100.0, // Height of the container
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12.0),
                            shape:
                                BoxShape.rectangle, // Makes the container round
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4), // Shadow position
                              ),
                            ],
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                                      image: AssetImage(AppImages.cash),
                                      width: size.height * 0.1,
                                      height: size.height * 0.1,
                                      fit: BoxFit.cover,
                                    ),
                                  )),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text("My Voucher",
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                          color: AppColor.dark,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500)),
                                  Text("${business['ValidVouchersCount']}",
                                      style: const TextStyle(
                                          color: AppColor.dark,
                                          fontSize: 24,
                                          fontWeight: FontWeight.w500)),
                                ],
                              ),
                              SizedBox(
                                width: size.width * 0.35,
                                child: AppButton(
                                    title: 'View & Manage',
                                    textSize: 15,
                                    color: AppColor.primaryColor,
                                    textColor: AppColor.dark,
                                    onTap: () {}),
                              ),
                            ],
                          )),
                    ],
                  ),
                ],
              ),
            ));
      },
    );
  }
}
