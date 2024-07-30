import 'dart:math';
import 'dart:typed_data';
import 'package:screenshot/screenshot.dart';
import 'package:exemple_usb/model/usb.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'dart:async';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';

class Test extends StatefulWidget {
  const Test({super.key});

  @override
  State<Test> createState() => _TestState();
}

class _TestState extends State<Test> {
  //Create an instance of ScreenshotController
  ScreenshotController screenshotController = ScreenshotController();

  List<int> _zeros = [];
  final List<double> _lista = [];
  List<LiveData>? chartData;
  late ChartSeriesController? _chartSeriesController;
  int time = 0;
  int count = 83;
  String dropdownValue = "50000";
  bool first = true;
  bool color = false;
  bool startDetect = false;
  bool oneTime = false;
  int startValue = 0;
  int endValue = 0;
  double vpow = 0;

  late ValueNotifier<double> vMax;
  late ValueNotifier<double> vMin;
  late ValueNotifier<double> vPp;
  late ValueNotifier<double> vRMS;
  late ValueNotifier<int> fHz;

  @override
  void initState() {
    _zeros = getIndexes(256);
    vMax = ValueNotifier<double>(0);
    vRMS = ValueNotifier<double>(0);
    vMin = ValueNotifier<double>(0);
    vPp = ValueNotifier<double>(0);
    fHz = ValueNotifier<int>(0);
    Usb model = ScopedModel.of(context);
    model.port?.write(Uint8List.fromList([53]));
    model.transaction!.stream.listen((event) {
      _lista.add(3.3 * double.parse(event) / 4095);
      if (_lista.length == 260) {
        updateDataSource();
      }
    });
    chartData = getChartData();
    super.initState();
  }

  @override
  void dispose() {
    chartData!.clear();
    vMax.dispose();
    vMin.dispose();
    vPp.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<Usb>(builder: (context, child, model) {
      return SafeArea(
          child: Scaffold(
              appBar: AppBar(
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: () {
                    Navigator.of(context).pop();
                    model.port?.write(Uint8List.fromList([101]));
                  },
                ),
                centerTitle: true,
                title: const Text('Osciloscópio'),
                backgroundColor: Colors.green,
                actions: <Widget>[
                  DropdownButton(
                    value: dropdownValue,
                    items: [
                      DropdownMenuItem(
                        value: '100',
                        child: const Text('100 Hz'),
                        onTap: () {
                          model.port!.write(Uint8List.fromList([48]));
                        },
                      ),
                      DropdownMenuItem(
                        value: '500',
                        child: const Text('500 Hz'),
                        onTap: () {
                          model.port!.write(Uint8List.fromList([49]));
                        },
                      ),
                      DropdownMenuItem(
                        value: '1000',
                        child: const Text('1 kHz'),
                        onTap: () {
                          model.port!.write(Uint8List.fromList([50]));
                        },
                      ),
                      DropdownMenuItem(
                        value: '5000',
                        child: const Text('5 kHz'),
                        onTap: () {
                          model.port!.write(Uint8List.fromList([51]));
                        },
                      ),
                      DropdownMenuItem(
                        value: '10000',
                        child: const Text('10 khz'),
                        onTap: () {
                          model.port!.write(Uint8List.fromList([52]));
                        },
                      ),
                      DropdownMenuItem(
                        value: '50000',
                        child: const Text('50 kHz'),
                        onTap: () {
                          model.port!.write(Uint8List.fromList([53]));
                        },
                      ),
                      DropdownMenuItem(
                        value: '100000',
                        child: const Text('100 kHz'),
                        onTap: () {
                          model.port!.write(Uint8List.fromList([54]));
                        },
                      ),
                      DropdownMenuItem(
                        value: '250000',
                        child: const Text('250 kHz'),
                        onTap: () {
                          model.port!.write(Uint8List.fromList([55]));
                        },
                      ),
                    ],
                    onChanged: (newValue) {
                        dropdownValue = newValue!;
                    },
                    icon: const Icon(Icons.arrow_drop_down),
                    style: const TextStyle(color: Colors.black, fontSize: 18),
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                  ),
                  IconButton(
                      onPressed: () {
                        count = 83;
                        chartData!.clear();
                        _lista.clear();
                        model.port!.write(Uint8List.fromList([83]));
                      },
                      icon: const Icon(Icons.play_arrow)),
                  // IconButton(
                  //     onPressed: () {
                  //       _timer!.cancel();
                  //     },
                  //     icon: const Icon(Icons.pause)),
                  IconButton(
                      onPressed: _captureScreen, icon: const Icon(Icons.image))
                ],
              ),
              body: Screenshot(
                controller: screenshotController,
                child: Row(
                  children: [
                    Container(
                      width: 120,
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        border: const Border(
                          right: BorderSide(width: 2),
                        ),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(8)),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                              onPressed: () {
                                count = 84;
                                chartData!.clear();
                                _lista.clear();
                                model.port!.write(Uint8List.fromList([84]));
                              },
                              style: ElevatedButton.styleFrom(
                                shape: const BeveledRectangleBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.zero)),
                                backgroundColor: Colors.green,
                              ),
                              child: const Text(
                                'Trigger',
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                              )),
                          ValueListenableBuilder(
                              valueListenable: fHz,
                              builder: (BuildContext context, value,
                                      Widget? child) =>
                                  Expanded(
                                      child: Text(
                                    'freq: \n $value Hz',
                                    style: const TextStyle(fontSize: 14),
                                  ))),
                          ValueListenableBuilder(
                              valueListenable: vMax,
                              builder: (BuildContext context, value,
                                      Widget? child) =>
                                  Expanded(
                                      child: Text(
                                    'Vmax: \n${value.toStringAsFixed(2)}V',
                                    style: const TextStyle(fontSize: 14),
                                  ))),
                          ValueListenableBuilder(
                              valueListenable: vMin,
                              builder: (BuildContext context, value,
                                      Widget? child) =>
                                  Expanded(
                                      child: Text(
                                    'Vmin: \n${value.toStringAsFixed(2)}V',
                                    style: const TextStyle(fontSize: 14),
                                  ))),
                          ValueListenableBuilder(
                              valueListenable: vPp,
                              builder: (BuildContext context, value,
                                      Widget? child) =>
                                  Expanded(
                                      child: Text(
                                          'Vpp: \n${value.toStringAsFixed(2)}V',
                                          style:
                                              const TextStyle(fontSize: 14)))),
                          ValueListenableBuilder(
                              valueListenable: vRMS,
                              builder: (BuildContext context, value,
                                      Widget? child) =>
                                  Expanded(
                                      child: Text(
                                          'VRMS: \n${value.toStringAsFixed(2)}V',
                                          style:
                                              const TextStyle(fontSize: 14)))),
                        ],
                      ),
                    ),
                    Expanded(
                      child: SfCartesianChart(
                          backgroundColor: Colors.blue[50],
                          series: <CartesianSeries>[
                            FastLineSeries<LiveData, int>(
                              markerSettings: const MarkerSettings(
                                  width: 4,
                                  height: 4,
                                  shape: DataMarkerType.circle),
                              onRendererCreated:
                                  (ChartSeriesController controller) {
                                _chartSeriesController = controller;
                              },
                              dataSource: chartData,
                              color: Colors.green,
                              sortingOrder: SortingOrder.values[0],
                              sortFieldValueMapper: (LiveData sales, _) =>
                                  sales.time,
                              xValueMapper: (LiveData sales, _) => sales.time,
                              yValueMapper: (LiveData sales, _) => sales.speed,
                            )
                          ],
                          primaryXAxis: const NumericAxis(
                            isVisible: false,
                            labelStyle:
                                TextStyle(fontSize: 20, color: Colors.green),
                            borderColor: Colors.green,
                            edgeLabelPlacement: EdgeLabelPlacement.shift,
                            interval: 16,
                            //title: AxisTitle(text: 'Time (seconds)')
                          ),
                          primaryYAxis: NumericAxis(
                            labelStyle: const TextStyle(
                                fontSize: 20, color: Colors.green),
                            axisLine: const AxisLine(width: 0),
                            minorGridLines: const MinorGridLines(
                                width: 0.5, color: Colors.blue),
                            majorGridLines: MajorGridLines(
                                width: 1,
                                color: Colors.grey[100],
                                dashArray: const [10, 10]),
                            majorTickLines: const MajorTickLines(size: 1),
                            // title: AxisTitle(text: 'Internet speed (Mbps)')
                          )),
                    ),
                  ],
                ),
              )));
    });
  }

  void updateDataSource() {
    vpow = 0;
    startDetect = false;
    oneTime = false;
    vMin.value = 3.3;
    vMax.value = 0;
    for (int i = 0; i < 256; i++) {
      vpow += pow(_lista[i], 2);
      chartData!.add(LiveData(i, _lista[i]));
      vMax.value = max(vMax.value, _lista[i]);
      vMin.value = min(vMin.value, _lista[i]);
      if ((_lista[i] - 1.65) < 0 &&
          (_lista[i + 1] - 1.65) > 0 &&
          oneTime == false) {
        if (startDetect == false) {
          startValue = i;
          startDetect = true;
        } else if (startDetect == true) {
          endValue = i;
          oneTime = true;
          fHz.value = (int.parse(dropdownValue) / (endValue - startValue)).round();
        }
      }
    }
    vRMS.value = sqrt(vpow / 256);
    vPp.value = vMax.value - vMin.value;
    if (time == 0) {
      _chartSeriesController?.updateDataSource(addedDataIndexes: _zeros);
      time++;
    } else {
      _chartSeriesController?.updateDataSource(updatedDataIndexes: _zeros);
    }
    _lista.clear();
    chartData!.clear();
    Usb model = ScopedModel.of(context);
    model.port!.write(Uint8List.fromList([count]));
  }

  void _captureScreen() async {
    final imageFile = await screenshotController.capture();
    await savedScreenshot(imageFile!);
  }

  Future<String> savedScreenshot(Uint8List bytes) async {
    await [Permission.storage].request();
    final name = '${DateTime.now().millisecondsSinceEpoch}';
    final result = await ImageGallerySaver.saveImage(bytes, name: name);
    return result['filePath'];
  }
}

List<int> getIndexes(int length) {
  final List<int> indexes = <int>[];
  for (int i = 0; i < length; i++) {
    indexes.add(i);
  }
  return indexes;
}

List<LiveData> getChartData() {
  return <LiveData>[
    LiveData(0, 0),
  ];
}

class LiveData {
  LiveData(this.time, this.speed);

  final int time;
  final double speed;
}
