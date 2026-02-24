import 'package:flutter_test/flutter_test.dart';
import 'package:example/main.dart';

void main() {
  testWidgets('PlaygroundApp renders', (WidgetTester tester) async {
    await tester.pumpWidget(const PlaygroundApp());
    expect(find.text('OverlayMenu Playground'), findsOneWidget);
  });
}
