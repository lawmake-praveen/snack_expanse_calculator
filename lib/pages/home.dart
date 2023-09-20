import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibration/vibration.dart';

Map<String, dynamic> history = {};

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  dynamic total;
  Map<String, dynamic> snacks = {};

  @override
  void initState() {
    super.initState();
    loadSnacks()
        .then((value) => setState(() => snacks = value))
        .then((value) => totalCalculate());
    loadHistory().then((value) => setState(() => history = value));
  }

  void totalCalculate() {
    total = 0;
    for (var entry in snacks.entries) {
      total += entry.value['cost'] * entry.value['count'];
    }
  }

  void increaseCounter(key) {
    setState(() {
      snacks[key]['count']++;
    });
    totalCalculate();
  }

  void reset() {
    setState(() {
      for (var entry in snacks.entries) {
        entry.value['count'] = 0;
      }
    });
    totalCalculate();
  }

  void decreaseCounter(key) {
    setState(() {
      if (snacks[key]['count'] > 0) {
        Vibration.vibrate(
          duration: 100,
        );
        snacks[key]['count']--;
      }
    });
    totalCalculate();
  }

  Future<void> saveSnacks(Map<String, dynamic> snacks) async {
    final prefs = await SharedPreferences.getInstance();
    final snacksJson = jsonEncode(snacks);
    await prefs.setString('Snacks', snacksJson);
  }

  Future<Map<String, dynamic>> loadSnacks() async {
    final prefs = await SharedPreferences.getInstance();
    final snacksJson = prefs.getString('Snacks');
    if (snacksJson != null) {
      final snacks = jsonDecode(snacksJson);
      return snacks.cast<String, dynamic>();
    } else {
      return {};
    }
  }

  Future<void> saveHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = jsonEncode(history);
    await prefs.setString('SnacksHistory', historyJson);
  }

  Future<Map<String, dynamic>> loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getString('SnacksHistory');
    if (historyJson != null) {
      final history = jsonDecode(historyJson);
      return history.cast<String, dynamic>();
    } else {
      return {};
    }
  }

  void _showAddSnackDialog() {
    String snackName = '';
    int snackCost = 0;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Snack'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                onChanged: (value) {
                  snackName = value;
                },
                decoration: const InputDecoration(labelText: 'Snack Name'),
              ),
              TextField(
                onChanged: (value) {
                  snackCost = int.tryParse(value) ?? 0;
                },
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Snack Cost'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                totalCalculate();
                setState(() {
                  if (snackName.isNotEmpty && snackCost > 0) {
                    snacks[snackName] = {"cost": snackCost, "count": 0};
                    saveSnacks(snacks);
                  }
                });
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void showSaveItemsDialog(total) {
    var date =
        '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}';
    var time =
        '${DateTime.now().hour}:${DateTime.now().minute}:${DateTime.now().second}';
    var dateTime = '${DateTime.now()}';

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              "₹ ${total.toString()}",
              style: const TextStyle(fontSize: 25),
            ),
            content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(date),
                  const SizedBox(
                    height: 6,
                  ),
                  Text(time),
                  const SizedBox(
                    height: 20,
                  ),
                  const Text(
                    'Do you want to save this data?',
                    style: TextStyle(fontSize: 20),
                  ),
                ]),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel')),
              TextButton(
                  onPressed: () {
                    history[dateTime.toString()] = {
                      "Total": total,
                      "Date": date,
                      "Time": time,
                    };
                    saveHistory();
                    Navigator.pop(context);
                  },
                  child: const Text('Save')),
            ],
          );
        });
  }

  Future<bool> confirmDelete() async {
    return await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Delete this Snack'),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                  child: const Text('Cancel')),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
                style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.red)),
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text(
          'Snacks',
          style: TextStyle(fontSize: 28),
        ),
        actions: [
          OutlinedButton(
              onPressed: () {
                _showAddSnackDialog();
              },
              child: const Row(
                children: [
                  Icon(
                    Icons.add,
                    color: Colors.white,
                    size: 30,
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Text(
                    'Add',
                    style: TextStyle(fontSize: 25, color: Colors.white),
                  )
                ],
              )),
        ],
        backgroundColor: Colors.black,
      ),
      body: Column(children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(children: [
              for (var entry in snacks.entries)
                Dismissible(
                  key: Key(entry.key),
                  confirmDismiss: (direction) async {
                    return await confirmDelete();
                  },
                  direction: DismissDirection.startToEnd,
                  onDismissed: (direction) {
                    snacks.remove(entry.key);
                    saveSnacks(snacks);
                    setState(() {
                      totalCalculate();
                    });
                  },
                  background: Container(
                    padding: const EdgeInsets.only(left: 20),
                    color: const Color.fromARGB(255, 255, 17, 0),
                    alignment: Alignment.centerLeft,
                    child: const Icon(
                      Icons.delete,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 20),
                    margin:
                        const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: const Color.fromARGB(255, 226, 226, 226)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(
                              (entry.key),
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(
                              width: 6,
                            ),
                            Text((entry.value['cost'].toString()))
                          ],
                        ),
                        Row(
                          children: [
                            IconButton(
                                onPressed: () {
                                  decreaseCounter(entry.key);
                                  saveSnacks(snacks);
                                },
                                icon: const Icon(Icons.remove)),
                            const SizedBox(
                              width: 10,
                            ),
                            Text(
                              entry.value['count'].toString(),
                              style: const TextStyle(fontSize: 22),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            IconButton(
                                onPressed: () {
                                  increaseCounter(entry.key);
                                  saveSnacks(snacks);
                                },
                                icon: const Icon(Icons.add)),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
            ]),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          height: 70,
          color: Colors.black,
          child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
            ElevatedButton(
              onPressed: () {
                showSaveItemsDialog(total);
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.white),
                shape: MaterialStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
              ),
              child: const Icon(
                Icons.save,
                color: Colors.black,
              ),
            ),
            ElevatedButton(
              onPressed: () {
                reset();
                saveSnacks(snacks);
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.white),
                shape: MaterialStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
              ),
              child: const Icon(
                Icons.replay_outlined,
                color: Colors.black,
              ),
            ),
            Row(
              children: [
                const Text(
                  'Total:  ',
                  style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w600,
                      color: Colors.white),
                ),
                Text(
                  "₹ $total".toString(),
                  style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                      color: Colors.white),
                ),
              ],
            )
          ]),
        )
      ]),
    );
  }
}
