import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/item_model.dart';

class FirestoreService {
  final FirebaseFirestore _db =
      FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _items =>
      _db.collection('items');

  CollectionReference<Map<String, dynamic>> get _banners =>
      _db.collection('banners');

  // STREAM INVENTARIS
  Stream<List<ItemModel>> getItems() {
    return _items.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return ItemModel.fromMap(
          doc.data(),
          documentId: doc.id,
        );
      }).toList();
    });
  }

  // TAMBAH INVENTARIS
  Future<void> addItem(ItemModel item) async {
    final doc = _items.doc();

    final data = item.toMap();

    data['item_id'] = doc.id;
    data['created_at'] =
        Timestamp.fromDate(DateTime.now());

    await doc.set(data);
  }

  // EDIT INVENTARIS
  Future<void> updateItem(ItemModel item) async {
    await _items.doc(item.itemId).update(item.toMap());
  }

  // HAPUS INVENTARIS
  Future<void> deleteItem(String itemId) async {
    await _items.doc(itemId).delete();
  }

  // SEARCH
  Stream<List<ItemModel>> searchItems(String keyword) {
    final search = keyword.trim().toLowerCase();

    return getItems().map((items) {
      if (search.isEmpty) return items;

      return items.where((item) {
        return item.itemName.toLowerCase().contains(search) ||
            item.code.toLowerCase().contains(search) ||
            item.category.toLowerCase().contains(search);
      }).toList();
    });
  }

  // FILTER KATEGORI
  Stream<List<ItemModel>> getItemsByCategory(String category) {
    return getItems().map((items) {
      if (category.toLowerCase() == 'semua') {
        return items;
      }

      return items.where((item) {
        return item.category.toLowerCase() ==
            category.toLowerCase();
      }).toList();
    });
  }

  // FILTER STATUS
  Stream<List<ItemModel>> getItemsByStatus(String status) {
    return getItems().map((items) {
      if (status.toLowerCase() == 'semua') {
        return items;
      }

      return items.where((item) {
        return item.status.toLowerCase() ==
            status.toLowerCase();
      }).toList();
    });
  }

  // DATA DUMMY INVENTARIS
  Future<void> seedDummyItemsIfEmpty() async {
    final snapshot = await _items.limit(1).get();

    if (snapshot.docs.isEmpty) {
      final batch = _db.batch();

      final dummyItems = [
        {
          'item_name': 'Mikroskop Binokuler',
          'category': 'Alat Optik',
          'code': 'LAB001',
          'status': 'Available',
          'image':
              'https://images.unsplash.com/photo-1532094349884-543bc11b234d?w=900',
          'spesification':
              'Mikroskop binokuler untuk pengamatan preparat.',
        },
        {
          'item_name': 'Tabung Reaksi',
          'category': 'Alat Gelas',
          'code': 'LAB002',
          'status': 'Available',
          'image':
              'https://images.unsplash.com/photo-1579154204601-01588f351e67?w=900',
          'spesification':
              'Tabung kaca laboratorium untuk menampung sampel.',
        },
        {
          'item_name': 'Gelas Ukur',
          'category': 'Alat Gelas',
          'code': 'LAB003',
          'status': 'Available',
          'image':
              'https://images.unsplash.com/photo-1518152006812-edab29b069ac?w=900',
          'spesification':
              'Gelas ukur untuk mengukur volume cairan.',
        },
        {
          'item_name': 'Erlenmeyer',
          'category': 'Alat Gelas',
          'code': 'LAB004',
          'status': 'Borrowed',
          'image':
              'https://images.unsplash.com/photo-1532187863486-abf9dbad1b69?w=900',
          'spesification':
              'Labu Erlenmeyer untuk mencampur larutan.',
        },
        {
          'item_name': 'Pipet Laboratorium',
          'category': 'Alat Ukur',
          'code': 'LAB005',
          'status': 'Available',
          'image':
              'https://images.unsplash.com/photo-1582719471384-894fbb16e074?w=900',
          'spesification':
              'Pipet untuk mengambil dan memindahkan cairan.',
        },
        {
          'item_name': 'Neraca Digital',
          'category': 'Alat Ukur',
          'code': 'LAB006',
          'status': 'Available',
          'image':
              'https://images.unsplash.com/photo-1581093458791-9d42e3c5e6b4?w=900',
          'spesification':
              'Alat untuk mengukur massa sampel secara digital.',
        },
      ];

      for (final item in dummyItems) {
        final doc = _items.doc();

        batch.set(doc, {
          'item_id': doc.id,
          ...item,
          'created_at':
              Timestamp.fromDate(DateTime.now()),
        });
      }

      await batch.commit();
    }

    await seedDummyBannersIfEmpty();
  }

  // DATA BANNER
  Future<void> seedDummyBannersIfEmpty() async {
    final snapshot = await _banners.limit(1).get();

    if (snapshot.docs.isNotEmpty) return;

    final batch = _db.batch();

    final banners = [
      {
        'title': 'Laboratorium Modern',
        'subtitle': 'Kelola peralatan laboratorium dengan mudah.',
        'image':
            'https://images.unsplash.com/photo-1532094349884-543bc11b234d?w=1200',
        'order': 1,
      },
      {
        'title': 'Inventaris Terorganisir',
        'subtitle': 'Pantau seluruh alat laboratorium.',
        'image':
            'https://images.unsplash.com/photo-1579154204601-01588f351e67?w=1200',
        'order': 2,
      },
      {
        'title': 'Peminjaman Lebih Mudah',
        'subtitle': 'Ajukan peminjaman melalui aplikasi.',
        'image':
            'https://images.unsplash.com/photo-1518152006812-edab29b069ac?w=1200',
        'order': 3,
      },
    ];

    for (final banner in banners) {
      final doc = _banners.doc();

      batch.set(doc, {
        'banner_id': doc.id,
        ...banner,
      });
    }

    await batch.commit();
  }

  // STREAM BANNER
  Stream<List<Map<String, dynamic>>> getBanners() {
    return _banners.snapshots().map((snapshot) {
      final banners = snapshot.docs.map((doc) {
        return {
          ...doc.data(),
          'banner_id': doc.id,
        };
      }).toList();

      banners.sort((a, b) {
        final orderA = (a['order'] as num?)?.toInt() ?? 0;
        final orderB = (b['order'] as num?)?.toInt() ?? 0;

        return orderA.compareTo(orderB);
      });

      return banners;
    });
  }

  // PENGAJUAN PEMINJAMAN
  Future<void> borrowItem({
    required String uid,
    required ItemModel item,
  }) async {
    final itemRef = _items.doc(item.itemId);

    final borrowRef = _db
        .collection('users')
        .doc(uid)
        .collection('borrowings')
        .doc();

    await _db.runTransaction((transaction) async {
      final itemSnapshot =
          await transaction.get(itemRef);

      if (!itemSnapshot.exists) {
        throw Exception('Barang tidak ditemukan.');
      }

      final data = itemSnapshot.data()!;

      final status =
          (data['status'] ?? 'Available').toString();

      if (status.toLowerCase() != 'available') {
        throw Exception('Barang sedang dipinjam.');
      }

      final itemName =
          (data['item_name'] ?? item.itemName).toString();

      transaction.update(itemRef, {
        'status': 'Borrowed',
      });

      transaction.set(borrowRef, {
        'borrow_id': borrowRef.id,
        'item_id': item.itemId,
        'item_name': itemName,
        'borrow_date': FieldValue.serverTimestamp(),
      });
    });
  }

  // RIWAYAT PEMINJAMAN

  Stream<List<Map<String, dynamic>>> getBorrowings(String uid) {
    return _db
        .collection('users')
        .doc(uid)
        .collection('borrowings')
        .orderBy('borrow_date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return {
          ...doc.data(),
          'borrow_id': doc.id,
        };
      }).toList();
    });
  }
}