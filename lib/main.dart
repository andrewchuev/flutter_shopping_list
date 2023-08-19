import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(ShoppingListApp());

class ShoppingListApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Список покупок',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.system,
      home: ShoppingListPage(),
    );
  }
}

class ShoppingListPage extends StatefulWidget {
  @override
  _ShoppingListPageState createState() => _ShoppingListPageState();
}

class _ShoppingListPageState extends State<ShoppingListPage> {
  List<String> _shoppingList = [];
  List<String> _archivedList = [];
  final _itemController = TextEditingController();
  bool _showArchived = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  _loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _shoppingList = (prefs.getStringList('shoppingList') ?? []);
      _archivedList = (prefs.getStringList('archivedList') ?? []);
    });
  }

  _saveData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList('shoppingList', _shoppingList);
    prefs.setStringList('archivedList', _archivedList);
  }

  _addItem() {
    if (_itemController.text.isNotEmpty) {
      setState(() {
        _shoppingList.add(_itemController.text);
        _itemController.clear();
        _saveData();
      });
    }
  }

  _editItem(int index) async {
    TextEditingController editController = TextEditingController(text: _shoppingList[index]);
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Редактировать товар'),
          content: TextField(
            controller: editController,
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Отмена'),
              onPressed: Navigator.of(context).pop,
            ),
            TextButton(
              child: Text('Сохранить'),
              onPressed: () {
                if (editController.text.isNotEmpty) {
                  setState(() {
                    _shoppingList[index] = editController.text;
                    _saveData();
                  });
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  _archiveItem(int index) {
    setState(() {
      _archivedList.add(_shoppingList[index]);
      _shoppingList.removeAt(index);
      _saveData();
    });
  }

  _unarchiveItem(int index) {
    setState(() {
      _shoppingList.add(_archivedList[index]);
      _archivedList.removeAt(index);
      _saveData();
    });
  }

  _deleteItem(int index) {
    setState(() {
      if (_showArchived) {
        _archivedList.removeAt(index);
      } else {
        _shoppingList.removeAt(index);
      }
      _saveData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_showArchived ? 'Архив' : 'Список покупок'),
        actions: [
          IconButton(
            icon: Icon(_showArchived ? Icons.shopping_cart : Icons.archive),
            onPressed: () {
              setState(() {
                _showArchived = !_showArchived;
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _itemController,
              onSubmitted: (value) => _addItem(),
              decoration: InputDecoration(
                labelText: 'Добавить товар',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _addItem,
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _showArchived ? _archivedList.length : _shoppingList.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_showArchived ? _archivedList[index] : _shoppingList[index]),
                  onLongPress: _showArchived ? null : () => _editItem(index),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      if (_showArchived)
                        IconButton(
                          icon: const Icon(Icons.shopping_cart),
                          onPressed: () => _unarchiveItem(index),
                        )
                      else
                        IconButton(
                          icon: const Icon(Icons.archive),
                          onPressed: () => _archiveItem(index),
                        ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _deleteItem(index),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
