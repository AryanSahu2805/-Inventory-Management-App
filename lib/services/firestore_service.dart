import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/item.dart';

class FirestoreService {
  // Create collection reference for 'items'
  final CollectionReference _itemsCollection =
      FirebaseFirestore.instance.collection('items');

  // CREATE: Add a new item to Firestore
  Future<void> addItem(Item item) async {
    try {
      await _itemsCollection.add(item.toMap());
    } catch (e) {
      throw Exception('Failed to add item: $e');
    }
  }

  // READ: Get items stream for real-time updates
  Stream<List<Item>> getItemsStream() {
    return _itemsCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Item.fromMap(doc.id, doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }

  // UPDATE: Update an existing item
  Future<void> updateItem(Item item) async {
    try {
      if (item.id == null) {
        throw Exception('Item ID is required for update');
      }
      await _itemsCollection.doc(item.id).update(item.toMap());
    } catch (e) {
      throw Exception('Failed to update item: $e');
    }
  }

  // DELETE: Delete an item by ID
  Future<void> deleteItem(String itemId) async {
    try {
      await _itemsCollection.doc(itemId).delete();
    } catch (e) {
      throw Exception('Failed to delete item: $e');
    }
  }

  // BULK DELETE: Delete multiple items
  Future<void> deleteMultipleItems(List<String> itemIds) async {
    try {
      WriteBatch batch = FirebaseFirestore.instance.batch();
      for (String id in itemIds) {
        batch.delete(_itemsCollection.doc(id));
      }
      await batch.commit();
    } catch (e) {
      throw Exception('Failed to delete multiple items: $e');
    }
  }

  // SEARCH: Search items by name
  Stream<List<Item>> searchItems(String query) {
    if (query.isEmpty) {
      return getItemsStream();
    }
    
    return _itemsCollection
        .orderBy('name')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Item.fromMap(doc.id, doc.data() as Map<String, dynamic>))
          .where((item) => 
              item.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  // FILTER: Filter items by category
  Stream<List<Item>> filterByCategory(String category) {
    if (category.isEmpty || category == 'All') {
      return getItemsStream();
    }
    
    return _itemsCollection
        .where('category', isEqualTo: category)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Item.fromMap(doc.id, doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }

  // FILTER: Get low stock items
  Stream<List<Item>> getLowStockItems() {
    return _itemsCollection
        .where('quantity', isGreaterThan: 0)
        .where('quantity', isLessThan: 10)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Item.fromMap(doc.id, doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }

  // FILTER: Get out of stock items
  Stream<List<Item>> getOutOfStockItems() {
    return _itemsCollection
        .where('quantity', isEqualTo: 0)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Item.fromMap(doc.id, doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }

  // Get all categories (for dropdown)
  Future<List<String>> getCategories() async {
    try {
      QuerySnapshot snapshot = await _itemsCollection.get();
      Set<String> categories = {};
      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        if (data['category'] != null) {
          categories.add(data['category']);
        }
      }
      return categories.toList()..sort();
    } catch (e) {
      return [];
    }
  }
}