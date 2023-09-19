
// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './home.dart';

class History extends StatefulWidget {
  const History({super.key});

  @override
  State<History> createState() => _HistoryState();
}

class _HistoryState extends State<History> {
  Future<void> showHistoryDel() async {
    final prefs = await SharedPreferences.getInstance();
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Delete History?'),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel')),
              TextButton(
                  onPressed: () async {
                    await prefs.remove('SnacksHistory');
                    setState(() {
                      history = {};
                    });
                    Navigator.pop(context);
                  },
                  child: const Text('Delete')),
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
          'History',
          style: TextStyle(fontSize: 28),
        ),
        backgroundColor: Colors.black,
      ),
      body: Column(
        children: [
          Expanded(
            child: history.isEmpty
                ? const Center(
                    child: Text('No History Available', style: TextStyle(fontSize: 25),),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    itemCount: history.length,
                    itemBuilder: (context, index) {
                      var entry = history.entries.elementAt(index);
                      var data = entry.value;

                      return ListTile(
                          subtitle: Container(
                        padding:
                            const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                        margin: const EdgeInsets.symmetric(vertical: 5),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: const Color.fromARGB(255, 226, 226, 226)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "${data['Date']}",
                                  style: const TextStyle(
                                      fontSize: 23,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black),
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                Text('${data['Time']}'),
                              ],
                            ),
                            Text(
                              "₹ ${data['Total']}",
                              style: const TextStyle(
                                  fontSize: 33,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black),
                            ),
                          ],
                        ),
                      ));
                    },
                  ),
          ),
          GestureDetector(
            onTap: () => {showHistoryDel()},
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              height: 70,
              color: Colors.black,
              child:
                  const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text(
                  'Clear History',
                  style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w600,
                      color: Colors.white),
                )
              ]),
            ),
          )
        ],
      ),
    );
  }
}
