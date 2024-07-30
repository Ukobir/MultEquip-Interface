import 'package:flutter/material.dart';
import 'package:usb_serial/usb_serial.dart';
import 'package:exemple_usb/model/usb.dart';
import 'package:scoped_model/scoped_model.dart';

class Connect extends StatefulWidget {
  const Connect({super.key});

  @override
  State<Connect> createState() => _ConnectState();
}

class _ConnectState extends State<Connect> {
  String? _value;

  @override
  void initState() {
    super.initState();
    Usb model = ScopedModel.of(context);
    UsbSerial.usbEventStream!.listen((UsbEvent event) {
      model.getPorts();
    });

    model.getPorts();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<Usb>(
      builder: (context, child, model) {
        return Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: const Text('Conexão'),
          ),
          body: SingleChildScrollView(
            child: Center(
                child: Container(
              margin: const EdgeInsets.all(24),
              child: Column(children: <Widget>[
                Text(
                    model.ports.isNotEmpty
                        ? "Porta serial disponível"
                        : "Porta serial indisponível",
                    style: Theme.of(context).textTheme.titleLarge),
                ...model.ports,
                Text('Estado: ${model.status}\n'),
                Text('info: ${model.port.toString()}\n'),
                Text(_value ?? ""),
                ElevatedButton(
                    style: const ButtonStyle(
                        backgroundColor: WidgetStatePropertyAll(Colors.purple)),
                    onPressed: () async {
                      //outro jeito de enviar dados
                      // await model.port!.write(Uint8List.fromList([98]));
                      // model.transaction!.stream.listen( (String data) {
                      //   _value = data;
                      // });
                      _value = await model.transacao(98, 1);
                    },
                    child: const Text(
                      'Teste',
                      style: TextStyle(color: Colors.white),
                    )),
              ]),
            )),
          ),
        );
      },
    );
  }
}
