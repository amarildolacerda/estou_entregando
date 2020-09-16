// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

//import 'package:estou_entregando/app/app_main.dart';
import 'package:estou_entregando/app/config/config.dart';
//import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

//import 'package:estou_entregando/main.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    //await tester.pumpWidget(AppMain());

    // Verify that our counter starts at 0.
    //expect(find.text('0'), findsOneWidget);
    //expect(find.text('1'), findsNothing);

    // Tap the '+' icon and trigger a frame.
    //await tester.tap(find.byIcon(Icons.add));
    //await tester.pump();

    // Verify that our counter has incremented.
    //expect(find.text('0'), findsNothing);
    //expect(find.text('1'), findsOneWidget);
    var r = ConfigApp();
    expect(inDev, false, reason: 'esta marcado como inDev');
    r.conta = '14812';
    await r.init();
    expect(r.conta, '14812');
    r.setup();
    expect(ConfigApp().conta, '14812');
    expect(r.usuario, 'checkout');
    expect(r.password, '14812');
    print('firebaseLogin --------------');
    await r.firebaseLogin('14812', 'checkout', '14812');
    print('validando o token...');
    expect(
      (r.cloudV3.token ?? '').length > 0,
      true,
      reason: 'Não obteve o token do cloud',
    );
  });
}
