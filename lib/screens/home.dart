import 'package:flutter/material.dart';
import 'package:shoping_list/models/grocery_item.dart';
import 'package:shoping_list/widgets/grocery_list.dart';
import 'package:shoping_list/widgets/new_item_form.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<GroceryItem> groceryItems = [];

  void _addItem() async {
    final newItem = await Navigator.of(context).push<GroceryItem>(
      MaterialPageRoute(builder: (ctx) => const NewItemForm()),
    );
    if (newItem == null) {
      return;
    }
    setState(() {
      groceryItems.add(newItem);
    });
  }

  void _removeItem(GroceryItem item){
    setState(() {
      groceryItems.remove(item);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Groceries"),
        actions: [IconButton(onPressed: _addItem, icon: Icon(Icons.add))],
      ),
      body: groceryItems.isNotEmpty
          ? GroceryList(groceryItems, _removeItem)
          : Center(
              child: Text(
                "No Items Added Yet!",
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withAlpha(150),
                  fontSize: 20,
                  fontWeight: FontWeight.bold
                ),
              ),
            ),
    );
  }
}
