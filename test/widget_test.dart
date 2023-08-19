import 'package:flutter/material.dart';
import 'package:flutter_shopping_list/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('UI elements are displayed correctly', (WidgetTester tester) async {
    await tester.pumpWidget(ShoppingListApp());

    // Проверка наличия AppBar
    expect(find.byType(AppBar), findsOneWidget);

    // Проверка наличия поля для ввода
    expect(find.byType(TextField), findsOneWidget);

    // Проверка наличия иконки архива
    expect(find.byIcon(Icons.archive), findsOneWidget);
  });

  testWidgets('Adding and archiving items', (WidgetTester tester) async {
    await tester.pumpWidget(ShoppingListApp());

    // Добавление элемента
    await tester.enterText(find.byType(TextField), 'Молоко');
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Проверка, что элемент добавлен
    expect(find.text('Молоко'), findsOneWidget);

    // Архивирование элемента
    await tester.tap(find.byIcon(Icons.archive).first);
    await tester.pump();

    // Проверка, что элемент был архивирован
    expect(find.text('Молоко'), findsNothing);

    // Переключение на архив
    await tester.tap(find.byIcon(Icons.archive));
    await tester.pump();

    // Проверка наличия элемента в архиве
    expect(find.text('Молоко'), findsOneWidget);
  });

}
