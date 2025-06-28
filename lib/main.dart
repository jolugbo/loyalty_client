import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:moniback/utils/widget/refresh.dart';
import 'package:moniback/modules/walk_through/root.dart';
import 'package:moniback/providers/count_down_manager.dart';
import 'package:moniback/providers/promotion_provider.dart';
import 'package:moniback/providers/session_manager.dart';
import 'package:moniback/providers/store_provider.dart';
import 'package:moniback/providers/voucher_provider.dart';
import 'package:moniback/utils/constants/app_colors.dart';
import 'package:moniback/providers/auth_providers.dart';
import 'package:provider/provider.dart';
//codex
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(create: (_) => SessionManager()),
    ChangeNotifierProvider(create: (_) => CountdownManager()),
    ChangeNotifierProxyProvider<SessionManager, AuthProvider>(
      create: (_) => AuthProvider(sessionManager: SessionManager()),
      update: (_, sessionManager, __) =>
          AuthProvider(sessionManager: sessionManager),
    ),
//    ChangeNotifierProxyProvider3<CountdownManager, AuthProvider, SessionManager,
//     PromotionProvider>(
//   create: (_) => PromotionProvider(
//     countdownManager: CountdownManager(), // temporary, will be overridden
//     authProvider: AuthProvider(sessionManager: SessionManager()), // temp
//     sessionManager: SessionManager(), // temp
//   ),
//   update: (_, countdownManager, authProvider, sessionManager, __) =>
//       PromotionProvider(
//     countdownManager: countdownManager,
//     authProvider: authProvider,
//     sessionManager: sessionManager,
//   ),
// ),
ChangeNotifierProxyProvider3<CountdownManager, AuthProvider, SessionManager,
    StoreProvider>(
  create: (_) => StoreProvider(
    countdownManager: CountdownManager(), // temporary, will be overridden
    authProvider: AuthProvider(sessionManager: SessionManager()), // temp
    sessionManager: SessionManager(), // temp
  ),
  update: (_, countdownManager, authProvider, sessionManager, __) =>
      StoreProvider(
    countdownManager: countdownManager,
    authProvider: authProvider,
    sessionManager: sessionManager,
  ),
),ChangeNotifierProxyProvider3<CountdownManager, AuthProvider, SessionManager,
    VoucherProvider>(
  create: (_) => VoucherProvider(
    countdownManager: CountdownManager(), // temporary, will be overridden
    authProvider: AuthProvider(sessionManager: SessionManager()), // temp
    sessionManager: SessionManager(), // temp
  ),
  update: (_, countdownManager, authProvider, sessionManager, __) =>
      VoucherProvider(
    countdownManager: countdownManager,
    authProvider: authProvider,
    sessionManager: sessionManager,
  ),
),
  ], child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
        designSize: const Size(360, 690),
        minTextAdapt: true,
        splitScreenMode: true,
        // Use builder only if you need to use library outside ScreenUtilInit context
        builder: (_, child) {
          return MaterialApp(
            navigatorKey: navigatorKey,
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              primarySwatch: Colors.red,
              splashColor: AppColor.primaryColor,
              textTheme: Typography.englishLike2018.apply(fontSizeFactor: 1.sp),
            ),
            home: const WalkthroughScreen(),
          );
        });
  }
}
