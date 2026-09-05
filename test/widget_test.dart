import 'package:flutter_test/flutter_test.dart';
import 'package:latte_conect/src/app.dart';

void main() {
  testWidgets('renders LatteConect home and primary routes', (tester) async {
    await tester.pumpWidget(const LatteConectApp());
    await tester.pumpAndSettle();

    expect(find.text('LatteConect'), findsWidgets);
    expect(find.text('Quero doar leite'), findsWidgets);

    await tester.ensureVisible(find.text('Quero doar leite').first);
    await tester.tap(find.text('Quero doar leite').first);
    await tester.pumpAndSettle();

    expect(find.text('Cadastro de nutriz doadora'), findsWidgets);
  });
}
