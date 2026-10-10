import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shoping_list/config/api_key.dart';
import 'package:shoping_list/data/categories.dart';
import 'package:shoping_list/models/category.dart';
import 'package:shoping_list/models/grocery_item.dart';

class NewItemForm extends StatefulWidget {
  const NewItemForm({super.key});

  @override
  State<NewItemForm> createState() => _NewItemFormState();
}

class _NewItemFormState extends State<NewItemForm> {
  final _formKey = GlobalKey<FormState>();

  String _enteredName = '';
  int _enteredQuantity = 1;
  Category _selectedCategory = categories[Categories.vegetables]!;
  bool _isSending = false;

  void _saveItem() async {
    final formState = _formKey.currentState!;
    if (!formState.validate()) {
      return;
    }

    formState.save();
    setState(() {
      _isSending = true;
    });

    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    final url = Uri.https(
      apiKey,
      'shopping-list.json',
    );

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'name': _enteredName,
          'quantity': _enteredQuantity,
          'category': _selectedCategory.title,
        }),
      );

      if (!mounted) return;

      if (response.statusCode >= 400) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Failed to add item. Please try again.'),
          ),
        );
        setState(() {
          _isSending = false;
        });
        return;
      }

      final Map<String, dynamic> resItem = json.decode(response.body);

      if (!mounted) return;

      navigator.pop(
        GroceryItem(
          id: resItem['name'],
          name: _enteredName,
          quantity: _enteredQuantity,
          category: _selectedCategory,
        ),
      );
    } catch (error) {
      if (!mounted) return;
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Something went wrong. Please check your connection.'),
        ),
      );
      setState(() {
        _isSending = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add a new item")),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                maxLength: 50,
                decoration: const InputDecoration(label: Text("Name")),
                validator: (value) {
                  if (value == null ||
                      value.trim().length <= 1 ||
                      value.trim().length > 50) {
                    return 'Input must be between 2 and 50 characters.';
                  }
                  return null;
                },
                onSaved: (value) {
                  _enteredName = value!;
                },
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextFormField(
                      decoration: const InputDecoration(
                        label: Text('Quantity'),
                      ),
                      keyboardType: TextInputType.number,
                      initialValue: _enteredQuantity.toString(),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a quantity.';
                        }
                        final parsedQuantity = int.tryParse(value);
                        if (parsedQuantity == null || parsedQuantity <= 0) {
                          return 'Input must be a valid positive number.';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _enteredQuantity = int.parse(value!);
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DropdownButtonFormField<Category>(
                      initialValue: _selectedCategory,
                      items: [
                        for (final category in categories.entries)
                          DropdownMenuItem(
                            value: category.value,
                            child: Row(
                              children: [
                                Container(
                                  width: 14,
                                  height: 14,
                                  decoration: BoxDecoration(
                                    color: category.value.color,
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(category.value.title),
                              ],
                            ),
                          ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          _selectedCategory = value;
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed:
                        _isSending
                            ? null
                            : () => _formKey.currentState!.reset(),
                    child: const Text('Reset'),
                  ),
                  const SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: _isSending ? null : _saveItem,
                    child:
                        _isSending
                            ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                            : const Text('Add Item'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
