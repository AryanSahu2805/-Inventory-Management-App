import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/item.dart';
import '../services/firestore_service.dart';

class AddEditItemScreen extends StatefulWidget {
  final Item? item;

  AddEditItemScreen({Key? key, this.item}) : super(key: key);

  @override
  _AddEditItemScreenState createState() => _AddEditItemScreenState();
}

class _AddEditItemScreenState extends State<AddEditItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final FirestoreService _firestoreService = FirestoreService();

  late TextEditingController _nameController;
  late TextEditingController _quantityController;
  late TextEditingController _priceController;
  late TextEditingController _categoryController;

  bool _isLoading = false;
  bool get _isEditing => widget.item != null;

  // Predefined categories
  final List<String> _predefinedCategories = [
    'Electronics',
    'Clothing',
    'Food & Beverages',
    'Home & Garden',
    'Sports & Outdoors',
    'Books',
    'Toys & Games',
    'Health & Beauty',
    'Automotive',
    'Office Supplies',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.item?.name ?? '');
    _quantityController = TextEditingController(
      text: widget.item?.quantity.toString() ?? '',
    );
    _priceController = TextEditingController(
      text: widget.item?.price.toString() ?? '',
    );
    _categoryController = TextEditingController(
      text: widget.item?.category ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _priceController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  Future<void> _saveItem() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      Item item = Item(
        id: widget.item?.id,
        name: _nameController.text.trim(),
        quantity: int.parse(_quantityController.text),
        price: double.parse(_priceController.text),
        category: _categoryController.text.trim(),
        createdAt: widget.item?.createdAt ?? DateTime.now(),
      );

      if (_isEditing) {
        await _firestoreService.updateItem(item);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Item updated successfully')),
        );
      } else {
        await _firestoreService.addItem(item);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Item added successfully')),
        );
      }

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteItem() async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Item'),
        content: Text('Are you sure you want to delete "${widget.item!.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() {
        _isLoading = true;
      });

      try {
        await _firestoreService.deleteItem(widget.item!.id!);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Item deleted successfully')),
        );
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting item: $e')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showCategoryPicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          height: 400,
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Select Category',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Divider(),
              Expanded(
                child: ListView.builder(
                  itemCount: _predefinedCategories.length,
                  itemBuilder: (context, index) {
                    String category = _predefinedCategories[index];
                    return ListTile(
                      title: Text(category),
                      trailing: _categoryController.text == category
                          ? Icon(Icons.check, color: Colors.blue)
                          : null,
                      onTap: () {
                        setState(() {
                          _categoryController.text = category;
                        });
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Item' : 'Add New Item'),
        actions: _isEditing
            ? [
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: _isLoading ? null : _deleteItem,
                  tooltip: 'Delete Item',
                ),
              ]
            : null,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Item Name
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Item Name *',
                        hintText: 'Enter item name',
                        prefixIcon: Icon(Icons.inventory_2),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey[100],
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter item name';
                        }
                        return null;
                      },
                      textCapitalization: TextCapitalization.words,
                    ),
                    SizedBox(height: 16),

                    // Quantity
                    TextFormField(
                      controller: _quantityController,
                      decoration: InputDecoration(
                        labelText: 'Quantity *',
                        hintText: 'Enter quantity',
                        prefixIcon: Icon(Icons.numbers),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey[100],
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter quantity';
                        }
                        int? quantity = int.tryParse(value);
                        if (quantity == null || quantity < 0) {
                          return 'Please enter a valid quantity';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),

                    // Price
                    TextFormField(
                      controller: _priceController,
                      decoration: InputDecoration(
                        labelText: 'Price *',
                        hintText: 'Enter price',
                        prefixIcon: Icon(Icons.attach_money),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey[100],
                      ),
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^\d+\.?\d{0,2}'),
                        ),
                      ],
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter price';
                        }
                        double? price = double.tryParse(value);
                        if (price == null || price < 0) {
                          return 'Please enter a valid price';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),

                    // Category
                    TextFormField(
                      controller: _categoryController,
                      decoration: InputDecoration(
                        labelText: 'Category *',
                        hintText: 'Select or enter category',
                        prefixIcon: Icon(Icons.category),
                        suffixIcon: IconButton(
                          icon: Icon(Icons.arrow_drop_down),
                          onPressed: _showCategoryPicker,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey[100],
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please select or enter a category';
                        }
                        return null;
                      },
                      onTap: _showCategoryPicker,
                      readOnly: true,
                      textCapitalization: TextCapitalization.words,
                    ),
                    SizedBox(height: 24),

                    // Calculated Total Value (for edit mode)
                    if (_quantityController.text.isNotEmpty &&
                        _priceController.text.isNotEmpty)
                      Card(
                        color: Colors.blue[50],
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Total Value:',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '\$${((int.tryParse(_quantityController.text) ?? 0) * (double.tryParse(_priceController.text) ?? 0.0)).toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green[700],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    SizedBox(height: 24),

                    // Save Button
                    ElevatedButton(
                      onPressed: _isLoading ? null : _saveItem,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        _isEditing ? 'UPDATE ITEM' : 'ADD ITEM',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    // Delete Button (only in edit mode)
                    if (_isEditing) ...[
                      SizedBox(height: 12),
                      OutlinedButton(
                        onPressed: _isLoading ? null : _deleteItem,
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          foregroundColor: Colors.red,
                          side: BorderSide(color: Colors.red),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'DELETE ITEM',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
    );
  }
}