import 'package:exemple_usb/model/usb.dart';
import 'package:exemple_usb/screen/ac.dart';
import 'package:exemple_usb/screen/testlista.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'connect.dart';
import 'ohm.dart';
import 'cap.dart';
import 'test.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScopedModel<Usb>(
      model: Usb(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Builder(
          builder: (context) => Scaffold(
              appBar: AppBar(
                centerTitle: true,
                title: const Text('MultEquip'),
                actions: <Widget>[
                  IconButton(
                    icon: const Icon(Icons.search),
                    tooltip: 'Próxima página',
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => const Connect()));
                    },
                  ),
                ],
              ),
              body: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: ButtonTheme(
                    minWidth: 200.0,
                    height: 100.0,
                    child: Container(
                      margin: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const Ohm()),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.purple),
                            child: const Text(
                              'Ohmmímetro',
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          ),
                          ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const Cap()),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.indigo),
                              child: const Text(
                                'Capacímetro',
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                              )),
                          ElevatedButton(
                              onPressed: () async {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const Test()),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green),
                              child: const Text(
                                'Osciloscópio',
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                              )),
                          // ElevatedButton(
                          //     onPressed: () async {
                          //       Navigator.push(
                          //         context,
                          //         MaterialPageRoute(
                          //             builder: (context) => const Onda()),
                          //       );
                          //     },
                          //     style: ElevatedButton.styleFrom(
                          //         backgroundColor: Colors.orange),
                          //     child: const Text(
                          //       'Forma de Onda',
                          //       style: TextStyle(
                          //           fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                          //     )),
                          ElevatedButton(
                              onPressed: () async {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const Testelista()),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.black),
                              child: const Text(
                                'FFT',
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                              )),
                          ElevatedButton(
                              onPressed: () async {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const Ac()),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange),
                              child: const Text(
                                'Osciloscópio AC',
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                              )),
                        ],
                      ),
                    ),
                  ),
                ),
              )),
        ),
      ),
    );
  }
}
