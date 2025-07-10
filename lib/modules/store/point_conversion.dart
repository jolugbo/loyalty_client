import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:moniback/modules/store/conversion_history.dart';
import 'package:moniback/providers/store_provider.dart';
import 'package:moniback/utils/constants/app_colors.dart';
import 'package:moniback/utils/constants/app_images.dart';
import 'package:moniback/utils/functions/helper.dart';
import 'package:moniback/utils/widget/app_button.dart';
import 'package:moniback/utils/widget/back_button.dart';
import 'package:moniback/utils/widget/custom_snackbar.dart';
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
  final TextEditingController _loyaltyPointsController =
      TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool isFormValid = false;
  double _halfValue = 0;

  @override
  void initState() {
    super.initState();
    _loyaltyPointsController.addListener(_updateHalfValue);
  }

  void _updateHalfValue() {
    final input = _loyaltyPointsController.text;
    final value = double.tryParse(input);
    setState(() {
      _halfValue = value != null ? value / 2 : 0;
    });
    print(_halfValue);
  }

  void _validateForm() {
    setState(() {
      isFormValid = _formKey.currentState?.validate() ?? false;
    });
  }

  Future<void> convertPoint() async {
    final input = _loyaltyPointsController.text;
    final value = double.tryParse(input);
    if (value == null || value <= 0) {
      CustomSnackbar.showError(context, "Please Input a value");
      return;
    }
    final storeProvider = Provider.of<StoreProvider>(context, listen: false);
    bool hasInternet = await HelperClass().hasInternetConnection();
    if (hasInternet) {
      setState(() {
        isLoading = true;
      });
      print("got here");
      final Map<String, dynamic> request = {
        "ContactKey": widget.business["ContactKey"],
        "ConvertValue": _loyaltyPointsController.text,
      };
      var resp = await storeProvider.point2StoreCredit(
          token: widget.token, converDetails: request);

      if (resp['success']) {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(resp["data"])),
        );
        Navigator.pop(context);
        Navigator.pop(context, 'refresh');
      } else {
        CustomSnackbar.showError(context, resp["data"]);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('No internet connection. Please try again later.')),
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
        actions: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ConversionHistory(
                          token: widget.token,
                        )),
              );
            },
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Container(
                height: 35,
                width: 35,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColor.white,
                    border: Border.all(color: AppColor.grey)),
                child: Icon(Icons.access_time_rounded,
                    size: 25, color: AppColor.dark),
              ),
            ),
          )
        ],
        title: const Text(
          "Convert to store credit",
          style: TextStyle(
              color: AppColor.dark, fontSize: 16, fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Stack(children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildInputField(
                  controller: _loyaltyPointsController,
                  label: 'Loyalty points',
                  icon: Icons.star_border,
                  availableAmount: "${widget.business["Points"]}",
                  isLoyaltyPoints: true,
                ),
                const SizedBox(height: 20),
                const Icon(Icons.arrow_downward, color: Colors.grey, size: 30),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 15.0, vertical: 5.0),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.red.shade50,
                          radius: 20,
                          child: Icon(
                            Icons.store,
                            color: Colors.red,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 15),
                        Text(
                          'Store credits', // The '0' on the right of the input field
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            "$_halfValue",
                            textAlign: TextAlign.right,
                            style: TextStyle(fontSize: 16, color: Colors.black),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'Available Store credits: ${widget.business["StoreCredit"]}',
                    style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                  ),
                ),
                const SizedBox(height: 30),
                _buildConversionRateDisplay(),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: AppButton(
                      title: 'Continue',
                      isEnabled: true,
                      textColor: AppColor.black,
                      color: AppColor.primaryColor,
                      textSize: 16,
                      onTap: () async {
                        convertPoint();
                      }),
                ),
              ],
            ),
            if (isLoading)
              Container(
                color: Colors.black.withOpacity(0.5),
                height: size.height * 0.9,
                child: Center(
                  child: CircularProgressIndicator(
                    color: AppColor.primaryColor,
                  ),
                ),
              ),
          ])),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String availableAmount,
    required bool isLoyaltyPoints,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300, width: 1.5),
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 15.0, vertical: 5.0),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: isLoyaltyPoints
                      ? Colors.orange.shade100
                      : Colors.red.shade50,
                  radius: 20,
                  child: Icon(
                    icon,
                    color: isLoyaltyPoints ? Colors.orange : Colors.red,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 15),
                Text(
                  label, // The '0' on the right of the input field
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey.shade600,
                  ),
                ),
                Expanded(
                  child: TextField(
                    controller: controller,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.right,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                          RegExp(r'^\d+\.?\d{0,1}'))
                    ], // Allows numbers and one decimal place
                    decoration: InputDecoration(
                      // hintText: label,
                      border: InputBorder.none,
                      isDense: true,
                    ),
                    style: const TextStyle(fontSize: 18, color: AppColor.dark),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 5),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            'Available ${label.toLowerCase()}: ${availableAmount}',
            style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
          ),
        ),
      ],
    );
  }

  Widget _buildConversionRateDisplay() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.star_border, color: Colors.orange.shade700, size: 20),
          const SizedBox(width: 5),
          const Text(
            '1 loyalty points =',
            style: TextStyle(
              color: Colors.black,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 10),
          Icon(Icons.store, color: Colors.red.shade700, size: 20),
          const SizedBox(width: 5),
          Text(
            '2 store credits',
            style: const TextStyle(
              color: Colors.black,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
