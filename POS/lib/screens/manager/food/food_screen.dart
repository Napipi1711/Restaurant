import 'package:flutter/material.dart';
import 'food_service.dart';
import 'food_dialog.dart';

class FoodScreen extends StatefulWidget {
  const FoodScreen({super.key});

  @override
  State<FoodScreen> createState() => _FoodScreenState();
}

class _FoodScreenState extends State<FoodScreen> {
  final FoodService service = FoodService();
  List foods = [];
  List filteredFoods = [];
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadFoods();
  }

  Future<void> loadFoods() async {
    final data = await service.fetchFoods();
    setState(() {
      foods = data;
      filteredFoods = data;
    });
  }

  void searchFood(String query) {
    final filtered = foods.where((f) => f['name'].toLowerCase().contains(query.toLowerCase())).toList();
    setState(() {
      filteredFoods = filtered;
    });
  }

  Future<void> deleteFood(String id) async {
    final success = await service.deleteFood(id);
    if (success) loadFoods();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: searchController,
            decoration: const InputDecoration(
              labelText: "Search Food",
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onChanged: searchFood,
          ),
        ),
        ElevatedButton.icon(
          onPressed: () => FoodDialog.showAddFoodDialog(context, loadFoods),
          icon: const Icon(Icons.add),
          label: const Text("Add Food"),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: filteredFoods.length,
            itemBuilder: (context, index) {
              final food = filteredFoods[index];
              return ListTile(
                leading: food['image'] != null
                    ? Image.network("http://10.0.2.2:5000/uploads/${food['image']}", width: 50, height: 50, fit: BoxFit.cover)
                    : const Icon(Icons.fastfood),
                title: Text(food['name']),
                subtitle: Text("${food['category']} - \$${food['price']}"),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => deleteFood(food['_id']),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
