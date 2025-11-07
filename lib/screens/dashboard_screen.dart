import 'package:flutter/material.dart';
import '../models/item.dart';
import '../services/firestore_service.dart';

class DashboardScreen extends StatelessWidget {
  final FirestoreService _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
        centerTitle: true,
      ),
      body: StreamBuilder<List<Item>>(
        stream: _firestoreService.getItemsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.dashboard_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No data available',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          List<Item> items = snapshot.data!;
          
          // Calculate statistics
          int totalItems = items.length;
          double totalValue = items.fold(0, (sum, item) => sum + item.totalValue);
          int outOfStockCount = items.where((item) => item.isOutOfStock).length;
          int lowStockCount = items.where((item) => item.isLowStock).length;
          
          // Category breakdown
          Map<String, int> categoryCount = {};
          Map<String, double> categoryValue = {};
          for (var item in items) {
            categoryCount[item.category] = (categoryCount[item.category] ?? 0) + 1;
            categoryValue[item.category] = (categoryValue[item.category] ?? 0) + item.totalValue;
          }

          // Most valuable items
          List<Item> sortedByValue = List.from(items)
            ..sort((a, b) => b.totalValue.compareTo(a.totalValue));
          List<Item> topValueItems = sortedByValue.take(5).toList();

          return SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Summary Cards
                Text(
                  'Inventory Summary',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16),
                
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'Total Items',
                        totalItems.toString(),
                        Icons.inventory_2,
                        Colors.blue,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        'Total Value',
                        '\$${totalValue.toStringAsFixed(2)}',
                        Icons.attach_money,
                        Colors.green,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'Out of Stock',
                        outOfStockCount.toString(),
                        Icons.warning,
                        Colors.red,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        'Low Stock',
                        lowStockCount.toString(),
                        Icons.error_outline,
                        Colors.orange,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24),

                // Category Breakdown
                Text(
                  'Category Breakdown',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 12),
                
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      children: categoryCount.entries.map((entry) {
                        String category = entry.key;
                        int count = entry.value;
                        double value = categoryValue[category] ?? 0;
                        
                        return Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: Text(
                                  category,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  '$count items',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  '\$${value.toStringAsFixed(2)}',
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                    color: Colors.green[700],
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                SizedBox(height: 24),

                // Top 5 Most Valuable Items
                Text(
                  'Top 5 Most Valuable Items',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 12),
                
                ...topValueItems.asMap().entries.map((entry) {
                  int index = entry.key;
                  Item item = entry.value;
                  
                  return Card(
                    margin: EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.amber,
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      title: Text(
                        item.name,
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text('${item.quantity} × \$${item.price.toStringAsFixed(2)}'),
                      trailing: Text(
                        '\$${item.totalValue.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[700],
                        ),
                      ),
                    ),
                  );
                }).toList(),
                SizedBox(height: 24),

                // Out of Stock Items
                if (outOfStockCount > 0) ...[
                  Text(
                    'Out of Stock Items',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                  SizedBox(height: 12),
                  
                  StreamBuilder<List<Item>>(
                    stream: _firestoreService.getOutOfStockItems(),
                    builder: (context, outOfStockSnapshot) {
                      if (!outOfStockSnapshot.hasData) {
                        return SizedBox.shrink();
                      }
                      
                      return Column(
                        children: outOfStockSnapshot.data!.map((item) {
                          return Card(
                            margin: EdgeInsets.only(bottom: 8),
                            color: Colors.red[50],
                            child: ListTile(
                              leading: Icon(Icons.warning, color: Colors.red),
                              title: Text(
                                item.name,
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                              subtitle: Text('Category: ${item.category}'),
                              trailing: Text(
                                'OUT OF STOCK',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
                  SizedBox(height: 24),
                ],

                // Low Stock Items
                if (lowStockCount > 0) ...[
                  Text(
                    'Low Stock Items',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                  SizedBox(height: 12),
                  
                  StreamBuilder<List<Item>>(
                    stream: _firestoreService.getLowStockItems(),
                    builder: (context, lowStockSnapshot) {
                      if (!lowStockSnapshot.hasData) {
                        return SizedBox.shrink();
                      }
                      
                      return Column(
                        children: lowStockSnapshot.data!.map((item) {
                          return Card(
                            margin: EdgeInsets.only(bottom: 8),
                            color: Colors.orange[50],
                            child: ListTile(
                              leading: Icon(Icons.error_outline, color: Colors.orange),
                              title: Text(
                                item.name,
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                              subtitle: Text('Category: ${item.category}'),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    'Qty: ${item.quantity}',
                                    style: TextStyle(
                                      color: Colors.orange,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    'LOW STOCK',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.orange,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            SizedBox(height: 4),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}