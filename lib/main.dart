import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:vault_it/app.dart';
import 'package:vault_it/config/localization/app_localization.dart';
import 'package:vault_it/injection_container.dart' as di;
import 'package:vault_it/core/ads/ad_manager.dart';
import 'package:vault_it/core/purchase/purchase_manager.dart';

Future<void> main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  
  // Initialize core services
  await AppLocalization.initialize();
  await di.init();
  
  // Initialize Purchase Manager first
  await PurchaseManager().initialize();
  
  // Initialize Ad Manager (will check premium status)
  await AdManager().initialize(
    onPremiumPromptShow: () {
      // Premium prompt will be shown via navigation
      debugPrint('💎 Premium prompt triggered');
    },
  );
  
  // Sync premium status between managers
  await AdManager().setPremiumStatus(PurchaseManager().isPremium);
  
  runApp(const VaultItApp());
}
