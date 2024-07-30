import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:usb_serial/transaction.dart';
import 'package:usb_serial/usb_serial.dart';

class Usb extends Model {

  UsbPort? port;
  String status = "Em espera";
  List<Widget> ports = [];
  List<Widget> serialData = [];
  List<UsbDevice> 
  devices = [];

  StreamSubscription<String>? subscription;
  Transaction<String>? transaction;
  UsbDevice? devicer;
  String? value;
  String? numero;

  Future<bool> connectTo(device) async {
    serialData.clear();

    if (subscription != null) {
      subscription!.cancel();
      subscription = null;
    }

    if (transaction != null) {
      transaction!.dispose();
      transaction = null;
    }

    if (port != null) {
      port!.close();
      port = null;
    }

    if (device == null) {
      devicer = null;

      status = "Desconectadar";

      return true;
    }

    port = await device.create();
    if (await (port!.open()) != true) {
      status = "Falha ao conectar";

      return false;
    }
    devicer = device;

    await port!.setDTR(true);
    await port!.setRTS(true);
    await port!.setPortParameters(
        115200, UsbPort.DATABITS_8, UsbPort.STOPBITS_1, UsbPort.PARITY_NONE);

    transaction = Transaction.stringTerminated(
        port!.inputStream as Stream<Uint8List>, Uint8List.fromList([13, 10]));

    subscription = transaction!.stream.listen((String line) {
      serialData.add(Text(line));
      if (serialData.length > 20) {
        serialData.removeAt(0);
      }
    });
    status = "Conectadar";
    notifyListeners();

    return true;
  }

  void getPorts() async {
    ports = [];
    devices = await UsbSerial.listDevices();
    if (!devices.contains(devicer)) {
      connectTo(null);
    }
    notifyListeners();

    for (var device in devices) {
      ports.add(ListTile(
          leading: const Icon(Icons.usb),
          title: Text(device.productName!),
          subtitle: Text(device.manufacturerName!),
          trailing: ElevatedButton(
            child: Text(devicer == device ? "Desconectar" : "Conectar"),
            onPressed: () {
              connectTo(devicer == device ? null : device).then((res) {
                getPorts();
              });
            },
          )));
    }
    notifyListeners();
  }

  Future<String?> transacao(int number, int tempo) async {
    value = await transaction!.transaction(
        port!, Uint8List.fromList([number]), Duration(seconds: tempo));
    notifyListeners();
    return value;
  }

  Future<double?> ping(int number, int tempo) async {
    numero =  await transaction!.transaction(
            port!, Uint8List.fromList([number]), Duration(seconds: tempo));
    notifyListeners();
    return double.parse(numero!);
  }
}
