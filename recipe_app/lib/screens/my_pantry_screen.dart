import 'package:flutter/material.dart';
import '../models/ingredient.dart';

/// 내 냉장고 화면
class MyPantryScreen extends StatefulWidget {
  const MyPantryScreen({super.key});

  @override
  State<MyPantryScreen> createState() => _MyPantryScreenState();
}

class _MyPantryScreenState extends State<MyPantryScreen> {
  // 임시 데이터 (실제로는 Provider나 서비스를 통해 가져옴)
  List<Ingredient> _ingredients = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('내 냉장고'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // 재료 추가 기능
              _showAddIngredientDialog();
            },
          ),
        ],
      ),
      body: _ingredients.isEmpty
          ? const Center(
              child: Text(
                '냉장고가 비어있습니다.\n재료를 추가해보세요!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _ingredients.length,
              itemBuilder: (context, index) {
                final ingredient = _ingredients[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: const Icon(Icons.food_bank),
                    title: Text(ingredient.name),
                    subtitle: ingredient.quantity != null && ingredient.unit != null
                        ? Text('${ingredient.quantity} ${ingredient.unit}')
                        : null,
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        setState(() {
                          _ingredients.removeAt(index);
                        });
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }

  void _showAddIngredientDialog() {
    // 재료 추가 다이얼로그 표시
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('재료 추가'),
        content: const Text('재료 추가 기능은 곧 구현될 예정입니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }
}

