import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:smartfarm_app/state/farm_provider.dart';
import 'package:smartfarm_app/ui/screens/data_meets_growth_cockpit_screen.dart';

void main() {
  testWidgets('DataMeetsGrowthCockpitScreen desktop render test',
      (WidgetTester tester) async {
    // Set a desktop resolution (1280x800)
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => FarmProvider(),
        child: const MaterialApp(
          home: DataMeetsGrowthCockpitScreen(),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Data Meets Growth'), findsWidgets);
    expect(find.text('Soil Intelligence'), findsOneWidget);
    expect(find.text('ClimateIQ'), findsOneWidget);
    expect(find.text('Golden Harvest'), findsOneWidget);
    expect(find.text('Research AI Stream'), findsOneWidget);
    expect(find.text('AI Detect'), findsOneWidget);
  });

  testWidgets('DataMeetsGrowthCockpitScreen mobile render test',
      (WidgetTester tester) async {
    // Set a mobile phone resolution (390x844)
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => FarmProvider(),
        child: const MaterialApp(
          home: DataMeetsGrowthCockpitScreen(),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Data Meets Growth'), findsWidgets);
    expect(find.text('Soil Intelligence'), findsOneWidget);
    expect(find.text('ClimateIQ'), findsOneWidget);
  });
}
