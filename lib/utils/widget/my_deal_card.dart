import 'dart:async';

import 'package:flutter/material.dart';
import 'package:moniback/modules/store/store.dart';
import 'package:moniback/providers/auth_providers.dart';
import 'package:moniback/providers/voucher_provider.dart';
import 'package:moniback/utils/constants/app_colors.dart';
import 'package:moniback/utils/constants/app_images.dart';
import 'package:moniback/utils/widget/custom_snackbar.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

class MyDealCard extends StatefulWidget {
  final deal;
  final token;
  final status;
  const MyDealCard(
      {required this.deal,
      required this.token,
      super.key,
      required this.status});
  @override
  State<MyDealCard> createState() => _MyDealCardState();
}

class _MyDealCardState extends State<MyDealCard> {
  bool isClaimed = false;
  bool isLoading = false;
  ImageProvider logo = AssetImage(AppImages.store1);
  ImageProvider dealImage = AssetImage(AppImages.deal);
  late ValueNotifier<bool> isBookmarking;
  late ValueNotifier<bool> isBookmarked;
  late ValueNotifier<bool> isLiking;
  late ValueNotifier<bool> isLiked;
  late Future<ImageProvider> _logoFuture;
  late Future<ImageProvider> _featuredImageFuture;

  late Timer _timer;
  String countDown = "";
  DateTime endDate = DateTime.now();

  void _startCountdown() {
    endDate = DateTime.parse(widget.deal["EndDate"]);
    // Calculate the difference
    Duration difference = endDate.difference(DateTime.now());
    countDown = "${difference.inDays}";
    if (difference.inDays < 0) {
      countDown = "Expired";
    } else if (difference.inDays == 0) {
      _timer = Timer.periodic(Duration(seconds: 1), (_) {
        final now = DateTime.now();
        final difference = endDate.difference(now);

        if (difference.isNegative) {
          setState(() {
            countDown = "Expired";
          });
          _timer.cancel();
        } else if (difference.inDays >= 1) {
          setState(() {
            countDown = "${difference.inDays} Days";
          });
        } else {
          final hours = difference.inHours;
          final minutes = difference.inMinutes % 60;
          final seconds = difference.inSeconds % 60;

          setState(() {
            countDown =
                "${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";
          });
        }
      });
    } else {
      countDown = "${difference.inDays} Days";
    }
  }

  @override
  void initState() {
    super.initState();
    _startCountdown();
    //_loadImage();
    setState(() {
      (widget.deal["AvailableVouchers"] < 1)
          ? isClaimed = true
          : isClaimed = false;
      isBookmarked = ValueNotifier(widget.deal["IsMarkedLiked"]);
      isBookmarking = ValueNotifier(false);
      isLiked = ValueNotifier(widget.deal["IsLiked"]);
      isLiking = ValueNotifier(false);
      final voucherProvider =
          Provider.of<VoucherProvider>(context, listen: false);
      _logoFuture = voucherProvider.getImage(
        token: widget.token,
        imageUrl: widget.deal["DomainLogo"],
      );
      _featuredImageFuture = voucherProvider.getImage(
        token: widget.token,
        imageUrl: widget.deal["FeaturedImageUri"],
      );
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _likeAction(VoucherProvider voucherProvider) async {
    try {
      // Perform the API calls concurrently
      setState(() {
        isLoading = true;
        widget.deal["IsMarkedLiked"] = !widget.deal["IsMarkedLiked"];
        widget.deal["MarkedLikedCount"] +=
            (widget.deal["IsMarkedLiked"]) ? 1 : -1;
      });
      final results = await voucherProvider.likeVoucher(
          token: widget.token,
          like: widget.deal["IsMarkedLiked"],
          businessKey: widget.deal["BusinessKey"],
          promotionkey: widget.deal["PromotionKey"]);

      print(results["message"]);
      // Extract the results
      //final dealsList = results[0];

      setState(() {
        isLoading = false;
        if (!results["success"]) {
          widget.deal["IsMarkedLiked"] = !widget.deal["IsMarkedLiked"];
          widget.deal["MarkedLikedCount"] -=
              (widget.deal["IsMarkedLiked"]) ? -1 : 1;
        }
      });
    } catch (error) {
      // Handle errors here
      print('Error fetching data: $error');
    }
  }

  void _bookmarkAction(VoucherProvider voucherProvider) async {
    try {
      setState(() {
        isLoading = true;
        widget.deal["IsBookmarked"] = !widget.deal["IsBookmarked"];
        widget.deal["BookmarkCount"] += (widget.deal["IsBookmarked"]) ? 1 : -1;
      });
      print(widget.deal["BookmarkCount"]);
      final results = await voucherProvider.bookMarkVoucher(
        token: widget.token,
        bookmark: widget.deal["IsBookmarked"],
        promotionkey: widget.deal["PromotionKey"],
      );

      setState(() {
        isLoading = false;
      });
      if (!results["success"]) {
        widget.deal["IsBookmarked"] = !widget.deal["IsBookmarked"];
        widget.deal["BookmarkCount"] -= (widget.deal["BookmarkCount"]) ? -1 : 1;
      }
    } catch (error) {
      // Handle errors here
      print('Error fetching data: $error');
    }
  }

  void _claimAction(VoucherProvider voucherProvider) async {
    try {
      setState(() {
        isLoading = true;
      });
      final results = await voucherProvider.claimDeal(
          token: widget.token,
          PromotionKey: widget.deal["PromotionKey"],
          businessKey: widget.deal["BusinessKey"]);

      setState(() {
        isLoading = false;
        print(results["success"]);
        if (results["success"]) {
          CustomSnackbar.showSuccess(context, results["message"]);
        } else {
          CustomSnackbar.showError(context, results['data']);
        }
      });
    } catch (error) {
      // Handle errors here
      print('Error fetching data: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    final voucherProvider =
        Provider.of<VoucherProvider>(context, listen: false);
    final size = MediaQuery.of(context).size;

    int count = widget.deal["MarkedLikedCount"];
    String likeCounts = "";
    if (count == 0) {
      likeCounts = "be the first to Like this";
    } else if (count == 1) {
      likeCounts = "1 Person Loves this";
    } else if (count > 999) {
      likeCounts = "${(count / 1000).round()} People Love this";
    } else {
      likeCounts = "${count} People Love this";
    }

    return Card(
      margin: const EdgeInsets.all(12),
      color: AppColor.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left image
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: FutureBuilder<ImageProvider>(
                future: _featuredImageFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    //
                    return Container(
                      color: AppColor.background,
                      width: 80,
                      height: 80,
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: AppColor.primaryColor,
                        ),
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return CircleAvatar(
                      backgroundColor: Colors.red[300],
                      child: Icon(Icons.error),
                      radius: double.infinity,
                    );
                  } else {
                    return Image(
                      image: snapshot.data!,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    );
                  }
                },
              ),
            ),
           
            const SizedBox(width: 12),
            // Right content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and countdown
                  Row(
                    children: [
                      // Logo and name
                      CircleAvatar(
                        radius: 10,
                        child: FutureBuilder<ImageProvider>(
                          future: _logoFuture,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return CircleAvatar(
                                backgroundColor: Colors.yellow[400],
                                child: Icon(Icons.store),
                                radius: 30,
                              );
                            } else if (snapshot.hasError) {
                              return CircleAvatar(
                                backgroundColor: Colors.red[300],
                                child: Icon(Icons.error),
                                radius: 30,
                              );
                            } else {
                              return CircleAvatar(
                                backgroundImage: snapshot.data!,
                                radius: 30,
                              );
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        (widget.deal["BusinessName"] != null &&
                                widget.deal["BusinessName"].length > 15)
                            ? widget.deal["BusinessName"].substring(0, 15) +
                                '...' // Add ellipsis for truncated text
                            : widget.deal["BusinessName"],
                        style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                            color: AppColor.dark),
                      ),
                      const Spacer(),
                      // Countdown badge
                      Visibility(
                          visible: widget.status == "all",
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: (countDown == "Expired")
                                  ? AppColor.objectColor
                                  : Color(0xFFE6F8EA),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.access_time,
                                  size: 14,
                                  color: (countDown == "Expired")
                                      ? AppColor.Red
                                      : Colors.green,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  "${(countDown == 0) ? "" : countDown}",
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: (countDown == "Expired")
                                        ? AppColor.Red
                                        : Colors.green,
                                  ),
                                ),
                              ],
                            ),
                          )),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    (widget.deal["Description"] != null &&
                            widget.deal["Description"].length > 100)
                        ? widget.deal["Description"].substring(0, 100) +
                            '... more' // Add ellipsis for truncated text
                        : widget.deal["Description"],
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.black87,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Visibility(
                      visible:
                          widget.status == "all" || widget.status == "expired",
                      child: Text(
                        widget.deal["CreatedDate"].substring(0, 10),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      )),
                  Visibility(
                    visible: widget.status == "redeemed",
                    child: Container(
                      child: Image.asset(
                        AppImages.redeemed,
                        width: size.width * 0.2,
                        //height: size.height * 0.2,
                        fit: BoxFit.fitHeight,
                      ),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class MyStoreCard extends StatefulWidget {
  final store;
  final token;
  const MyStoreCard({required this.store, required this.token, super.key});
  @override
  State<MyStoreCard> createState() => _MyStoreCardState();
}

class _MyStoreCardState extends State<MyStoreCard> {
  bool isClaimed = false;
  bool isLoading = false;
  ImageProvider logo = AssetImage(AppImages.store1);
  ImageProvider dealImage = AssetImage(AppImages.deal);
  late Future<ImageProvider> _logoFuture;
  late Future<ImageProvider> _featuredImageFuture;

  @override
  void initState() {
    super.initState();
    //_loadImage();
    setState(() {
      final voucherProvider =
          Provider.of<VoucherProvider>(context, listen: false);
      _logoFuture = voucherProvider.getImage(
        token: widget.token,
        imageUrl: widget.store["LogoUri"] ?? "",
      );
      // _featuredImageFuture = voucherProvider.getImage(
      //   token: widget.token,
      //   imageUrl: widget.deal["FeaturedImageUri"],
      // );
    });
  }

  @override
  Widget build(BuildContext context) {

    return GestureDetector(
        onTap: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => Store(token: widget.token,contactKey: widget.store["BusinessProfileId"],)));
        },
        child: Card(
          margin: const EdgeInsets.all(12),
          color: AppColor.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left image
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: FutureBuilder<ImageProvider>(
                    future: _logoFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        //
                        return Container(
                          color: AppColor.background,
                          width: 80,
                          height: 80,
                          child: const Center(
                            child: CircularProgressIndicator(
                              color: AppColor.primaryColor,
                            ),
                          ),
                        );
                      } else if (snapshot.hasError) {
                        return CircleAvatar(
                          backgroundColor: Colors.red[300],
                          child: Icon(Icons.error),
                          radius: double.infinity,
                        );
                      } else {
                        return Image(
                          image: snapshot.data!,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                        );
                      }
                    },
                  ),
                ),
                const SizedBox(width: 12),
                // Right content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title and countdown
                      Text(
                        (widget.store["Name"] != null &&
                                widget.store["Name"].length > 15)
                            ? widget.store["Name"].substring(0, 15) +
                                '...' // Add ellipsis for truncated text
                            : widget.store["Name"],
                        style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                            color: AppColor.dark),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        (widget.store["BusinessDescription"] != null &&
                                widget.store["BusinessDescription"].length >
                                    100)
                            ? "${widget.store["BusinessDescription"].substring(0, 100) + '... more'}" // Add ellipsis for truncated text
                            : "${widget.store["BusinessDescription"]}",
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.black87,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 6),
                    ],
                  ),
                )
              ],
            ),
          ),
        ));
  }
}

class AccountCard extends StatelessWidget {
  final AssetImage icon;
  final Color iconBgColor;
  final String label;
  final String value;
  final bool showArrow;

  const AccountCard({
    required this.icon,
    required this.iconBgColor,
    required this.label,
    required this.value,
    this.showArrow = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon Circle
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: iconBgColor,
              shape: BoxShape.circle,
            ),
            child: ClipOval(
                                    child: Image(
                                      image: icon,
                                      width: 50,
                                      height: 50,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
          ),
          const SizedBox(width: 10),
          // Texts
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(color: AppColor.lightdark,
                        fontSize: 10, fontWeight: FontWeight.w400)),
                const SizedBox(height: 15),
                Text(value,
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: AppColor.black)),
              ],
            ),
          ),
          if (showArrow)
            const Icon(Icons.chevron_right, color: Colors.black54, size: 20),
        ],
      ),
    );
  }
}