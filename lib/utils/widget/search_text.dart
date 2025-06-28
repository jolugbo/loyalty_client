import 'package:flutter/material.dart';
import 'package:moniback/utils/constants/app_colors.dart';
import 'package:moniback/utils/styles/text_style.dart';

class SearchTextField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;

  const SearchTextField({
    Key? key,
    required this.controller,
    this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return  Center(
      child: Container(
        //width: size.width * 0.8, // 80% of screen width
        padding: const EdgeInsets.symmetric(horizontal: 12.0), 
        alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(30.0), 
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: AppTextStyle.body(
                color: AppColor.dark, fontWeight: FontWeight.w700,size: 14),
        decoration: InputDecoration(
          hintText: 'Search...',
          border: InputBorder.none,
          prefixIcon: Icon(Icons.search, color: AppColor.lightdark),
          suffixIcon: Icon(Icons.filter_list, color: AppColor.lightdark),
        ),
        textInputAction: TextInputAction.search,
      ),
    ));
  }
}

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     final TextEditingController searchController = TextEditingController();

//     return MaterialApp(
//       home: Scaffold(
//         appBar: AppBar(
//           title: Text('Search Example'),
//         ),
//         body: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             children: [
//               SearchTextField(
//                 controller: searchController,
//                 onChanged: (value) {
//                   print('Search input: $value');
//                 },
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
