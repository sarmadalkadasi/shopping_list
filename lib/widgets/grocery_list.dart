import 'package:flutter/material.dart';
import 'package:shoping_list/models/grocery_item.dart';
import 'package:shoping_list/widgets/grocery_item.dart' as grocery;

class GroceryList extends StatelessWidget {
  const GroceryList(this._groceryItems, this.removeItem, {super.key});
  final List<GroceryItem> _groceryItems;
  final Function(GroceryItem) removeItem;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: _groceryItems.length,
      itemBuilder: (ctx, index) {
        final groceryItemId = _groceryItems[index].id;
        final groceryItemName = _groceryItems[index].name;
        final groceryItemQuantity = _groceryItems[index].quantity.toString();
        final groceryItemColor = _groceryItems[index].category.color;

        return grocery.GroceryItem(id: groceryItemId, name: groceryItemName, quantity: groceryItemQuantity, color: groceryItemColor, () => removeItem(_groceryItems[index]));
      },
    );
  }
}
