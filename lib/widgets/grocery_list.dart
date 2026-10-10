import 'package:flutter/material.dart';
import 'package:shoping_list/models/grocery_item.dart';
import 'package:shoping_list/widgets/grocery_item.dart';

class GroceryList extends StatelessWidget {
  const GroceryList(this._groceryItems, this.removeItem, {super.key});

  final List<GroceryItem> _groceryItems;
  final void Function(GroceryItem) removeItem;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: _groceryItems.length,
      itemBuilder: (ctx, index) {
        final item = _groceryItems[index];
        return GroceryTile(
          item: item,
          onRemove: () => removeItem(item),
        );
      },
    );
  }
}
