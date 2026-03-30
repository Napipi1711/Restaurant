import 'package:flutter/material.dart';
import 'table_dialogs.dart';

class TableDetailDialog extends StatefulWidget {
  final Map table;
  final Function(String, String) onUpdateStatus;
  final Function(String) onDelete;
  const TableDetailDialog({
    super.key,
    required this.table,
    required this.onUpdateStatus,
    required this.onDelete,
  });

  @override
  State<TableDetailDialog> createState() => _TableDetailDialogState();
}

class _TableDetailDialogState extends State<TableDetailDialog> {
  late String selectedStatus;

  @override
  void initState() {
    super.initState();
    selectedStatus = widget.table['status'] == 'available' || widget.table['status'] == 'unavailable'
        ? widget.table['status']
        : 'available';
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Table ${widget.table['tableNumber']} Details"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Seats: ${widget.table['seats']}"),
          if (widget.table['note'] != null && widget.table['note'].toString().isNotEmpty)
            Text("Note: ${widget.table['note']}"),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            value: selectedStatus,
            items: ['available', 'unavailable']
                .map((status) => DropdownMenuItem(
              value: status,
              child: Text(status),
            ))
                .toList(),
            onChanged: (val) {
              if (val != null) setState(() => selectedStatus = val);
            },
            decoration: const InputDecoration(labelText: "Status"),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
        ElevatedButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (_) => ConfirmChangeStatusDialog(
                onConfirm: () => widget.onUpdateStatus(widget.table['_id'], selectedStatus),
              ),
            );
          },
          child: const Text("Save"),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          onPressed: () {
            showDialog(
              context: context,
              builder: (_) => ConfirmDeleteDialog(
                onConfirm: () => widget.onDelete(widget.table['_id']),
              ),
            );
          },
          child: const Text("Delete"),
        ),
      ],
    );
  }
}
