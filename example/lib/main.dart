// ignore_for_file: public_member_api_docs

import 'package:example/text_menu.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flow_chart/flutter_flow_chart.dart';
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
      title: 'EasyHour New Editor',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF00ADE6)),
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Dashboard dashboard = Dashboard();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'EasyHour New Editor',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF00ADE6),
        actions: [
          IconButton(
            onPressed: _addMap,
            icon: const Icon(Icons.image_search),
            tooltip: 'Sostituisci piantina',
            color: Colors.white,
          ),
          IconButton(
            onPressed: _addDesk,
            icon: const Icon(Icons.desktop_windows_outlined),
            tooltip: 'Aggiungi scrivania',
            color: Colors.white,
          ),
          const VerticalDivider(),
          IconButton(
            onPressed: () =>
                dashboard.setZoomFactor(1.5 * dashboard.zoomFactor),
            icon: const Icon(Icons.zoom_in),
            tooltip: 'Zoom in',
            color: Colors.white,
          ),
          IconButton(
            onPressed: () =>
                dashboard.setZoomFactor(dashboard.zoomFactor / 1.5),
            icon: const Icon(Icons.zoom_out),
            tooltip: 'Zoom out',
            color: Colors.white,
          ),
          IconButton(
            onPressed: dashboard.recenter,
            icon: const Icon(Icons.center_focus_strong),
            tooltip: 'Center view',
            color: Colors.white,
          ),
          const VerticalDivider(),
          IconButton(
            onPressed: _saveMap,
            icon: const Icon(Icons.save_outlined),
            tooltip: 'Salva',
            color: Colors.white,
          ),
        ],
      ),
      backgroundColor: Colors.black12,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: FlowChart(
              dashboard: dashboard,
              // onNewConnection: (p1, p2) {
              //   debugPrint('new connection');
              // },
              onDashboardTapped: (context, position) {
                debugPrint('Dashboard tapped $position');
                // _displayDashboardMenu(context, position);
                _addDesk(position);
              },
              // onScaleUpdate: (newScale) {
              //   debugPrint('Scale updated. new scale: $newScale');
              // },
              // onDashboardSecondaryTapped: (context, position) {
              //   debugPrint('Dashboard right clicked $position');
              //   _displayDashboardMenu(context, position);
              // },
              // onDashboardLongTapped: (context, position) {
              //   debugPrint('Dashboard long tapped $position');
              // },
              // onDashboardSecondaryLongTapped: (context, position) {
              //   debugPrint(
              //     'Dashboard long tapped with mouse right click $position',
              //   );
              // },
              // onElementLongPressed: (context, position, element) {
              //   debugPrint('Element with "${element.text}" text long pressed');
              // },
              // onElementSecondaryLongTapped: (context, position, element) {
              //   debugPrint('Element with "${element.text}" text '
              //       'long tapped with mouse right click');
              // },
              onElementPressed: (context, position, element) {
                debugPrint('Element with "${element.text}" text pressed');
                if (element.kind == ElementKind.image) {
                  _addDesk(position.translate(0, -55));
                } else {
                  _displayElementMenu(context, position, element);
                }
              },
              // onElementSecondaryTapped: (context, position, element) {
              //   debugPrint('Element with "${element.text}" text pressed');
              //   _displayElementMenu(context, position, element);
              // },
              // onPivotSecondaryPressed: (context, pivot) {
              //   dashboard.removeDissection(pivot);
              // },
            ),
          ),
          Container(
            width: 220,
            color: const Color(0xFF019CE4),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHelpEntry(
                    title: '1. Aggiungi la piantina',
                    help:
                        'Aggiungi la piantina catastale da usare come base in formato PNG o PDF.',
                    onTap: _addMap,
                    done: dashboard.elements.firstOrNull?.kind ==
                        ElementKind.image,
                  ),
                  const Divider(),
                  _buildHelpEntry(
                    title: '2. Aggiungi la prima scrivania',
                    help:
                        'Aggiungi la prima scrivania cliccando sulla piantina, quindi ridimensionala in modo che si sovrapponga al disegno della scrivania sottostante. '
                        'Per facilitare l\'immissione, le scrivanie successive avranno automaticamente la dimensione dell\'ultima scrivania inserita.',
                    onTap: _addDesk,
                    done: dashboard.elements.lastOrNull?.kind ==
                        ElementKind.rectangle,
                  ),
                  const Divider(),
                  _buildHelpEntry(
                    title: '3. Aggiungi le altre scrivanie',

                    help:
                        'Per ogni scrivania aggiungi un rettangolo e posizionalo esattamente sopra alla scrivania corrispondente. '
                        'Il nome deve corrispondere esattamente a quello inserito in fase di creazione dell\'ufficio, come ad es. "A1" o "SCR-1".',

                    onTap: _addDesk,
                    done: false, // FIXME: true se le ho messe tutte
                  ),
                  const Divider(),
                  _buildHelpEntry(
                    title: '4. Salva la piantina',
                    help: '',
                    onTap: _saveMap,
                    done: false,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      // ),
    );
  }

  Widget _buildHelpEntry({
    required String title,
    required String help,
    required VoidCallback onTap,
    required bool done,
  }) =>
      Opacity(
        opacity: done ? 0.5 : 1,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          InkWell(
            onTap: onTap,
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Text(
            help,
            style: const TextStyle(color: Colors.white),
          ),
        ]),
      );

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
            onTap: () => dashboard.removeElement(element),
            child: const Text('Delete'),
          ),
          TextMenu(element: element),
          // ElementSettingsMenu(
          //   element: element,
          // ),
        ],
        parentContext: context,
      ),
    );
  }

  // void _displayDashboardMenu(BuildContext context, Offset position) {
  //   StarMenuOverlay.displayStarMenu(
  //     context,
  //     StarMenu(
  //       params: StarMenuParameters(
  //         shape: MenuShape.linear,
  //         openDurationMs: 60,
  //         linearShapeParams: const LinearShapeParams(
  //           angle: 270,
  //           alignment: LinearAlignment.left,
  //           space: 10,
  //         ),
  //         // calculate the offset from the dashboard center
  //         centerOffset: position -
  //             Offset(
  //               dashboard.dashboardSize.width / 2,
  //               dashboard.dashboardSize.height / 2,
  //             ),
  //       ),
  //       onItemTapped: (index, controller) => controller.closeMenu!(),
  //       parentContext: context,
  //       items: [
  //         ActionChip(
  //           label: const Text('Remove all'),
  //           onPressed: () {
  //             dashboard.removeAllElements();
  //           },
  //         ),
  //         ActionChip(
  //           label: const Text('SAVE dashboard'),
  //           onPressed: () async {
  //             final appDocDir = await path.getApplicationDocumentsDirectory();
  //             dashboard.saveDashboard('${appDocDir.path}/FLOWCHART.json');
  //           },
  //         ),
  //         ActionChip(
  //           label: const Text('LOAD dashboard'),
  //           onPressed: () async {
  //             final appDocDir = await path.getApplicationDocumentsDirectory();
  //             dashboard.loadDashboard('${appDocDir.path}/FLOWCHART.json');
  //           },
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Offset get dashboardCenter => Offset(
      dashboard.dashboardSize.width / 2, dashboard.dashboardSize.height / 2);

  _addMap() async {
    final pickResult = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );
    if (pickResult == null) return;
    if (dashboard.elements.firstOrNull?.kind == ElementKind.image) {
      dashboard.removeElement(dashboard.elements.first);
    }
    dashboard.addElement(
      FlowElement(
        position: Offset.zero,
        kind: ElementKind.image,
        data: Image.memory(pickResult.files.single.bytes!).image,
      )
        ..isDraggable = true
        ..isResizable = true
        ..isConnectable = false,
      position: 0,
    );
    // FIXME: reload solo help
    setState(() {});
  }

  _addDesk([Offset? position]) {
    final lastElement = dashboard.elements.lastOrNull;
    final lastElementSize =
        lastElement?.kind == ElementKind.rectangle ? lastElement!.size : null;
    dashboard.addElement(
      FlowElement(
        position: position ?? dashboardCenter,
        size: lastElementSize ?? const Size(55, 55),
        text: '${dashboard.elements.length}',
        handlerSize: 25,
        kind: ElementKind.rectangle,
      )
        ..isDraggable = true
        ..isResizable = true
        ..isConnectable = false,
    );
    // FIXME: reload solo help
    setState(() {});
  }

  _saveMap([Offset? position]) {
    // TODO
    showMessage("TODO");
  }

  showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      duration: const Duration(seconds: 2),
      behavior: SnackBarBehavior.floating,
    ));
  }
}
