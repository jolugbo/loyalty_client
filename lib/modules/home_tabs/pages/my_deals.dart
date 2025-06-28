import 'package:flutter/material.dart';
import 'package:moniback/modules/store/store.dart';
import 'package:moniback/providers/store_provider.dart';
import 'package:moniback/providers/voucher_provider.dart';
import 'package:moniback/utils/constants/app_colors.dart';
import 'package:moniback/utils/constants/app_images.dart';
import 'package:moniback/utils/widget/my_deal_card.dart';
import 'package:moniback/utils/widget/tab_button.dart';
import 'package:provider/provider.dart';

class MyDeals extends StatefulWidget {
  final token;
  const MyDeals({required this.token, super.key});
  @override
  State<MyDeals> createState() => _MyDealsState();
}

class _MyDealsState extends State<MyDeals> {
  int activeTabIndex = 0;
  int subActiveTabIndex = 0;
  final TextEditingController searchController = TextEditingController();
  late ScrollController _AllDealScrollController;
  late ScrollController _RedeemedDealScrollController;
  late ScrollController _ExpiredDealScrollController;
  bool isLoading = false;
  List<dynamic> allDeals = [];
  List<dynamic> redeemedDeals = [];
  List<dynamic> expiredDeals = [];
  int _currentAllDealsPage = 1;
  int _totalAllDealsPages = 1;
  int _currentRedeemedDealsPage = 1;
  int _totalRedeemedDealsPages = 1;
  int _currentExpiredDealsPage = 1;
  int _totalExpiredDealsPages = 1;
  bool showAllEmptyState = false;
  bool showMyDeals = true;
  bool showRedeemedEmptyState = false;
  bool showExpiredEmptyState = false;
  bool loadingMore = false;

  final List<dynamic> items = [
    {
      "logo_url": AppImages.storelogo,
      "name": "RoadChef Cafe",
    },
    {
      "logo_url": AppImages.storelogo1,
      "name": "Angelos Cafe",
    },
    {
      "logo_url": AppImages.storelogo2, // Placeholder logo URL
      "name": "RedOnions Cafe", // Name of the item
    },
    {
      "logo_url": AppImages.storelogo3, // Placeholder logo URL
      "name": "Crafted By Neneh", // Name of the item
    },
    {
      "logo_url": AppImages.storelogo4, // Placeholder logo URL
      "name": "Skybox Restaurant & Bar", // Name of the item
    },
    {
      "logo_url": AppImages.storelogo5, // Placeholder logo URL
      "name": "ActiCare", // Name of the item
    },
    {
      "logo_url": AppImages.storelogo6, // Placeholder logo URL
      "name": "Angelos Cafe", // Name of the item
    },
    {
      "logo_url": AppImages.storelogo7, // Placeholder logo URL
      "name": "Angelos Cafe", // Name of the item
    },
    {
      "logo_url": AppImages.storelogo8, // Placeholder logo URL
      "name": "Angelos Cafe", // Name of the item
    },
    {
      "logo_url": AppImages.storelogo9, // Placeholder logo URL
      "name": "Angelos Cafe", // Name of the item
    },
    {
      "logo_url": AppImages.storelogo10, // Placeholder logo URL
      "name": "Angelos Cafe", // Name of the item
    },
  ];

  void _loadDeals() async {
    setState(() {
      isLoading = true;
    });
    final voucherProvider =
        Provider.of<VoucherProvider>(context, listen: false);
    try {
      // Perform the API calls concurrently
      final results = await Future.wait([
        voucherProvider.getMyDeals(
            token: widget.token, search: searchController.text),
        voucherProvider.getMyDeals(
            token: widget.token,
            search: searchController.text,
            isRedeemed: true),
        voucherProvider.getMyDeals(
            token: widget.token,
            search: searchController.text,
            isExpired: true),
      ]);

      // results for all Deals
      if (results[0]["success"]) {
        final allMydeals = results[0];
        setState(() {
          isLoading = false;
          _totalAllDealsPages = allMydeals["data"]["totalPage"];
          allDeals = allMydeals["data"]["items"]
            ..sort((a, b) {
              DateTime dateA =
                  DateTime.tryParse(a["EndDate"] ?? "") ?? DateTime(1970);
              DateTime dateB =
                  DateTime.tryParse(b["EndDate"] ?? "") ?? DateTime(1970);
              return dateB.compareTo(dateA); // Sort in descending order
            });
          if (allMydeals["data"]["totalNumber"] == 0) {
            showAllEmptyState = true;
          }
        });
      } else {
        setState(() {
          isLoading = false;
          showAllEmptyState = true;
        });
      }

      // results for Redeemed Deals
      if (results[1]["success"]) {
        final allRedeemedDeals = results[1];
        setState(() {
          isLoading = false;
          _totalRedeemedDealsPages = allRedeemedDeals["data"]["totalPage"];
          allDeals = allRedeemedDeals["data"]["items"]
            ..sort((a, b) {
              DateTime dateA =
                  DateTime.tryParse(a["EndDate"] ?? "") ?? DateTime(1970);
              DateTime dateB =
                  DateTime.tryParse(b["EndDate"] ?? "") ?? DateTime(1970);
              return dateB.compareTo(dateA); // Sort in descending order
            });
          if (allRedeemedDeals["data"]["totalNumber"] == 0) {
            showRedeemedEmptyState = true;
          }
        });
      } else {
        setState(() {
          isLoading = false;
          showRedeemedEmptyState = true;
        });
      }
      // results for Expired Deals
      if (results[2]["success"]) {
        final allExpiredDeals = results[2];
        setState(() {
          isLoading = false;
          _totalExpiredDealsPages = allExpiredDeals["data"]["totalPage"];
          expiredDeals = allExpiredDeals["data"]["items"]
            ..sort((a, b) {
              DateTime dateA =
                  DateTime.tryParse(a["EndDate"] ?? "") ?? DateTime(1970);
              DateTime dateB =
                  DateTime.tryParse(b["EndDate"] ?? "") ?? DateTime(1970);
              return dateB.compareTo(dateA); // Sort in descending order
            });
          if (allExpiredDeals["data"]["totalNumber"] == 0) {
            showExpiredEmptyState = true;
          }
        });
      } else {
        setState(() {
          isLoading = false;
          showExpiredEmptyState = true;
        });
      }
    } catch (error) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _onScrollAllDeals() async {
    final provider = Provider.of<VoucherProvider>(context, listen: false);
    if (_AllDealScrollController.position.pixels >=
        _AllDealScrollController.position.maxScrollExtent - 200) {
      //print("_totalPages $_totalPages _currentPage $_currentPage");
      if (_currentAllDealsPage < _totalAllDealsPages) {
        ++_currentAllDealsPage;
        setState(() {
          loadingMore = true;
        });
        final voucherProvider =
            Provider.of<VoucherProvider>(context, listen: false);
        try {
          // Perform the API calls concurrently
          final results = await Future.wait([
            voucherProvider.getMyDeals(
            token: widget.token, search: searchController.text, page: _currentAllDealsPage),
          ]);

       // results for all Deals
      if (results[0]["success"]) {
        final allMydeals = results[0];
        setState(() {
          isLoading = false;
          _totalAllDealsPages = allMydeals["data"]["totalPage"];
          allDeals.add(allMydeals["data"]["items"]
            ..sort((a, b) {
              DateTime dateA =
                  DateTime.tryParse(a["EndDate"] ?? "") ?? DateTime(1970);
              DateTime dateB =
                  DateTime.tryParse(b["EndDate"] ?? "") ?? DateTime(1970);
              return dateB.compareTo(dateA); // Sort in descending order
            }));
          if (allMydeals["data"]["totalNumber"] == 0) {
            showAllEmptyState = true;
          }
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
        } catch (error) {
          // Handle errors here
          print('Error fetching data: $error');
        }
      }
    }
  }

  Future<void> _onScrollRedeemedDeals() async {
    final provider = Provider.of<VoucherProvider>(context, listen: false);
    if (_RedeemedDealScrollController.position.pixels >=
        _RedeemedDealScrollController.position.maxScrollExtent - 200) {
      //print("_totalPages $_totalPages _currentPage $_currentPage");
      if (_currentRedeemedDealsPage < _totalRedeemedDealsPages) {
        ++_currentRedeemedDealsPage;
        setState(() {
          loadingMore = true;
        });
        final voucherProvider =
            Provider.of<VoucherProvider>(context, listen: false);
        try {
          // Perform the API calls concurrently
          final results = await Future.wait([
            voucherProvider.getMyDeals(
            token: widget.token, search: searchController.text,
            isRedeemed: true, page: _currentRedeemedDealsPage),
          ]);

      // results for Redeemed Deals
      if (results[0]["success"]) {
        final allRedeemedDeals = results[0];
        setState(() {
          isLoading = false;
          _totalRedeemedDealsPages = allRedeemedDeals["data"]["totalPage"];
          allDeals.add(allRedeemedDeals["data"]["items"]
            ..sort((a, b) {
              DateTime dateA =
                  DateTime.tryParse(a["EndDate"] ?? "") ?? DateTime(1970);
              DateTime dateB =
                  DateTime.tryParse(b["EndDate"] ?? "") ?? DateTime(1970);
              return dateB.compareTo(dateA); // Sort in descending order
            }));
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
        } catch (error) {
          // Handle errors here
          print('Error fetching data: $error');
        }
      }
    }
  }

  Future<void> _onScrollExpiredDeal() async {
    final provider = Provider.of<VoucherProvider>(context, listen: false);
    if (_ExpiredDealScrollController.position.pixels >=
        _ExpiredDealScrollController.position.maxScrollExtent - 200) {
      if (_currentExpiredDealsPage < _totalExpiredDealsPages) {
        ++_currentExpiredDealsPage;
        setState(() {
          loadingMore = true;
        });
        final voucherProvider =
            Provider.of<VoucherProvider>(context, listen: false);
        try {
          // Perform the API calls concurrently
          final results = await Future.wait([
            voucherProvider.getMyDeals(
            token: widget.token, search: searchController.text,
            isExpired: true,page: _currentExpiredDealsPage),
          ]);

       // results for Expired Deals
      if (results[0]["success"]) {
        final allExpiredDeals = results[0];
        setState(() {
          isLoading = false;
          _totalExpiredDealsPages = allExpiredDeals["data"]["totalPage"];
          expiredDeals.add(allExpiredDeals["data"]["items"]
            ..sort((a, b) {
              DateTime dateA =
                  DateTime.tryParse(a["EndDate"] ?? "") ?? DateTime(1970);
              DateTime dateB =
                  DateTime.tryParse(b["EndDate"] ?? "") ?? DateTime(1970);
              return dateB.compareTo(dateA); // Sort in descending order
            }));
          if (allExpiredDeals["data"]["totalNumber"] == 0) {
            showExpiredEmptyState = true;
          }
        });
      } else {
        setState(() {
          isLoading = false;
          showExpiredEmptyState = true;
        });
      }
        } catch (error) {
          // Handle errors here
          print('Error fetching data: $error');
        }
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _AllDealScrollController = ScrollController();
    _AllDealScrollController.addListener(_onScrollAllDeals);
    _RedeemedDealScrollController = ScrollController();
    _RedeemedDealScrollController.addListener(_onScrollRedeemedDeals);
    _ExpiredDealScrollController = ScrollController();
    _ExpiredDealScrollController.addListener(_onScrollExpiredDeal);
    _loadDeals();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: AppColor.white,
      body: Center(
        child: Container(
          color: Colors.white,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Container(
                height: size.height * 0.12,
                alignment: Alignment.bottomCenter,
                padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
                child: const Text(
                  "My Deals",
                  style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                      color: AppColor.dark),
                ),
              ),
              Container(
                height: 2,
                width: size.width,
                color: Colors.grey[300],
              ),
              SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.only(bottom: 0),
                width: size.width * 0.8,
                alignment: Alignment.bottomCenter,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    TabButton(
                      label: "My deals",
                      isActive: activeTabIndex == 0,
                      onTap: () {
                        //_loadAllDeals();
                        setState(() {
                          activeTabIndex = 0;
                        });
                      },
                    ),
                    TabButton(
                      label: "My Stores",
                      isActive: activeTabIndex == 2,
                      onTap: () {
                        //_loadNearByDeals();
                        setState(() {
                          activeTabIndex = 2;
                        });
                      },
                    ),
                  ],
                ),
              ),
              Visibility(
                visible: showMyDeals,
                child: Container(
                  padding: const EdgeInsets.only(bottom: 0),
                  width: size.width,
                  alignment: Alignment.bottomCenter,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(5),
                        child: TabButton2(
                          label: "All deals",
                          isActive: subActiveTabIndex == 0,
                          onTap: () {
                            //_loadAllDeals();
                            setState(() {
                              subActiveTabIndex = 0;
                            });
                          },
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(5),
                        child: TabButton2(
                          label: "Redeemed",
                          isActive: subActiveTabIndex == 1,
                          onTap: () {
                            //_loadNearByDeals();
                            setState(() {
                              subActiveTabIndex = 1;
                            });
                          },
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(5),
                        child: TabButton2(
                          label: "Expired",
                          isActive: subActiveTabIndex == 2,
                          onTap: () {
                            //_loadNearByDeals();
                            setState(() {
                              subActiveTabIndex = 2;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                  // height: size.height * 0.62,
                  child: Stack(
                children: [
                  ListView.builder(
                      padding: EdgeInsets.symmetric(horizontal: 5),
                      controller: (subActiveTabIndex == 0)?_AllDealScrollController:(subActiveTabIndex == 1)?_RedeemedDealScrollController:_ExpiredDealScrollController,
                      itemCount: (subActiveTabIndex == 0)?allDeals.length:(subActiveTabIndex == 1)?redeemedDeals.length:expiredDeals.length,
                      itemBuilder: (context, index) {
                        return MyDealCard(deal: (subActiveTabIndex == 0)?allDeals[index]:(subActiveTabIndex == 1)?redeemedDeals[index]:expiredDeals[index], token: widget.token);
                      }),
                  
                  if (loadingMore)
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Center(
                          child: CircularProgressIndicator(
                        color: AppColor.primaryColor,
                      )),
                    ),
                  if (isLoading)
                    Container(
                      //color: AppColor.background,
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: AppColor.primaryColor,
                        ),
                      ),
                    ),
                  if ((subActiveTabIndex == 0)?showAllEmptyState:(subActiveTabIndex == 1)?showRedeemedEmptyState:showExpiredEmptyState)
                    Container(
                      child: Center(
                        child: Image.asset(
                          AppImages.empty_state,
                          width: size.width,
                          height: size.height * 0.2,
                          fit: BoxFit.fitHeight,
                        ),
                      ),
                    ),
                ],
              )),
            ],
          ),
        ),
      ),
    );
  }
}
