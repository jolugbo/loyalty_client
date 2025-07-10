import 'package:flutter/material.dart';
import 'package:moniback/modules/store/loyalty_points.dart';
import 'package:moniback/modules/store/point_conversion.dart';
import 'package:moniback/providers/store_provider.dart';
import 'package:moniback/providers/voucher_provider.dart';
import 'package:moniback/utils/constants/app_colors.dart';
import 'package:moniback/utils/constants/app_images.dart';
import 'package:moniback/utils/widget/app_button.dart';
import 'package:moniback/utils/widget/my_deal_card.dart';
import 'package:moniback/utils/widget/back_button.dart';
import 'package:provider/provider.dart';

class BulkDeal extends StatefulWidget {
  final token;
  final contactKey;
  const BulkDeal({required this.token, required this.contactKey, super.key});
  @override
  State<BulkDeal> createState() => _BulkDealState();
}

class _BulkDealState extends State<BulkDeal> {
  int activeTabIndex = 0;
  final TextEditingController searchController = TextEditingController();
  bool isLoading = false;
  late Future<Map<String, dynamic>> _dealFuture;
  late Future<ImageProvider> _featuredImageFuture;

  void _load() async {
    setState(() {
      isLoading = true;
    });

    final voucherProvider =
        Provider.of<VoucherProvider>(context, listen: false);
    try {
      // Perform the API calls concurrently
      _dealFuture = voucherProvider.getBulkDeals(
          token: widget.token, key: widget.contactKey);

      print(_dealFuture);
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
    final size = MediaQuery.of(context).size;

    final voucherProvider =
        Provider.of<VoucherProvider>(context, listen: false);

    return FutureBuilder<Map<String, dynamic>>(
        future: _dealFuture,
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
          } else if (!snapshot.hasData ||
              snapshot.data!.isEmpty ||
              snapshot.data!["data"] == null) {
            return Container(
                color: Colors.white.withOpacity(0.5),
                child: const Center(child: Text("No business found")));
          }

          final megaDeal = snapshot.data!["data"]["LoyaltyBulkDealPromotion"];
          print("Business $megaDeal");
          return Scaffold(
            appBar: AppBar(
              backgroundColor: AppColor.white,
              toolbarHeight: size.height * 0.1,
              elevation: 0,
              leading: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: GoBackButtton(
                    iconColor: AppColor.dark,
                  )),
              title: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //  Center(
                  //   child: Container(
                  //       width: 50.0,
                  //       height: 50.0, // Height of the container
                  //       decoration: BoxDecoration(
                  //         color: Colors.white, // Background color
                  //         shape: BoxShape.circle, // Makes the container round
                  //         boxShadow: [
                  //           BoxShadow(
                  //             color: Colors.grey.withOpacity(0.3),
                  //             blurRadius: 8,
                  //             offset: const Offset(0, 4), // Shadow position
                  //           ),
                  //         ],
                  //       ),
                  //       child: ClipOval(
                  //           child: FutureBuilder<ImageProvider>(
                  //         future: storeProvider.fetchImage(
                  //             token: widget.token, url: megaDeal["LogoUri"]),
                  //         builder: (context, snapshot) {
                  //           if (snapshot.connectionState ==
                  //               ConnectionState.waiting) {
                  //             return CircleAvatar(
                  //               backgroundColor: Colors.grey[300],
                  //               child: Icon(Icons.image),
                  //             );
                  //           } else if (snapshot.hasError) {
                  //             return CircleAvatar(
                  //               backgroundColor: Colors.red[300],
                  //               child: Icon(Icons.error),
                  //               radius: 50,
                  //             );
                  //           } else {
                  //             return Image(
                  //               image: snapshot.data!,
                  //               //width: size.height * 0.04,
                  //               height: size.height * 0.04,
                  //               fit: BoxFit.cover,
                  //             );
                  //           }
                  //         },
                  //       ))),
                  // ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${ megaDeal["Name"]}",
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "${megaDeal["Description"]}",
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
              // Row(
              //   mainAxisSize: MainAxisSize.max,
              //   mainAxisAlignment: MainAxisAlignment.center,
              //   children: [
              //     Center(
              //       child: Container(
              //           width: 50.0,
              //           height: 50.0, // Height of the container
              //           decoration: BoxDecoration(
              //             color: Colors.white, // Background color
              //             shape: BoxShape.circle, // Makes the container round
              //             boxShadow: [
              //               BoxShadow(
              //                 color: Colors.grey.withOpacity(0.3),
              //                 blurRadius: 8,
              //                 offset: const Offset(0, 4), // Shadow position
              //               ),
              //             ],
              //           ),
              //           child: ClipOval(
              //               child: FutureBuilder<ImageProvider>(
              //             future: storeProvider.fetchImage(
              //                 token: widget.token, url: business["LogoUri"]),
              //             builder: (context, snapshot) {
              //               if (snapshot.connectionState ==
              //                   ConnectionState.waiting) {
              //                 return CircleAvatar(
              //                   backgroundColor: Colors.grey[300],
              //                   child: Icon(Icons.image),
              //                 );
              //               } else if (snapshot.hasError) {
              //                 return CircleAvatar(
              //                   backgroundColor: Colors.red[300],
              //                   child: Icon(Icons.error),
              //                   radius: 50,
              //                 );
              //               } else {
              //                 return Image(
              //                   image: snapshot.data!,
              //                   //width: size.height * 0.04,
              //                   height: size.height * 0.04,
              //                   fit: BoxFit.cover,
              //                 );
              //               }
              //             },
              //           ))),
              //     ),
              //     const SizedBox(
              //       width: 20,
              //     ),
              //     Text(
              //       "",
              //       style: TextStyle(
              //           color: AppColor.dark,
              //           fontSize: 16,
              //           fontWeight: FontWeight.w700),
              //     ),
              //   ],
              // ),
              centerTitle: true,
            ),
            // body: Container(
            //   color: Colors.white,
            //   child: Column(
            //     children: [
            //       ClipRRect(
            //         borderRadius: BorderRadius.circular(0),
            //         child: Stack(
            //           children: [
            //             FutureBuilder<ImageProvider>(
            //               future: voucherProvider.getImage(
            //                 token: widget.token,
            //                 imageUrl: "${business["LogoUri"]}",
            //               ),
            //               builder: (context, snapshot) {
            //                 if (snapshot.connectionState ==
            //                     ConnectionState.waiting) {
            //                   //
            //                   return Container(
            //                     color: AppColor.background,
            //                     height: size.height * 0.25,
            //                     child: const Center(
            //                       child: CircularProgressIndicator(
            //                         color: AppColor.primaryColor,
            //                       ),
            //                     ),
            //                   );
            //                 } else if (snapshot.hasError) {
            //                   return CircleAvatar(
            //                     backgroundColor: Colors.red[300],
            //                     child: Icon(Icons.error),
            //                     radius: double.infinity,
            //                   );
            //                 } else {
            //                   return Image(
            //                     image: snapshot.data!,
            //                     height: size.height * 0.25,
            //                     width: double.infinity,
            //                     fit: BoxFit.fill,
            //                   );
            //                 }
            //               },
            //             ),
            //           ],
            //         ),
            //       ),
            //       Column(
            //         children: [
            //           Container(
            //             height: size.height * 0.1,
            //             alignment: Alignment.bottomLeft,
            //             padding: EdgeInsets.fromLTRB(size.width * 0.06, 0,
            //                 size.width * 0.06, size.width * 0.08),
            //             child: Text.rich(
            //               TextSpan(
            //                 children: [
            //                   TextSpan(
            //                     text: "${business['Name']}\n\n",
            //                     style: const TextStyle(
            //                         color: AppColor.dark,
            //                         fontSize: 14,
            //                         fontWeight: FontWeight.w600),
            //                   ),
            //                   TextSpan(
            //                     text: "${business['BusinessDescription']}",
            //                     style: TextStyle(
            //                       fontSize: 14,
            //                       color: AppColor.dark,
            //                       fontWeight: FontWeight.w400,
            //                     ),
            //                   ),
            //                 ],
            //               ),
            //             ),
            //           ),
            //           Padding(
            //             padding: const EdgeInsets.all(16.0),
            //             child: Column(
            //               crossAxisAlignment: CrossAxisAlignment.start,
            //               children: [
            //                 const Text(
            //                   "My Account",
            //                   style: TextStyle(
            //                     fontSize: 18,
            //                     fontWeight: FontWeight.w600,
            //                     color: Colors.black,
            //                   ),
            //                 ),
            //                 const SizedBox(height: 16),
            //                 GridView.count(
            //                   shrinkWrap: true,
            //                   crossAxisCount: 2,
            //                   mainAxisSpacing: 12,
            //                   crossAxisSpacing: 12,
            //                   childAspectRatio: 1.6,
            //                   physics: const NeverScrollableScrollPhysics(),
            //                   children: [
            //                     AccountCard(
            //                       icon: AssetImage(AppImages.acct_balance),
            //                       iconBgColor: Colors.grey.shade200,
            //                       label: 'Account balance',
            //                       value: "${business["AccountBalanceString"]}",
            //                     ),
            //                     GestureDetector(
            //                       onTap: () async {
            //                         final result = await Navigator.push(
            //                           context,
            //                           MaterialPageRoute(
            //                               builder: (context) => LoyaltyPointsPage(
            //                                     business: business,
            //                                     token: widget.token,
            //                                   )),
            //                         );

            //                         if (result == 'refresh') {
            //                           setState(() {
            //                             _load(); // re-trigger the FutureBuilder
            //                           });
            //                         }
            //                       },
            //                       child: AccountCard(
            //                         icon: AssetImage(AppImages.loyalty_points),
            //                         iconBgColor: Colors.orange.shade50,
            //                         label: 'Loyalty points',
            //                         value: "${business['Points']}",
            //                         showArrow: true,
            //                       ),
            //                     ),
            //                     AccountCard(
            //                       icon: AssetImage(AppImages.store_credit),
            //                       iconBgColor: Colors.red.shade50,
            //                       label: 'Store Credit',
            //                       value: "${business['StoreCredit']}",
            //                     ),
            //                     AccountCard(
            //                       icon: AssetImage(AppImages.my_vouchers),
            //                       iconBgColor: Colors.green.shade50,
            //                       label: 'My vouchers',
            //                       value: "${business['ValidVouchersCount']}",
            //                     ),
            //                   ],
            //                 ),
            //               ],
            //             ),
            //           ),
            //         ],
            //       ),
            //     ],
            //   ),
            // )
          );
        });
  }
}
