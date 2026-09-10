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

  testWidgets('opens guidance and donation modality flows', (tester) async {
    await tester.pumpWidget(const LatteConectApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('LatteConect').first);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Orientacao e apoio').first);
    await tester.tap(find.text('Orientacao e apoio').first);
    await tester.pumpAndSettle();
    expect(
      find.text('Informacao para quem quer cuidar, mesmo sem doar'),
      findsOneWidget,
    );

    await tester.tap(find.text('LatteConect').first);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Quero doar leite').first);
    await tester.tap(find.text('Quero doar leite').first);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Ja tenho cadastro e quero agendar'));
    await tester.tap(find.text('Ja tenho cadastro e quero agendar'));
    await tester.pumpAndSettle();
    expect(find.text('Escolha como prefere contribuir'), findsOneWidget);
    expect(find.text('Entrega no hospital'), findsOneWidget);
  });
}
