// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:inventaris_lab/models/item_model.dart';
import 'package:inventaris_lab/widgets/item_card.dart';

void main() {
  testWidgets('shows the inventory item name', (WidgetTester tester) async {
    final item = ItemModel(
      itemId: 'item-1',
      itemName: 'Mikroskop',
      category: 'Laboratorium',
      code: 'LAB-001',
      status: 'Available',
      image: '',
      specification: '',
      createdAt: DateTime(2026),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ItemCard(item: item, onTap: () {}),
        ),
      ),
    );

    expect(find.text('Mikroskop'), findsOneWidget);
  });
}
