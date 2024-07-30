import 'dart:typed_data';

import 'package:exemple_usb/model/usb.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

class Cap extends StatefulWidget {
  const Cap({super.key});

  @override
  State<Cap> createState() => _CapState();
}

class _CapState extends State<Cap> {
  double? value;
  String unit = "";

  @override
  void initState() {

    Usb model = ScopedModel.of(context);
    model.transaction!.stream.listen((event) {
      value = double.parse(event);
      unit = "uF";
      setState(() {});
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<Usb>(builder: (context, child, model) {
      return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text(
            'Capacímetro',
            style: TextStyle(color: Colors.black),
          ),
          backgroundColor: Colors.indigo,
          actions: [
            TextButton(
                onPressed: () {
                  model.port!.write(Uint8List.fromList([75]));
                  showDialog<String>(
                    builder: (context) => AlertDialog(
                      title: const Text(
                        "O dispositivo está calibrado!",
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, 'OK'),
                          child: const Text('OK'),
                        ),
                      ],
                    ),
                    context: context,
                  );
                },
                child: const Text(
                  "Calibrar",
                  style: TextStyle(color: Colors.black),
                )),
          ],
        ),
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 18.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Builder(
                          builder: (context) {
                            return Text(
                              value?.toStringAsFixed(2) ?? "Insira o capacitor",
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 70,
                                //color: isFull ? Colors.red.shade600 : Colors.yellow.shade100,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 4,
                              ),
                            );
                          },
                        ),
                      ),
                      Text(
                        unit,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 70,
                          //color: isFull ? Colors.red.shade600 : Colors.yellow.shade100,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 4,
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    model.port?.write(Uint8List.fromList([67]));
                  },
                  style: ButtonStyle(
                    backgroundColor:
                        WidgetStateProperty.all<Color>(Colors.indigo),
                  ),
                  child: const Text(
                    'Amostrar',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
