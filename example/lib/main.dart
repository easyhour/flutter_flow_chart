// ignore_for_file: public_member_api_docs

import 'dart:ui' as ui;

import 'package:example/element_settings_menu.dart';
import 'package:example/text_menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_flow_chart/flutter_flow_chart.dart';
import 'package:image/image.dart' as image;
import 'package:star_menu/star_menu.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'EasyHour Editor NG',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const MyHomePage(title: 'EasyHour Editor NG'),
    );
  }
}

///
class MyHomePage extends StatefulWidget {
  const MyHomePage({required this.title, super.key});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

Future<ui.Image> getUiImage(
    String imageAssetPath, int height, int width) async {
  final ByteData assetImageByteData = await rootBundle.load(imageAssetPath);
  image.Image baseSizeImage =
      image.decodeImage(assetImageByteData.buffer.asUint8List())!;
  image.Image resizeImage =
      image.copyResize(baseSizeImage, height: height, width: width);
  ui.Codec codec = await ui.instantiateImageCodec(image.encodePng(resizeImage));
  ui.FrameInfo frameInfo = await codec.getNextFrame();
  return frameInfo.image;
}

class _MyHomePageState extends State<MyHomePage> {
  Dashboard? dashboard;

  @override
  void initState() {
    super.initState();

    getUiImage('test.png', 2000, 1629).then((image) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() => dashboard = Dashboard(backgroundImage: image));
      });
    });
  }

  /// Notifier for the tension slider
  final segmentedTension = ValueNotifier<double>(1);

  @override
  Widget build(BuildContext context) {
    if (dashboard == null) return Container();

    return Scaffold(
      appBar: AppBar(title: Text(widget.title), actions: [
        IconButton(
          onPressed: () =>
              dashboard!.setZoomFactor(1.5 * dashboard!.zoomFactor),
          icon: const Icon(Icons.zoom_in),
        ),
        IconButton(
          onPressed: () =>
              dashboard!.setZoomFactor(dashboard!.zoomFactor / 1.5),
          icon: const Icon(Icons.zoom_out),
        ),
        IconButton(
          onPressed: _deleteAllElements,
          icon: const Icon(Icons.delete_forever_outlined),
        ),
      ]),
      backgroundColor: Colors.black12,
      body: Container(
        constraints: const BoxConstraints.expand(),
        child: FlowChart(
          dashboard: dashboard!,
          onNewConnection: (p1, p2) {
            debugPrint('new connection');
          },
          onDashboardTapped: (context, position) {
            debugPrint('Dashboard tapped $position');
            _addElement(position);
          },
          onScaleUpdate: (newScale) {
            debugPrint('Scale updated. new scale: $newScale');
          },
          onDashboardSecondaryTapped: (context, position) {
            debugPrint('Dashboard right clicked $position');
            _addElement(position);
          },
          onDashboardLongTapped: (context, position) {
            debugPrint('Dashboard long tapped $position');
          },
          onDashboardSecondaryLongTapped: (context, position) {
            debugPrint(
              'Dashboard long tapped with mouse right click $position',
            );
          },
          onElementLongPressed: (context, position, element) {
            debugPrint('Element with "${element.text}" text '
                'long pressed');
          },
          onElementSecondaryLongTapped: (context, position, element) {
            debugPrint('Element with "${element.text}" text '
                'long tapped with mouse right click');
          },
          onElementPressed: (context, position, element) {
            debugPrint('Element with "${element.text}" text pressed');
            _displayElementMenu(context, position, element);
          },
          onElementSecondaryTapped: (context, position, element) {
            debugPrint('Element with "${element.text}" text pressed');
            _displayElementMenu(context, position, element);
          },
          onHandlerPressed: (context, position, handler, element) {
            debugPrint('handler pressed: position $position '
                'handler $handler" of element $element');
            _displayHandlerMenu(position, handler, element);
          },
          onHandlerLongPressed: (context, position, handler, element) {
            debugPrint('handler long pressed: position $position '
                'handler $handler" of element $element');
          },
          onPivotSecondaryPressed: (context, pivot) {
            dashboard!.removeDissection(pivot);
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: dashboard!.recenter,
        child: const Icon(Icons.center_focus_strong),
      ),
    );
  }

  //*********************
  //* POPUP MENUS
  //*********************

  /// Display a drop down menu when tapping on a handler
  void _displayHandlerMenu(
    Offset position,
    Handler handler,
    FlowElement element,
  ) {
    StarMenuOverlay.displayStarMenu(
      context,
      StarMenu(
        params: StarMenuParameters(
          shape: MenuShape.linear,
          openDurationMs: 60,
          linearShapeParams: const LinearShapeParams(
            angle: 270,
            space: 10,
            alignment: LinearAlignment.left,
          ),
          onHoverScale: 1.1,
          useTouchAsCenter: true,
          centerOffset: position -
              Offset(
                dashboard!.dashboardSize.width / 2,
                dashboard!.dashboardSize.height / 2,
              ),
        ),
        onItemTapped: (index, controller) {
          if (index != 2) {
            controller.closeMenu!();
          }
        },
        items: [
          ActionChip(
            label: const Icon(Icons.delete),
            onPressed: () =>
                dashboard!.removeElementConnection(element, handler),
          ),
          ActionChip(
            label: const Icon(Icons.control_point),
            onPressed: () {
              dashboard!.dissectElementConnection(element, handler);
            },
          ),
          ValueListenableBuilder<double>(
            valueListenable: segmentedTension,
            builder: (_, tension, __) {
              return Wrap(
                children: [
                  ActionChip(
                    label: const Text('segmented'),
                    onPressed: () {
                      dashboard!.setArrowStyleByHandler(
                        element,
                        handler,
                        ArrowStyle.segmented,
                        tension: tension,
                      );
                    },
                  ),
                  SizedBox(
                    width: 200,
                    child: Slider(
                      value: tension,
                      max: 3,
                      onChanged: (v) {
                        segmentedTension.value = v;
                        dashboard!.setArrowStyleByHandler(
                          element,
                          handler,
                          ArrowStyle.segmented,
                          tension: v,
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
          ActionChip(
            label: const Text('curved'),
            onPressed: () {
              dashboard!.setArrowStyleByHandler(
                element,
                handler,
                ArrowStyle.curve,
              );
            },
          ),
          ActionChip(
            label: const Text('rectangular'),
            onPressed: () {
              dashboard!.setArrowStyleByHandler(
                element,
                handler,
                ArrowStyle.rectangular,
              );
            },
          ),
        ],
        parentContext: context,
      ),
    );
  }

  /// Display a drop down menu when tapping on an element
  void _displayElementMenu(
    BuildContext context,
    Offset position,
    FlowElement element,
  ) {
    StarMenuOverlay.displayStarMenu(
      context,
      StarMenu(
        params: StarMenuParameters(
          shape: MenuShape.linear,
          openDurationMs: 60,
          linearShapeParams: const LinearShapeParams(
            angle: 270,
            alignment: LinearAlignment.left,
            space: 10,
          ),
          onHoverScale: 1.1,
          centerOffset: position - const Offset(50, 0),
          boundaryBackground: BoundaryBackground(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Theme.of(context).cardColor,
              boxShadow: kElevationToShadow[6],
            ),
          ),
        ),
        onItemTapped: (index, controller) {
          if (!(index == 5 || index == 2)) {
            controller.closeMenu!();
          }
        },
        items: [
          Text(
            element.text,
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
          InkWell(
            onTap: () => dashboard!.removeElement(element),
            child: const Text('Delete'),
          ),
          TextMenu(element: element),
          InkWell(
            onTap: () {
              dashboard!.setElementResizable(element, true);
            },
            child: const Text('Resize'),
          ),
          ElementSettingsMenu(
            element: element,
          ),
        ],
        parentContext: context,
      ),
    );
  }

  _deleteElement() {}

  _deleteAllElements() {
    dashboard!.removeAllElements();
  }

  _addElement(Offset position) {
    final element = FlowElement(
      position: position,
      size: const Size(100, 50),
      text: '${dashboard!.elements.length}',
      handlerSize: 25,
      kind: ElementKind.rectangle,
      handlers: [
        Handler.bottomCenter,
        Handler.topCenter,
        Handler.leftCenter,
        Handler.rightCenter,
      ],
    );
    dashboard!.addElement(element);
    // ..setElementResizable(element, true);
  }
}
