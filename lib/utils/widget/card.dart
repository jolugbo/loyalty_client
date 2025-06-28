import 'dart:async';

import 'package:flutter/material.dart';
import 'package:moniback/providers/auth_providers.dart';
import 'package:moniback/providers/voucher_provider.dart';
import 'package:moniback/utils/constants/app_colors.dart';
import 'package:moniback/utils/constants/app_images.dart';
import 'package:moniback/utils/widget/custom_snackbar.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

class DealCard extends StatefulWidget {
  final deal;
  final token;
  const DealCard({required this.deal, required this.token, super.key});
  @override
  State<DealCard> createState() => _DealCardState();
}

class _DealCardState extends State<DealCard> {
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
      (widget.deal["AvailableVouchers"] < 1) ? isClaimed = true : isClaimed = false;
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
        widget.deal["MarkedLikedCount"] += (widget.deal["IsMarkedLiked"])? 1:-1;
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
          widget.deal["MarkedLikedCount"] -=  (widget.deal["IsMarkedLiked"])? -1:1;
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
        widget.deal["BookmarkCount"] += (widget.deal["IsBookmarked"])? 1:-1;
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
          widget.deal["BookmarkCount"] -=  (widget.deal["BookmarkCount"])? -1:1;
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
          CustomSnackbar.showSuccess(context,results["message"]);

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

    return Container(
      margin: EdgeInsets.only(bottom: 20),
      color: AppColor.white,
      child: Padding(
        padding: const EdgeInsets.all(0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 8),
            //Card Top
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.max,
              children: [
                Row(
                  children: [
                    const SizedBox(width: 10),
                    FutureBuilder<ImageProvider>(
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
                    SizedBox(width: 8),
                    Text(
                      widget.deal["BusinessName"],
                      style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                          color: AppColor.dark),
                    ),
                  ],
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    alignment: Alignment.centerLeft,
                    width: size.width * 0.22,
                    height: size.height * 0.04,
                    color: countDown == "Expired"
                        ? AppColor.lightRed
                        : AppColor.dateBGGreen,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(width: 6),
                        Visibility(
                            visible: countDown != "Expired",
                            child: const Icon(Icons.access_time,
                                color: AppColor.dateGreen)),
                        Text(
                          "${(countDown == 0) ? "" : countDown}",
                          style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                              color: countDown == "Expired"
                                  ? AppColor.Red
                                  : AppColor.dateGreen),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            // Image
            ClipRRect(
              borderRadius: BorderRadius.circular(0),
              child: Stack(
                children: [
                  FutureBuilder<ImageProvider>(
                    future: _featuredImageFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        //
                        return  Container(
                      color: AppColor.background,
                      height: size.height * 0.4,
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
                          height: size.height * 0.4,
                          width: double.infinity,
                          fit: BoxFit.fill,
                        );
                      }
                    },
                  ),
                  // if (isLoading)
                  //   Container(
                  //     color: AppColor.background,
                  //     height: size.height * 0.4,
                  //     child: const Center(
                  //       child: CircularProgressIndicator(
                  //         color: AppColor.primaryColor,
                  //       ),
                  //     ),
                  //   ),
                ],
              ),
            ),

            const SizedBox(height: 10),
            //Card footer
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 5, 10, 10),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: size.width,
                      child: Row(
                        children: [
                          //Like Button
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              alignment: Alignment.centerLeft,
                              width: size.width * 0.22,
                              color: (widget.deal["IsMarkedLiked"])
                                  ? AppColor.Red
                                  : AppColor.background,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(width: 6),
                                  IconButton(
                                    onPressed: () {
                                      _likeAction(voucherProvider);
                                    },
                                    icon: Icon(Icons.favorite_outline,
                                        color: (widget.deal["IsMarkedLiked"])
                                            ? AppColor.white
                                            : AppColor.lightdark),
                                  ),
                                  SizedBox(width: 6),
                                  Text(
                                    "${widget.deal["MarkedLikedCount"]}",
                                    style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 20,
                                        color: (widget.deal["IsMarkedLiked"])
                                            ? AppColor.white
                                            : AppColor.grey2),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(width: 6),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              alignment: Alignment.centerLeft,
                              width: size.width * 0.18,
                              child: ValueListenableBuilder<bool>(
                                valueListenable: isBookmarking,
                                builder: (context, loading, _) {
                                  return ValueListenableBuilder<bool>(
                                    valueListenable: isBookmarked,
                                    builder: (context, bookmarked, _) {
                                      return Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            onPressed: () {
                                              _bookmarkAction(voucherProvider);
                                            },
                                            icon: (widget.deal["IsBookmarked"])
                                                ? Icon(Icons.bookmark_rounded,
                                                    color: AppColor.lightdark)
                                                : Icon(
                                                    Icons
                                                        .bookmark_border_outlined,
                                                    color: AppColor.lightdark),
                                          ),
                                          Text(
                                            "${widget.deal["BookmarkCount"]}",
                                            style: const TextStyle(
                                                fontWeight: FontWeight.w500,
                                                fontSize: 20,
                                                color: AppColor.grey2),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                              ),
                            ),
                          ),
                          SizedBox(width: 10),
                          ValueListenableBuilder<bool>(
                            valueListenable: isLiking,
                            builder: (context, loading, _) {
                              return ValueListenableBuilder<bool>(
                                valueListenable: isLiked,
                                builder: (context, liked, _) {
                                  return GestureDetector(
                                    onTap: () {
                                      String content =
                                          'Check out this amazing app!';
                                      String subject = 'Moniback';
                                      Share.share(content, subject: subject);
                                    },
                                    child: Image.asset(
                                      AppImages.share,
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                          // Claim Button
                          Container(
                            padding:
                                EdgeInsets.fromLTRB(size.width * 0.08, 0, 0, 0),
                            width: size.width * 0.4,
                            child: ElevatedButton(
                              onPressed: () => isClaimed||(countDown == "Expired")
                                  ? {
                                      CustomSnackbar.showError(context,
                                          "You you cannot claim this voucher")
                                    }
                                    :_claimAction(voucherProvider),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isClaimed|(countDown == "Expired")
                                    ? AppColor.cardBtn
                                    : AppColor.primaryColor,
                                foregroundColor: Colors.black,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(
                                (widget.deal["AvailableVouchers"] < 1) ? "Claimed" :(countDown == "Expired")? "Expired": "Claim Now",
                                style: TextStyle(
                                    color: isClaimed
                                        ? AppColor.grey2
                                        :(countDown == "Expired")? AppColor.Red: Colors.black,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                     ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    alignment: Alignment.centerLeft,
                    width: size.width * 0.3,
                    height: size.height * 0.04,
                    color: (widget.deal["AvailableVouchers"] <= 10)
                        ? AppColor.lightRed
                        : AppColor.dateBGGreen,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(width: 6),
                        Visibility(
                            visible: (widget.deal["AvailableVouchers"] >= 10),
                            child:  Icon(Icons.info_outline,
                                 color: widget.deal["AvailableVouchers"] <= 10
                                  ? AppColor.Red
                                  : AppColor.dateGreen),),
                        SizedBox(width: 6),
                        Text(
                          "${widget.deal["AvailableVouchersHtml"]}",
                          style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                              color: widget.deal["AvailableVouchers"] <= 10
                                  ? AppColor.Red
                                  : AppColor.dateGreen),
                        )
                      ],
                    ),
                  ),
                ),
                    
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: "${widget.deal["Name"]} ",
                            style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w400,
                                fontSize: 14),
                          ),
                          TextSpan(
                            text: widget.deal["Description"] != null &&
                                    widget.deal["Description"].length > 100
                                ? widget.deal["Description"].substring(0, 100) +
                                    '... more' // Add ellipsis for truncated text
                                : widget.deal["Description"],
                            style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w300,
                                fontSize: 11),
                          ),
                          // TextSpan(
                          //   text: widget.deal["Description"] != null &&
                          //           widget.deal["Description"].length >
                          //               100
                          //       ? 'Read More' // Add ellipsis for truncated text
                          //       : "",
                          //   style: TextStyle(
                          //       color: Colors.black,
                          //       fontWeight: FontWeight.w500,
                          //       fontSize: 11),
                          // ),
                        ],
                      ),
                    ),

                    // Description
                  ]),
            ),
          ],
        ),
      ),
    );
  }
}
