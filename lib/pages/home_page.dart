import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Box? _todolist;
  final TextEditingController textEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Hive.openBox("todoBox").then((_box) {
      setState(() {
        _todolist = _box;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.red,
        statusBarBrightness: Brightness.light,
        statusBarIconBrightness: Brightness.light,
      ),
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: const Text(
              'Note it!',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.red,
          ),
          body: buildUI(),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _displayTextInputDialog(context),
            child: const Icon(Icons.add),
          ),
        ),
      ),
    );
  }

  Widget buildUI() {
    if (_todolist == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    return ValueListenableBuilder(
      valueListenable: _todolist!.listenable(),
      builder: (context, box, child) {
        final todosKeys = box.keys.toList();
        return SizedBox.expand(
          child: ListView.builder(
              itemCount: todosKeys.length,
              itemBuilder: (context, index) {
                Map todo = box.get(todosKeys[index]); // Imp
                final DateTime dateTime = DateTime.parse(todo['time']);
                final String formattedDate = DateFormat('dd-MM-yy, kk:mm').format(dateTime);
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.grey,
                        width: 1
                      )
                    ),
                    child: ListTile(
                      title: Text(todo['content'] ?? ''),
                      //subtitle: Text(todo['time'] ?? ''),
                      subtitle: Text(formattedDate),
                      onLongPress: () async {
                        await box.delete(todosKeys[index]);
                      },
                      trailing: Checkbox(
                        value: todo['isDone'],
                        onChanged: (value) async {
                          todo['isDone'] = value;
                          await box.put(todosKeys[index], todo);
                        },
                      ),
                    ),
                  ),
                );
              }),
        );
      },
    );
  }

  Future<void> _displayTextInputDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Add a note'),
            content: TextField(
              controller: textEditingController,
              decoration: const InputDecoration(hintText: 'Todo....'),
            ),
            actions: [
              MaterialButton(
                onPressed: () {
                  _todolist?.add({
                    'content' : textEditingController.text,
                    'time' : DateTime.now().toIso8601String(),
                    'isDone' : false,
                  });
                  Navigator.pop(context);
                  textEditingController.clear();
                },
                color: Colors.red,
                textColor: Colors.white,
                child: const Text('Save'),
              )
            ],
          );
        });
  }
}
