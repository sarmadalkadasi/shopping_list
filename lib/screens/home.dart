import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shoping_list/config/api_key.dart';
import 'package:shoping_list/data/categories.dart';
import 'package:shoping_list/models/grocery_item.dart';
import 'package:shoping_list/widgets/grocery_list.dart';
import 'package:shoping_list/widgets/new_item_form.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<GroceryItem> _groceryItems = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  void _loadItems() async {
    final url = Uri.https(
      apiKey,
      'shopping-list.json',
    );

    try {
      final response = await http.get(url);

      if (!mounted) return;

      if (response.statusCode >= 400) {
        setState(() {
          _error = "Failed to fetch data. Please try again later.";
          _isLoading = false;
        });
        return;
      }

      if (response.body == 'null') {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final Map<String, dynamic> dataList = json.decode(response.body);
      final List<GroceryItem> loadedItems = [];

      for (final item in dataList.entries) {
        final category = categories.entries
            .firstWhere(
              (catItem) => catItem.value.title == item.value['category'],
              orElse: () => categories.entries.first,
            )
            .value;

        loadedItems.add(
          GroceryItem(
            id: item.key,
            name: item.value['name'],
            quantity: item.value['quantity'],
            category: category,
          ),
        );
      }

      setState(() {
        _groceryItems = loadedItems;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _error = 'Something went wrong! Please try again later.';
        _isLoading = false;
      });
    }
  }

  void _addItem() async {
    final newItem = await Navigator.of(context).push<GroceryItem>(
      MaterialPageRoute(builder: (ctx) => const NewItemForm()),
    );

    if (newItem == null || !mounted) {
      return;
    }

    setState(() {
      _groceryItems.add(newItem);
    });
  }

  void _removeItem(GroceryItem item) async {
    final int index = _groceryItems.indexOf(item);
    setState(() {
      _groceryItems.remove(item);
    });

    final url = Uri.https(
      apiKey,
      'shopping-list/${item.id}.json',
    );

    try {
      final response = await http.delete(url);

      if (response.statusCode >= 400) {
        if (!mounted) return;

        await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(
              'Error ${response.statusCode}',
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
            content: const Text("Something went wrong, please try again later."),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: Text(
                  "OK",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              ),
            ],
          ),
        );

        if (!mounted) return;
        setState(() {
          _groceryItems.insert(index, item);
        });
      }
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not delete item. Restoring...')),
      );
      setState(() {
        _groceryItems.insert(index, item);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget currentScreen = _groceryItems.isNotEmpty
        ? GroceryList(_groceryItems, _removeItem)
        : Center(
            child: Text(
              "No Items Added Yet!",
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withAlpha(140),
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          );

    if (_error != null && _error!.trim().isNotEmpty) {
      currentScreen = Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.all(18),
        child: Text(
          _error!,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge!.copyWith(
            color: Theme.of(context).colorScheme.error.withAlpha(150),
          ),
        ),
      );
    }

    if (_isLoading) {
      currentScreen = const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Groceries"),
        actions: [
          IconButton(
            onPressed: _addItem,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: currentScreen,
    );
  }
}
