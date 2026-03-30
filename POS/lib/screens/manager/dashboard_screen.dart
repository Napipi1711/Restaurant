import 'package:flutter/material.dart';
import 'discount_screen.dart';
import 'orders_screen.dart';
import 'reservation_screen.dart';
import 'sumary_screen.dart';
import '../../services/dashboard_service.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 40, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// MENU GRID
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.1,
                children: [
                  _buildMenuCard(
                    context,
                    'Discount',
                    Icons.local_offer_rounded,
                    [Colors.orangeAccent, Colors.deepOrange],
                    const DiscountScreen(),
                  ),
                  _buildMenuCard(
                    context,
                    'Bookings',
                    Icons.event_seat_rounded,
                    [Colors.teal.shade400, Colors.teal.shade700],
                    const ReservationScreen(),
                  ),
                  _buildMenuCard(
                    context,
                    'Summary',
                    Icons.insert_chart_rounded,
                    [Colors.purpleAccent, Colors.purple],
                    const SummaryScreen(),
                  ),
                  _buildMenuCard(
                    context,
                    'Orders',
                    Icons.receipt_long_rounded,
                    [Colors.redAccent, Colors.red.shade700],
                    const OrdersScreen(),
                  ),
                ],
              ),

              const SizedBox(height: 35),
              const Text(
                "Revenue",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),

              _buildRevenueSection(),
            ],
          ),
        ),
      ),
    );
  }

  /// MENU CARD
  Widget _buildMenuCard(
      BuildContext context,
      String title,
      IconData icon,
      List<Color> colors,
      Widget screen,
      ) {
    return InkWell(
      onTap: () =>
          Navigator.push(context, MaterialPageRoute(builder: (_) => screen)),
      borderRadius: BorderRadius.circular(24),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: colors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: colors.last.withOpacity(0.35),
              blurRadius: 12,
              offset: const Offset(0, 6),
            )
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 42),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// REVENUE SECTION
  Widget _buildRevenueSection() {
    return FutureBuilder<Map<String, double>?>(
      future: DashboardService.getRevenueSummary(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final revenue = snapshot.data ??
            {'today': 0.0, 'week': 0.0, 'month': 0.0};

        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            children: [
              _buildRevenueRow(
                "Today",
                "\$${revenue['today']!.toStringAsFixed(2)}",
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 14),
                child: Divider(height: 1),
              ),
              _buildRevenueRow(
                "This Week",
                "\$${revenue['week']!.toStringAsFixed(2)}",
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 14),
                child: Divider(height: 1),
              ),
              _buildRevenueRow(
                "This Month",
                "\$${revenue['month']!.toStringAsFixed(2)}",
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRevenueRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}
