import 'package:flutter/material.dart';

class GroceryItem extends StatelessWidget {
  const GroceryItem(this.removeItem, {
    super.key,
    required this.id,
    required this.name,
    required this.quantity,
    required this.color,
  });

  final String id;
  final String name;
  final String quantity;
  final Color color;
  final VoidCallback removeItem;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(id),
      onDismissed: (direction) => removeItem(),
      child: ListTile(
        title: Text(name),
        leading: CircleAvatar(backgroundColor: color, radius: 15),
        trailing: Text(quantity),
      ),
    );
  }
}
