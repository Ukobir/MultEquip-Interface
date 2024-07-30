import 'dart:typed_data';
import 'package:exemple_usb/model/usb.dart';
import 'package:exemple_usb/screen/test.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class Onda extends StatefulWidget {
  const Onda({super.key});

  @override
  State<Onda> createState() => _OndaState();
}

class _OndaState extends State<Onda> {
  ChartSeriesController<LiveData, num>? seriesController;
  late List<LiveData> chartData;

  late bool isLoadMoreView, isNeedToUpdateView, isDataUpdated;

  num? oldAxisVisibleMin, oldAxisVisibleMax;

  late ZoomPanBehavior _zoomPanBehavior;

  late GlobalKey<State> globalKey;

  final _lista = [];

  @override
  void initState() {
    _initializeVariables();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            appBar: AppBar(
              centerTitle: true,
              title: const Text('Forma de Onda'),
              backgroundColor: Colors.orange,
            ),
            body: _buildInfiniteScrollingChart()));
  }

  Future<void> _initializeVariables() async {
    Usb model = ScopedModel.of(context);
    model.port!.write(Uint8List.fromList([83]));
    model.transaction!.stream.listen((event) async {
       _lista.add(3.3 * double.parse(event) / 4095);
    });
    chartData = <LiveData>[
      LiveData(0, 0),
      LiveData(1, 0),
      LiveData(2, 0),
      LiveData(3, 0),
      LiveData(4, 0),
      LiveData(5, 0),
      LiveData(6, 0),
      LiveData(7,0),
      LiveData(8, 0),
      LiveData(9, 0),
    ];
    isLoadMoreView = false;
    isNeedToUpdateView = false;
    isDataUpdated = true;
    globalKey = GlobalKey<State>();
    _zoomPanBehavior =  ZoomPanBehavior(
        enableDoubleTapZooming: true,
        enablePanning: true,
        enablePinching: true,
        enableSelectionZooming: true
    );
  }

  SfCartesianChart _buildInfiniteScrollingChart() {
    return SfCartesianChart(
      backgroundColor: Colors.orange[50],
      key: GlobalKey<State>(),
      onActualRangeChanged: (ActualRangeChangedArgs args) {
        if (args.orientation == AxisOrientation.horizontal) {
          if (isLoadMoreView) {
            args.visibleMin = oldAxisVisibleMin;
            args.visibleMax = oldAxisVisibleMax;
          }
          oldAxisVisibleMin = args.visibleMin as num;
          oldAxisVisibleMax = args.visibleMax as num;

          isLoadMoreView = false;
        }
      },
      zoomPanBehavior: _zoomPanBehavior,
      plotAreaBorderWidth: 0,
      primaryXAxis:  NumericAxis(
          name: 'XAxis',
          interval: 2,
          enableAutoIntervalOnZooming: false,
          edgeLabelPlacement: EdgeLabelPlacement.shift,
          majorTickLines: const MajorTickLines(color: Colors.transparent),
          minorGridLines:
          const MinorGridLines(width: 0.5, color: Colors.blue),
          majorGridLines: const MajorGridLines(
              width: 1, color: Colors.blue, dashArray: [10, 10]),
          axisLabelFormatter: (AxisLabelRenderDetails details) {
            return ChartAxisLabel(details.text.split('.')[0],
                const TextStyle(fontSize: 20, color: Color.fromRGBO(252, 101, 3, 1.0)));
          }
          ),
      primaryYAxis:  NumericAxis(
          axisLine: const AxisLine(width: 0),
          majorTickLines: const MajorTickLines(color: Colors.transparent),
          axisLabelFormatter: (AxisLabelRenderDetails details) {
            return ChartAxisLabel(details.text,
                const TextStyle(fontSize: 20, color: Color.fromRGBO(252, 101, 3, 1.0)));
          }),
      series: getSeries(),
      loadMoreIndicatorBuilder:
          (BuildContext context, ChartSwipeDirection direction) =>
              getloadMoreIndicatorBuilder(context, direction),
    );
  }

  List<LineSeries<LiveData, num>> getSeries() {
    return <LineSeries<LiveData, num>>[
      LineSeries<LiveData, num>(
        width: 5,
        dataSource: chartData,
        color: const Color.fromRGBO(252, 101, 3, 1.0),
        xValueMapper: (LiveData sales, _) => sales.time,
        yValueMapper: (LiveData sales, _) => sales.speed,
        onRendererCreated: (ChartSeriesController<LiveData, num> controller) {
          seriesController = controller;
        },
      ),
    ];
  }

  Widget getloadMoreIndicatorBuilder(
      BuildContext context, ChartSwipeDirection direction) {
    if (direction == ChartSwipeDirection.end) {
      isNeedToUpdateView = true;
      globalKey = GlobalKey<State>();
      return StatefulBuilder(
          key: globalKey,
          builder: (BuildContext context, StateSetter stateSetter) {
            Widget widget;
            if (isNeedToUpdateView) {
              widget = getProgressIndicator();
              _updateView();
              isDataUpdated = true;
            } else {
              widget = Container();
            }
            return widget;
          });
    } else {
      return SizedBox.fromSize(size: Size.zero);
    }
  }

  Widget getProgressIndicator() {
    return Align(
        alignment: Alignment.centerRight,
        child: Padding(
            // ignore: use_named_constants
            padding: const EdgeInsets.only(),
            child: Container(
                width: 50,
                alignment: Alignment.centerRight,
                child: const SizedBox(
                    height: 35,
                    width: 35,
                    child: CircularProgressIndicator(
                      backgroundColor: Colors.transparent,
                      strokeWidth: 3,
                    )))));
  }

  void _updateData() {
    for (int i = 0; i < 10; i++) {
      chartData.add(LiveData(chartData.length - 1, _lista[chartData.length - 1]));
    }
    isLoadMoreView = true;
    seriesController?.updateDataSource(addedDataIndexes: getIndexes(10));
  }

  Future<void> _updateView() async {
    await Future<void>.delayed(const Duration(seconds: 1), () {
      isNeedToUpdateView = false;
      if (isDataUpdated) {
        _updateData();
        isDataUpdated = false;
      }
      if (globalKey.currentState != null) {
        (globalKey.currentState as dynamic).setState(() {});
      }
    });
  }

  List<int> getIndexes(int length) {
    final List<int> indexes = <int>[];
    for (int i = length - 1; i >= 0; i--) {
      indexes.add(chartData.length - 1 - i);
    }
    return indexes;
  }



  @override
  void dispose() {
    seriesController = null;
    super.dispose();
  }
}
