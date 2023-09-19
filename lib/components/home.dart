// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables


import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibration/vibration.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  dynamic total;
  Map<String, dynamic> snacks = {};

  @override
  void initState() {
    super.initState();
    total = 0;
    loadSnacks()
        .then((value) => setState(() => snacks = value))
        .then((value) => totalCalculate());
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

  void _showAddSnackDialog() {
    String snackName = '';
    int snackCost = 0;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Snack'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                onChanged: (value) {
                  snackName = value;
                },
                decoration: InputDecoration(labelText: 'Snack Name'),
              ),
              TextField(
                onChanged: (value) {
                  snackCost = int.tryParse(value) ?? 0;
                },
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Snack Cost'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
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
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
          style: TextStyle(fontSize: 28),
        ),
        actions: [
          OutlinedButton(
              onPressed: () {
                _showAddSnackDialog();
              },
              child: Row(
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
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Column(children: [
              for (var entry in snacks.entries)
                Dismissible(
                  key: Key(entry.key),
                  direction: DismissDirection.startToEnd,
                  onDismissed: (direction) {
                    snacks.remove(entry.key);
                    saveSnacks(snacks);
                    setState(() {
                      totalCalculate();
                    });
                  },
                  background: Container(
                    padding: EdgeInsets.only(left: 20),
                    color: Color.fromARGB(255, 255, 17, 0),
                    alignment: Alignment.centerLeft,
                    child: Icon(
                      Icons.delete,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                    margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Color.fromARGB(255, 226, 226, 226)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(
                              (entry.key),
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(
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
                                icon: Icon(Icons.remove)),
                            SizedBox(
                              width: 10,
                            ),
                            Text(
                              entry.value['count'].toString(),
                              style: TextStyle(fontSize: 22),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            IconButton(
                                onPressed: () {
                                  increaseCounter(entry.key);
                                  saveSnacks(snacks);
                                },
                                icon: Icon(Icons.add)),
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
          padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
          color: Colors.black,
          child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
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
              child: Icon(
                Icons.replay_outlined,
                color: Colors.black,
              ),
            ),
            Row(
              children: [
                Text(
                  'Total:  ',
                  style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w600,
                      color: Colors.white),
                ),
                Text(
                  "₹ $total".toString(),
                  style: TextStyle(
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
