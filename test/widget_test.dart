import 'package:flutter_test/flutter_test.dart';
import 'package:shoping_list/main.dart';

void main() {
  testWidgets('App loads and displays title', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ShoppingList());

    // Verify that the AppBar title is displayed.
    expect(find.text('Your Groceries'), findsOneWidget);
  });
}
