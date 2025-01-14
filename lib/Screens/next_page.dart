import 'package:flutter/material.dart';

class NextPage extends StatelessWidget {
  final List<Map<String, String>> rows;

  const NextPage({Key? key, required this.rows}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Next Set of Rows'),
        backgroundColor: Colors.blue,
      ),
      body: ListView.builder(
        itemCount: rows.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 0.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                SizedBox(
                  height: 40,
                  width: 160,
                  child: TextFormField(
                    initialValue: rows[index]["description"],
                    decoration: InputDecoration(
                      labelText: 'Description',
                      labelStyle: const TextStyle(fontSize: 20, color: Colors.blue),
                      border: const OutlineInputBorder(),
                      enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 40,
                  width: 100,
                  child: TextFormField(
                    initialValue: rows[index]["qty"],
                    decoration: const InputDecoration(
                      labelText: 'Qty',
                      labelStyle: TextStyle(fontSize: 18, color: Colors.blue),
                      border: OutlineInputBorder(),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 40,
                  width: 100,
                  child: TextFormField(
                    initialValue: rows[index]["amount"],
                    decoration: const InputDecoration(
                      labelText: 'Amount',
                      labelStyle: TextStyle(fontSize: 18, color: Colors.blue),
                      border: OutlineInputBorder(),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
