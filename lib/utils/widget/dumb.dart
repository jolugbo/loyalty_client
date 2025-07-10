import 'package:flutter/material.dart';

class ConversionHistoryPage extends StatelessWidget {
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

  @override
  Widget build(BuildContext context) {
    return        SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // User Info
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.redAccent,
                    child: Text('B', style: TextStyle(color: Colors.white)),
                  ),
                  title: Text('Bose May'),
                  subtitle: Text('bose.may@qbicles.com'),
                ),
              ),
              const SizedBox(height: 16),

              // Store Credit and Vouchers
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Column(
                        children: [
                          Icon(Icons.store, color: Colors.red),
                          SizedBox(height: 4),
                          Text('Store Credit'),
                          SizedBox(height: 4),
                          Text('₦ 0.00', style: TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                      Column(
                        children: [
                          Icon(Icons.card_giftcard, color: Colors.green),
                          SizedBox(height: 4),
                          Text('My vouchers'),
                          SizedBox(height: 4),
                          Text('0', style: TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Menu Items
              // _buildMenuTile(Icons.person, 'Profile'),
              // _buildMenuTile(Icons.notifications, 'Notifications'),
              // _buildMenuTile(Icons.group_add, 'Invite friends'),
              // _buildMenuTile(Icons.security, 'Security'),
              // _buildMenuTile(Icons.help_outline, 'Help Center'),
              // _buildMenuTile(Icons.logout, 'Log out'),

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
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
      ;
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
    final bool isSuccess = item["status"] == "success";

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
                  item["title"],
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item["subtitle"],
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  item["time"],
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
