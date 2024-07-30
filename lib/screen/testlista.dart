import 'dart:typed_data';
import 'package:screenshot/screenshot.dart';
import 'package:exemple_usb/model/usb.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'dart:async';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';

class Testelista extends StatefulWidget {
  const Testelista({super.key});

  @override
  State<Testelista> createState() => _TestelistaState();
}

class _TestelistaState extends State<Testelista> {
  ScreenshotController screenshotController = ScreenshotController();

  List<int> _zeros = [];
  final _lista = [];
  List<LiveData>? chartData;
  late ChartSeriesController? _chartSeriesController;
  int time = 0;
  int count = 0;
  String dropdownValue = "50000";
  bool first = true;
  Timer? _timer;

  late ZoomPanBehavior _zoomPanBehavior;
  late TooltipBehavior _tooltipBehavior;

  @override
  void initState() {
    Usb model = ScopedModel.of(context);
    model.transaction!.stream.listen((event) {
      _lista.add(double.parse(event) / 1400000);
    });
    _zeros = getIndexes(1024);
    chartData = getChartData();
    _tooltipBehavior = TooltipBehavior(
        enable: true,
        header: "Frequencia",
        format: 'X = ' 'point.x' 'Hz \n' 'Y = ' 'point.y' 'V',
        duration: 10000);
    _zoomPanBehavior = ZoomPanBehavior(
        enablePanning: true,
        // Enables pinch zooming
        enablePinching: true);
    super.initState();
  }

  @override
  void dispose() {
    _timer!.cancel();
    chartData!.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<Usb>(builder: (context, child, model) {
      return SafeArea(
          child: Scaffold(
              appBar: AppBar(
                centerTitle: true,
                title: const Text('FFT'),
                backgroundColor: Colors.white,
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
                      setState(() {
                        dropdownValue = newValue!;
                      });
                      time = 0;
                    },
                    icon: const Icon(Icons.arrow_drop_down),
                    style: const TextStyle(color: Colors.black, fontSize: 18),
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                  ),
                  IconButton(
                      onPressed: () {
                        _timer?.cancel();
                        chartData!.clear();
                        model.port!.write(Uint8List.fromList([97]));
                        _timer = Timer.periodic(
                            const Duration(seconds: 1), updateDataSource);
                      },
                      icon: const Icon(Icons.replay)),
                  IconButton(
                      onPressed: _captureScreen, icon: const Icon(Icons.image))
                ],
              ),
              body: Screenshot(
                controller: screenshotController,
                child: SfCartesianChart(
                    tooltipBehavior: _tooltipBehavior,
                    zoomPanBehavior: _zoomPanBehavior,
                    backgroundColor: Colors.cyan[50],
                    series: <CartesianSeries>[
                      FastLineSeries<LiveData, double>(
                        onRendererCreated: (ChartSeriesController controller) {
                          _chartSeriesController = controller;
                        },
                        dataSource: chartData,
                        color: Colors.green,
                        sortFieldValueMapper: (LiveData sales, _) =>
                            sales.speed,
                        xValueMapper: (LiveData sales, _) => sales.time,
                        yValueMapper: (LiveData sales, _) => sales.speed,
                      )
                    ],
                    primaryXAxis: const NumericAxis(
                      isVisible: false,
                      title: AxisTitle(
                          text: 'Bins Fs/Ns',
                          alignment: ChartAlignment.far,
                          textStyle: TextStyle(
                              fontStyle: FontStyle.italic,
                              fontSize: 24,
                              fontWeight: FontWeight.w900)),
                      labelStyle: TextStyle(fontSize: 20, color: Colors.black),
                      borderColor: Colors.black,
                      edgeLabelPlacement: EdgeLabelPlacement.shift,
                      //title: AxisTitle(text: 'Time (seconds)')
                    ),
                    primaryYAxis: const NumericAxis(
                      labelStyle: TextStyle(fontSize: 20, color: Colors.black),
                      axisLine: AxisLine(width: 0),
                      minorGridLines:
                          MinorGridLines(width: 0.5, color: Colors.black),
                      majorGridLines: MajorGridLines(
                          width: 1, color: Colors.blue, dashArray: [10, 10]),
                      majorTickLines: MajorTickLines(size: 1),
                      // title: AxisTitle(text: 'Internet speed (Mbps)')
                    )),
              )));
    });
  }

  void updateDataSource(Timer timer) {
    for (int i = 0; i < 2048; i++) {
      chartData!.add(
          LiveData((i * double.parse(dropdownValue) / 2048), _lista[count]));
      count++;
    }
    if (first) {
      _chartSeriesController?.updateDataSource(addedDataIndexes: _zeros);
      first = false;
    }else{
      _chartSeriesController?.updateDataSource(updatedDataIndexes: _zeros);
    }
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

  final double time;
  final double speed;
}
