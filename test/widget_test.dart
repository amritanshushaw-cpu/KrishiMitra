import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartfarm_app/main.dart';
import 'package:smartfarm_app/state/farm_provider.dart';
import 'package:smartfarm_app/services/secure_db_service.dart';
import 'package:smartfarm_app/ui/screens/auth_screen.dart';
import 'package:smartfarm_app/ui/screens/profile_settings_tab.dart';

void main() {
  testWidgets('SmartFarmEdgeApp smoke test', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({'isLoggedIn': true});
    await tester.pumpWidget(const SmartFarmEdgeApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('KRISHIMITRA'), findsWidgets);
  });

  testWidgets('AuthScreen shows Name field on Sign Up toggle', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => FarmProvider(),
        child: const MaterialApp(home: AuthScreen()),
      ),
    );
    await tester.pump();

    // Initial state is Sign In - Name field shouldn't be present
    expect(find.text('Sign In'), findsOneWidget);
    expect(find.text('FARMER FULL NAME'), findsNothing);

    // Tap to switch to Create Account (Sign Up)
    await tester.tap(find.text('No account yet? Create one.'));
    await tester.pump();

    // Now Sign Up state is active - Farmer Full Name field must appear
    expect(find.text('Create Farmer Account'), findsOneWidget);
    expect(find.text('FARMER FULL NAME'), findsOneWidget);
    expect(find.byIcon(Icons.badge_outlined), findsOneWidget);
  });

  testWidgets('ProfileSettingsTab displays synced Farmer Name and Log Out options', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({
      'isLoggedIn': true,
      'farmer_name': 'Ramesh Kumar',
    });

    final provider = FarmProvider();
    provider.setFarmerName('Ramesh Kumar');

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: provider,
        child: MaterialApp(
          home: Scaffold(
            body: ProfileSettingsTab(onOpenSafetyNet: () {}),
          ),
        ),
      ),
    );
    await tester.pump();

    // Verify synced farmer name is rendered in profile card
    expect(find.text('Ramesh Kumar'), findsOneWidget);

    // Verify Log Out buttons exist (both quick header icon and bottom card)
    expect(find.byIcon(Icons.logout_rounded), findsWidgets);
    expect(find.text('LOG OUT SESSION'), findsOneWidget);
  });

  testWidgets('ProfileSettingsTab auto-fetches and updates location', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({
      'isLoggedIn': true,
      'farmer_name': 'Saptak',
      'farmer_location': 'Kolkata, West Bengal',
      'farmer_lat': 22.5643,
      'farmer_lon': 88.3693,
    });

    final provider = FarmProvider();
    provider.setFarmerLocation('Kolkata, West Bengal');

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: provider,
        child: MaterialApp(
          home: Scaffold(
            body: ProfileSettingsTab(onOpenSafetyNet: () {}),
          ),
        ),
      ),
    );
    await tester.pump();

    // Verify synced farmer location is rendered in profile card
    expect(find.text('Kolkata, West Bengal'), findsOneWidget);

    // Verify geolocation section and auto-fetch button
    expect(find.text('FARM LOCATION & GPS SYNCHRONIZATION'), findsOneWidget);
    expect(find.text('AUTO-FETCH LOCATION'), findsOneWidget);
  });

  test('SecureDatabaseService registers and authenticates cross-platform without plugin errors', () async {
    SharedPreferences.setMockInitialValues({});
    final service = SecureDatabaseService.instance;

    // Register user 'ok' with name 'ok' and password 'testpass'
    final registered = await service.registerUser('ok', 'testpass', name: 'ok');
    expect(registered, isTrue);

    // Duplicate registration should fail
    final duplicate = await service.registerUser('ok', 'newpass', name: 'ok2');
    expect(duplicate, isFalse);

    // Login with wrong password should fail
    final wrongLogin = await service.loginUser('ok', 'wrongpass');
    expect(wrongLogin, isFalse);

    // Login with correct credentials should succeed
    final loginSuccess = await service.loginUser('ok', 'testpass');
    expect(loginSuccess, isTrue);

    // Retrieve name should return 'ok'
    final name = await service.getUserName('ok');
    expect(name, equals('ok'));
  });
}
