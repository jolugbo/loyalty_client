import 'package:flutter/material.dart';
import 'package:moniback/modules/store/store.dart';
import 'package:moniback/providers/store_provider.dart';
import 'package:moniback/providers/voucher_provider.dart';
import 'package:moniback/utils/constants/app_colors.dart';
import 'package:moniback/utils/constants/app_images.dart';
import 'package:moniback/utils/widget/back_button.dart';
import 'package:moniback/utils/widget/my_deal_card.dart';
import 'package:moniback/utils/widget/tab_button.dart';
import 'package:provider/provider.dart';

class Account extends StatefulWidget {
  final token;
  const Account({required this.token, super.key});
  @override
  State<Account> createState() => _AccountState();
}

class _AccountState extends State<Account> {
  int activeTabIndex = 0;
  int subActiveTabIndex = 0;
  final TextEditingController searchController = TextEditingController();
  bool isLoading = false;
  List<dynamic> allDeals = [];
  List<dynamic> redeemedDeals = [];
  List<dynamic> expiredDeals = [];
  List<dynamic> stores = [];
  int _currentAllDealsPage = 1;
  int _totalAllDealsPages = 1;
  int _currentRedeemedDealsPage = 1;
  int _totalRedeemedDealsPages = 1;
  int _currentExpiredDealsPage = 1;
  int _totalExpiredDealsPages = 1;
  int _totalStoresPages = 1;
  bool showAllEmptyState = false;
  bool showMyDeals = true;
  bool showRedeemedEmptyState = false;
  bool showExpiredEmptyState = false;
  bool showStoresEmptyState = false;
  bool loadingMore = false;

  void _loadDeals() async {
    setState(() {
      isLoading = true;
    });
    final voucherProvider =
        Provider.of<VoucherProvider>(context, listen: false);
    final storeProvider = Provider.of<StoreProvider>(context, listen: false);
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
        storeProvider.getStores(
          token: widget.token,
          page: 1,
          key: searchController.text,
        ),
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
          redeemedDeals = allRedeemedDeals["data"]["items"]
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
      print("Stores empty?........");

      // results for Stores
      if (results[3]["success"]) {
        print("Stores not empty........");
        final allStores = results[3];
        setState(() {
          isLoading = false;
          _totalStoresPages = allStores["data"]["totalPage"];
          stores = allStores["data"]["items"];
          if (allStores["data"]["totalNumber"] == 0) {
            showStoresEmptyState = true;
          }
        });
      } else {
        setState(() {
          isLoading = false;
          showStoresEmptyState = true;
        });
      }
    } catch (error) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    // _loadDeals();
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
                  child: Row(
                    children: [
                      const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: GoBackButtton(
                            iconColor: AppColor.dark,
                          )),
                      Expanded(
                        child: const Text(
                          "Account",
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 18,
                              color: AppColor.dark),
                        ),
                      )
                    ],
                  )),
              Container(
                height: 2,
                width: size.width,
                color: Colors.grey[300],
              ),
              Expanded(
                // height: size.height * 0.62,
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // User Info
                    Card(
                      elevation: 2,
                      color: AppColor.lightRed,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.redAccent,
                          child:
                              Text('B', style: TextStyle(color: Colors.white)),
                        ),
                        title: Text(
                          'Bose May',
                          style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 20,
                              color: AppColor.dark),
                        ),
                        subtitle: Text(
                          'bose.may@qbicles.com',
                          style: const TextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize: 14,
                              color: AppColor.dark),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Store Credit and Vouchers
                    Card(
                      elevation: 2,
                      color: AppColor.lightRed,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: const Padding(
                        padding:  EdgeInsets.symmetric(
                            horizontal: 20, vertical: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            Column(
                              children: [
                                Icon(Icons.store, color: Colors.red),
                                SizedBox(height: 4),
                                Text(
                                  'Store Credit',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 14,
                                      color: AppColor.dark),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  '₦ 0.00',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 20,
                                      color: AppColor.dark),
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                Icon(Icons.card_giftcard, color: Colors.green),
                                SizedBox(height: 4),
                                Text(
                                  'My vouchers',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 14,
                                      color: AppColor.dark),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  '0',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 20,
                                      color: AppColor.dark),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Menu Items
                    _buildMenuTile(Icons.person, 'Profile'),
                    _buildMenuTile(Icons.notifications, 'Notifications'),
                    _buildMenuTile(Icons.group_add, 'Invite friends'),
                    _buildMenuTile(Icons.security, 'Security'),
                    _buildMenuTile(Icons.help_outline, 'Help Center'),
                    _buildMenuTile(Icons.logout, 'Log out'),

                    const SizedBox(height: 24),

                    // Survey
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF2F2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Is Moniback easy to use?',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          const Text('Let us know'),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                            ),
                            onPressed: () {},
                            child: const Text('Take survey'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuTile(IconData icon, String title) {
    return ListTile(
      leading: Icon(icon, color: Colors.black87),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {},
    );
  }
}
