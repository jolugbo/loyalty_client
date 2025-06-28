import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:moniback/providers/auth_providers.dart';
import 'package:moniback/providers/promotion_provider.dart';
import 'package:moniback/providers/voucher_provider.dart';
import 'package:moniback/utils/constants/app_colors.dart';
import 'package:moniback/utils/constants/app_images.dart';
import 'package:moniback/utils/styles/text_style.dart';
import 'package:moniback/utils/widget/card.dart';
import 'package:moniback/utils/widget/custom_snackbar.dart';
import 'package:moniback/utils/widget/search_text.dart';
import 'package:moniback/utils/widget/tab_button.dart';
import 'package:provider/provider.dart';

class Home extends StatefulWidget {
  final token;
  const Home({required this.token, super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int activeTabIndex = 0;
  bool isLoading = false;
  bool showEmptyState = false;
  bool permGranted = false;
  int _currentPage = 1;
  int _totalPages = 1;
  List<dynamic> deals = [];
  List<dynamic> dealsHolders = [];
  late ScrollController _scrollController;
  final TextEditingController searchController = TextEditingController();
  bool loadingMore = false;
  String longitude ="";
  String latitude ="";

  void filterList(String searchTerm) {
    setState(() {
      deals = dealsHolders.where((promo) {
        final name = promo["Name"]?.toString().toLowerCase() ?? "";
        final description =
            promo["Description"]?.toString().toLowerCase() ?? "";
        final businessName =
            promo["BusinessName"]?.toString().toLowerCase() ?? "";
        final query = searchTerm.toLowerCase();

        return name.contains(query) ||
            description.contains(query) ||
            businessName.contains(query);
      }).toList();
    });
  }

  Future<void> _checkLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        permGranted = true;
      });
      return;
    }

    // Check for permission
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      setState(() {
        permGranted = true;
      });
    } else if (permission == LocationPermission.deniedForever) {
      setState(() {
        permGranted = true;
      });
    } else {

      // Optional: get location
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {
        permGranted = false;
        longitude = position.longitude.toString();
        latitude = position.latitude.toString();
      });
      print("Your location: ${position.latitude}, ${position.longitude}");
    }
  }

  void _load() async {
    _checkLocationPermission;
    setState(() {
      isLoading = true;
      showEmptyState = false;
      _currentPage = 1;
    });
    final voucherProvider =
        Provider.of<VoucherProvider>(context, listen: false);
    try {
      // Perform the API calls concurrently
      final results = await Future.wait([
        voucherProvider.getDeals(
            token: widget.token, search: searchController.text),
      ]);

      // Extract the results
      if( results[0]["success"]){
      final dealsList = results[0];
      setState(() {
        isLoading = false;
        _totalPages = dealsList["data"]["totalPage"];
        deals = dealsList["data"]["items"]
          ..sort((a, b) {
            DateTime dateA =
                DateTime.tryParse(a["EndDate"] ?? "") ?? DateTime(1970);
            DateTime dateB =
                DateTime.tryParse(b["EndDate"] ?? "") ?? DateTime(1970);
            return dateB.compareTo(dateA); // Sort in descending order
          });
        dealsHolders = dealsList["data"]["items"]
          ..sort((a, b) {
            DateTime dateA =
                DateTime.tryParse(a["EndDate"] ?? "") ?? DateTime(1970);
            DateTime dateB =
                DateTime.tryParse(b["EndDate"] ?? "") ?? DateTime(1970);
            return dateB.compareTo(dateA); // Sort in descending order
          });
      });
      }
      else{
         setState(() {
        isLoading = false;
        showEmptyState = true;
      });
      }
    } catch (error) {
      setState(() {
        isLoading = false;
        showEmptyState = true;
      });
      // Handle errors here
      print('Error fetching data: $error');
    }
  }

  void _loadNearByDeals() async {
    _checkLocationPermission;
    if(permGranted){
      showEmptyState = true;
          CustomSnackbar.showError(context, "Enable Location Services");
          return;
    };
    setState(() {
      isLoading = true;
      showEmptyState = false;
      _currentPage = 1;
    });
    final voucherProvider =
        Provider.of<VoucherProvider>(context, listen: false);
    try {
      // Perform the API calls concurrently
      final results = await Future.wait([
        voucherProvider.getDealsByLocation(
            token: widget.token, search: searchController.text,latitude: latitude,longitude: longitude),
      ]);

      // Extract the results
      if( results[0]["success"]){
      final dealsList = results[0];
      setState(() {
        isLoading = false;
        _totalPages = dealsList["data"]["totalPage"];
        deals = dealsList["data"]["items"]
          ..sort((a, b) {
            DateTime dateA =
                DateTime.tryParse(a["EndDate"] ?? "") ?? DateTime(1970);
            DateTime dateB =
                DateTime.tryParse(b["EndDate"] ?? "") ?? DateTime(1970);
            return dateB.compareTo(dateA); // Sort in descending order
          });
        dealsHolders = dealsList["data"]["items"]
          ..sort((a, b) {
            DateTime dateA =
                DateTime.tryParse(a["EndDate"] ?? "") ?? DateTime(1970);
            DateTime dateB =
                DateTime.tryParse(b["EndDate"] ?? "") ?? DateTime(1970);
            return dateB.compareTo(dateA); // Sort in descending order
          });
      });
      }
      else{
         setState(() {
        isLoading = false;
        showEmptyState = true;
      });
      }
    } catch (error) {
      setState(() {
        isLoading = false;
        showEmptyState = true;
      });
      // Handle errors here
      print('Error fetching data: $error');
    }
  }

  void _loadBookmarked() async {
    setState(() {
      isLoading = true;
      deals = dealsHolders.where((promo) {
        final IsMarkedLiked = promo["IsBookmarked"];
        //final IsLiked = promo["IsLiked"];
        return IsMarkedLiked == true; // || IsLiked == true;
      }).toList();
    });
    isLoading = false;
  }

  void _loadAllDeals() async {
    setState(() {
      isLoading = true;
      deals = dealsHolders;
    });
    isLoading = false;
  }

  Future<void> requestLocation(BuildContext context) async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Location services are disabled.')),
      );
      return;
    }

    // Check permission status
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Location permissions are denied')),
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Location permissions are permanently denied.')),
      );
      return;
    }

    // If permissions are granted, get the current position
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    print('Location: ${position.latitude}, ${position.longitude}');
  }

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    _checkLocationPermission();
    _load();
  }

  Future<void> _onScroll() async {
    final provider = Provider.of<VoucherProvider>(context, listen: false);
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      //print("_totalPages $_totalPages _currentPage $_currentPage");
      if (_currentPage < _totalPages) {
        ++_currentPage;
        setState(() {
          loadingMore = true;
        });
        final voucherProvider =
            Provider.of<VoucherProvider>(context, listen: false);
        try {
          // Perform the API calls concurrently
          final results = await Future.wait([
            voucherProvider.getDeals(token: widget.token, page: _currentPage),
          ]);

          // Extract the results
          final dealsList = results[0];

          setState(() {
            loadingMore = false;
            _totalPages = dealsList["data"]["totalPage"];
            deals.addAll(dealsList["data"]["items"]);
            dealsHolders = deals;
            // ..sort((a, b) {
            //   DateTime dateA =
            //       DateTime.tryParse(a["EndDate"] ?? "") ?? DateTime(1970);
            //   DateTime dateB =
            //       DateTime.tryParse(b["EndDate"] ?? "") ?? DateTime(1970);
            //   return dateB.compareTo(dateA); // Sort in descending order
            // }));
            //dealsHolders.addAll(dealsList["data"]["promotions"]);
            // ..sort((a, b) {
            //   DateTime dateA =
            //       DateTime.tryParse(a["EndDate"] ?? "") ?? DateTime(1970);
            //   DateTime dateB =
            //       DateTime.tryParse(b["EndDate"] ?? "") ?? DateTime(1970);
            //   return dateB.compareTo(dateA); // Sort in descending order
            // }));
          });
          print(deals.length);
          print(dealsList["data"]["promotions"].length);
        } catch (error) {
          // Handle errors here
          print('Error fetching data: $error');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Container(
      color: AppColor.white,
      child: Stack(children: [
        Container(
          height: size.height * 0.15,
          color: AppColor.primaryColor,
          child: Image.asset(
            AppImages.header_bg,
            width: size.width,
            height: size.height * 0.15,
            fit: BoxFit.cover,
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                    width: size.width,
                    padding: EdgeInsets.fromLTRB(10, size.height * 0.02, 10, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Image.asset(
                          AppImages.logo2,
                          width: size.width * 0.25,
                        ),
                        GestureDetector(
                          onTap: () {},
                          child: Image.asset(
                            AppImages.notification,
                            width: size.width * 0.2,
                          ),
                        )
                      ],
                    )),
                Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18.0),
                    child: SearchTextField(
                      controller: searchController,
                      onChanged: (value) {
                        filterList(value);
                      },
                    )),
              ],
            ),
            SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.only(bottom: 0),
              alignment: Alignment.bottomCenter,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                  TabButton(
                    label: "All Deals",
                    isActive: activeTabIndex == 0,
                    onTap: () {
                      _loadAllDeals();
                      setState(() {
                        activeTabIndex = 0;
                      });
                    },
                  ),
                  TabButton(
                    label: "Nearby Deals",
                    isActive: activeTabIndex == 2,
                    onTap: () {
                    _loadNearByDeals();
                      setState(() {
                        activeTabIndex = 2;
                      });
                    },
                  ),
                  TabButton(
                    label: "Bookmarked",
                    isActive: activeTabIndex == 1,
                    onTap: () {
                      _loadBookmarked();
                      setState(() {
                        activeTabIndex = 1;
                      });
                    },
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            Visibility(
              visible: permGranted,
              child: Container(
                width: size.width,
                margin: EdgeInsets.fromLTRB(
                    size.width * 0.1, 0, size.width * 0.1, 0),
                alignment: Alignment.center,
                child: GestureDetector(
                  onTap: () {
                    requestLocation(context);
                  },
                  child: Card(
                    color: AppColor.white,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(width: 20),
                        CircleAvatar(
                          backgroundColor: AppColor.bordergrey,
                          child: Image.asset(
                            AppImages.router,
                          ),
                        ),
                        SizedBox(width: 10),
                        Container(
                          width: size.width * 0.6,
                          alignment: Alignment.center,
                          padding: EdgeInsets.fromLTRB(0, size.width * 0.06,
                              size.width * 0.06, size.width * 0.06),
                          child: const Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: "Looking for something nearby?\n",
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: AppColor.dark,
                                  ),
                                ),
                                TextSpan(
                                  text: "Allow location access",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColor.grey2,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
                // height: size.height * 0.62,
                child: Stack(
              children: [
                ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 5),
                    controller: _scrollController,
                    itemCount: deals.length,
                    itemBuilder: (context, index) {
                      return DealCard(deal: deals[index], token: widget.token);
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
                if (showEmptyState)
                  Container(
                    child: Center(
                      child: Image.asset(
                        AppImages.error_state,
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
      ]),
    );
  }
}
