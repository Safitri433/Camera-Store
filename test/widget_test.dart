
import 'package:flutter_test/flutter_test.dart';
import 'package:tugas_2/main.dart';

void main() {
  testWidgets('Camera Store smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const CameraStoreApp());
  });
}
