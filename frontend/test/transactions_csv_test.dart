import 'package:flutter_test/flutter_test.dart';
import 'package:satutani_mobile/core/utils/transactions_csv.dart';
import 'package:satutani_mobile/data/mock/orders_mock.dart' show OrderStatus, OrderStatusExt;
import 'package:satutani_mobile/data/models/farmer_order.dart';

FarmerOrder _order({String name = 'Budi', String product = 'Tomat', double qty = 2.5, String phone = ''}) => FarmerOrder(
      id: 'abc123',
      productName: product,
      productImageUrl: '',
      quantity: qty,
      unit: 'kg',
      pricePerUnit: 15000,
      shippingCost: 5000,
      status: OrderStatus.selesai,
      consumerName: name,
      consumerPhone: phone,
      createdAt: DateTime(2026, 7, 15, 14, 3),
    );

void main() {
  test('header, BOM, dan baris angka mentah', () {
    final csv = buildTransactionsCsv([_order()]);
    final lines = csv.substring(1).trim().split('\r\n');
    expect(csv.startsWith('﻿'), isTrue);
    expect(lines.first.split(';').first, 'Tanggal');
    expect(lines[1], '2026-07-15 14:03;abc123;Tomat;2,5;kg;15000;5000;42500;Budi;;${OrderStatus.selesai.label}');
  });

  test('field dengan ; atau kutip di-escape', () {
    final csv = buildTransactionsCsv([_order(name: 'Budi; "Pak" Tani')]);
    expect(csv, contains('"Budi; ""Pak"" Tani"'));
  });

  test('formula injection dinetralkan, telepon +62 tetap utuh', () {
    final csv = buildTransactionsCsv([_order(name: '=HYPERLINK("x")', phone: '+6281234')]);
    expect(csv, contains(';"\'=HYPERLINK(""x"")";'));
    expect(csv, contains(';+6281234;'));
  });
}
