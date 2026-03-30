import 'package:flutter/material.dart';

class TableCreateDialog extends StatefulWidget {
  final Function(Map<String, dynamic>) onAdd;
  const TableCreateDialog({super.key, required this.onAdd});

  @override
  State<TableCreateDialog> createState() => _TableCreateDialogState();
}

class _TableCreateDialogState extends State<TableCreateDialog> {
  final tableNumberController = TextEditingController();
  final seatsController = TextEditingController();
  final noteController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Add Table"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: tableNumberController,
            decoration: const InputDecoration(labelText: "Table Number"),
            keyboardType: TextInputType.number,
          ),
          TextField(
            controller: seatsController,
            decoration: const InputDecoration(labelText: "Seats"),
            keyboardType: TextInputType.number,
          ),
          TextField(
            controller: noteController,
            decoration: const InputDecoration(labelText: "Note"),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: () {
            final tableNumber = tableNumberController.text.trim();
            final seats = seatsController.text.trim();
            final note = noteController.text.trim();
            if (tableNumber.isEmpty) return;

            widget.onAdd({
              "tableNumber": int.parse(tableNumber),
              "seats": seats.isEmpty ? 2 : int.parse(seats),
              "note": note,
              "status": "available",
            });

            Navigator.pop(context);
          },
          child: const Text("Add"),
        ),
      ],
    );
  }
}
