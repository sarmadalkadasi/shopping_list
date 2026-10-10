import 'package:flutter/material.dart';
import 'package:shoping_list/models/grocery_item.dart';

class GroceryTile extends StatelessWidget {
  const GroceryTile({
    super.key,
    required this.item,
    required this.onRemove,
  });

  final GroceryItem item;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(item.id),
      onDismissed: (_) => onRemove(),
      child: ListTile(
        title: Text(item.name),
        leading: CircleAvatar(
          backgroundColor: item.category.color,
          radius: 15,
        ),
        trailing: Text(item.quantity.toString()),
      ),
    );
  }
}
