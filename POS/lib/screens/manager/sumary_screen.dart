import 'package:flutter/material.dart';
import '../../services/summary_service.dart';

class SummaryScreen extends StatefulWidget {
  const SummaryScreen({super.key});

  @override
  State<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends State<SummaryScreen> {
  bool loading = true;
  List<dynamic> summaries = [];

  @override
  void initState() {
    super.initState();
    fetchSummaries();
  }

  Future<void> fetchSummaries() async {
    setState(() => loading = true);
    final data = await SummaryService.getSubmittedSummaries();
    if (data != null) {
      setState(() => summaries = data);
    }
    setState(() => loading = false);
  }

  Future<void> approveSummary(String id) async {
    final success = await SummaryService.approveSummary(id);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Summary approved successfully")),
      );
      fetchSummaries();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to approve summary")),
      );
    }
  }

  String formatDate(String isoDate) {
    final dt = DateTime.parse(isoDate).toLocal();
    return "${dt.day}/${dt.month}/${dt.year}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Waiter Summaries"),
        centerTitle: true,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : summaries.isEmpty
          ? const Center(child: Text("No summaries found"))
          : ListView.builder(
        itemCount: summaries.length,
        itemBuilder: (context, index) {
          final summary = summaries[index];

          final waiter =
              summary['waiter']?['username'] ?? 'Unknown';
          final createdAt = summary['createdAt'];
          final totalAmount = summary['totalAmount'] ?? 0;
          final status = summary['status'] ?? 'active';

          return Card(
            margin: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 8),
            elevation: 3,
            child: ListTile(
              title: Text(
                "Waiter: $waiter",
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text("Date: ${formatDate(createdAt)}"),
                  Text(
                    "Total Amount: \$${totalAmount.toStringAsFixed(2)}",
                  ),
                  Text(
                    "Status: ${status.toUpperCase()}",
                    style: TextStyle(
                      color: status == "approved"
                          ? Colors.green
                          : Colors.blue,
                    ),
                  ),
                ],
              ),
              trailing: status == "active"
                  ? ElevatedButton(
                onPressed: () async {
                  final confirm =
                  await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text("Confirm"),
                      content: const Text(
                          "Are you sure you want to approve this summary?"),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(
                              context, false),
                          child: const Text("Cancel"),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(
                              context, true),
                          child: const Text("Approve"),
                        ),
                      ],
                    ),
                  );

                  if (confirm == true) {
                    approveSummary(summary['_id']);
                  }
                },
                child: const Text("Approve"),
              )
                  : const Icon(
                Icons.check_circle,
                color: Colors.green,
              ),
            ),
          );
        },
      ),
    );
  }
}
