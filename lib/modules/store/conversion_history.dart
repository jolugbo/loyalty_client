import 'package:flutter/material.dart';
import 'package:moniback/modules/store/store.dart';
import 'package:moniback/providers/store_provider.dart';
import 'package:moniback/providers/voucher_provider.dart';
import 'package:moniback/utils/constants/app_colors.dart';
import 'package:moniback/utils/constants/app_images.dart';
import 'package:moniback/utils/widget/my_deal_card.dart';
import 'package:moniback/utils/widget/tab_button.dart';
import 'package:provider/provider.dart';

class ConversionHistory extends StatefulWidget {
  final token;
  const ConversionHistory({required this.token, super.key});
  @override
  State<ConversionHistory> createState() => _ConversionHistoryState();
}

class _ConversionHistoryState extends State<ConversionHistory> {
  bool isLoading = false;
  List<dynamic> historyList = [];
  bool showEmptyState = false;
  final List<Map<String, dynamic>> history = [
    {
      "status": "success",
      "title": "Conversion successful",
      "subtitle": "Converted 200 loyalty points to 199.9 store credits",
      "date": "Today",
      "time": "Just now"
    },
    {
      "status": "failed",
      "title": "Conversion failed",
      "subtitle": "Insufficient loyalty points to convert",
      "date": "Today",
      "time": "Just now"
    },
    {
      "status": "success",
      "title": "Conversion successful",
      "subtitle": "Converted 200 loyalty points to 199.9 store credits",
      "date": "24 May",
      "time": "Just now"
    },
  ];
  
  void _load() async {
    setState(() {
      isLoading = true;
    });

    final voucherProvider =
        Provider.of<VoucherProvider>(context, listen: false);

    try {
      // Perform the API calls concurrently
      final results = await Future.wait([
        voucherProvider.getConversionHistory(token: widget.token),
      ]);

      // Extract the results
      if (results[0]["success"]) {
        setState(() {
          isLoading = false;
           historyList = results[0]["data"]["items"];
        });
      } else {
        setState(() {
          isLoading = false;
          showEmptyState = true;
        });
      }
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
    return Scaffold(
      backgroundColor: AppColor.white,
      appBar: AppBar(
        leading: const BackButton(color: Colors.black),
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Conversion History",
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
      ),
      body:ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 5),
                   // controller: _scrollController,
                    itemCount: historyList.length,
                    itemBuilder: (context, index) {
                      return buildCard(historyList[index]);
                    }),
      //  ListView(
      //   padding: const EdgeInsets.symmetric(horizontal: 16),
      //   children: buildGroupedHistory(),
      // ),
    );
  }

  List<Widget> buildGroupedHistory() {
    final Map<String, List<Map<String, dynamic>>> grouped = {};

    for (var item in history) {
      grouped.putIfAbsent(item["date"], () => []).add(item);
    }

    return grouped.entries.map((entry) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Text(
            entry.key,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 10),
          ...entry.value.map(buildCard).toList()
        ],
      );
    }).toList();
  }

  Widget buildCard(Map<String, dynamic> item) {
    final bool isSuccess = item["Title"] == "Conversion successful";

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSuccess ? Colors.green.shade50 : Colors.red.shade50,
            ),
            child: Icon(
              isSuccess ? Icons.check_circle_outline : Icons.cancel_outlined,
              color: isSuccess ? Colors.green : Colors.red,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item["Title"],
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item["Summary"],
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  item["DateGroup"],
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
