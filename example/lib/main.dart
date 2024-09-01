// ignore_for_file: public_member_api_docs

import 'package:example/element_settings_menu_web.dart';
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
      home: EasyDeskEditor(prefix: 'A-'),
    );
  }
}

class EasyDeskEditor extends StatefulWidget {
  final String prefix;

  EasyDeskEditor({required this.prefix, super.key});

  @override
  State<EasyDeskEditor> createState() => _EasyDeskEditorState();
}

class _EasyDeskEditorState extends State<EasyDeskEditor> {
  final Dashboard dashboard = Dashboard();

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
          _buildAppBarIcon(
            onPressed: _addMap,
            icon: Icons.image_search,
            tooltip: 'Sostituisci piantina',
          ),
          _buildAppBarIcon(
            onPressed: _addDesk,
            icon: Icons.desktop_windows_outlined,
            tooltip: 'Aggiungi scrivania',
          ),
          const VerticalDivider(),
          _buildAppBarIcon(
            onPressed: _doUndo,
            icon: Icons.undo,
            tooltip: 'Undo',
          ),
          _buildAppBarIcon(
            onPressed: _doRedo,
            icon: Icons.redo,
            tooltip: 'Redo',
          ),
          const VerticalDivider(),
          _buildAppBarIcon(
            onPressed: () =>
                dashboard.setZoomFactor(1.5 * dashboard.zoomFactor),
            icon: Icons.zoom_in,
            tooltip: 'Zoom in',
          ),
          _buildAppBarIcon(
            onPressed: () =>
                dashboard.setZoomFactor(dashboard.zoomFactor / 1.5),
            icon: Icons.zoom_out,
            tooltip: 'Zoom out',
          ),
          _buildAppBarIcon(
            onPressed: dashboard.recenter,
            icon: Icons.center_focus_strong,
            tooltip: 'Center view',
          ),
          const VerticalDivider(),
          _buildAppBarIcon(
            onPressed: _saveMap,
            icon: Icons.save_outlined,
            tooltip: 'Salva',
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
              onDashboardTapped: (context, position) {
                debugPrint('Dashboard tapped $position');
                _addDesk(position);
              },
              onElementPressed: (context, position, element) {
                debugPrint('Element with "${element.text}" text pressed');
                if (element.kind == ElementKind.image) {
                  _addDesk(position.translate(0, -55));
                } else {
                  // _displayElementMenu(context, position, element);
                  dashboard.setElementEditingText(element, true);
                }
              },
            ),
          ),
          _buildHelpSidebar(),
        ],
      ),
    );
  }

  Widget _buildAppBarIcon({
    required String tooltip,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(icon),
      tooltip: tooltip,
      color: Colors.white,
    );
  }

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
            onTap: () => _removeDesk(element),
            child: const Text('Delete'),
          ),
          TextMenu(element: element),
          InkWell(
            onTap: () {
              dashboard.removeElementConnections(element);
            },
            child: const Text('Remove all connections'),
          ),
          InkWell(
            onTap: () {
              dashboard.setElementDraggable(element, !element.isDraggable);
            },
            child:
                Text('Toggle Draggable (${element.isDraggable ? '✔' : '✘'})'),
          ),
          InkWell(
            onTap: () {
              dashboard.setElementConnectable(element, !element.isConnectable);
            },
            child: Text(
              'Toggle Connectable (${element.isConnectable ? '✔' : '✘'})',
            ),
          ),
          InkWell(
            onTap: () {
              dashboard.setElementResizable(element, !element.isResizable);
            },
            child:
                Text('Toggle Resizable (${element.isResizable ? '✔' : '✘'})'),
          ),
          ElementSettingsMenu(
            element: element,
          ),
        ],
        parentContext: context,
      ),
    );
  }

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
    setState(() {});
  }

  _addDesk([Offset? position]) {
    final lastElement = dashboard.elements.lastOrNull;
    final lastElementSize =
        lastElement?.kind == ElementKind.rectangle ? lastElement!.size : null;
    debugPrint(
        "lastElementSize=$lastElementSize dashboard.zoomFactor=${dashboard.zoomFactor}");
    dashboard.addElement(
      FlowElement(
        position: position ?? dashboardCenter,
        size: (lastElementSize ?? const Size(55, 55)) / dashboard.zoomFactor,
        text:
            '${widget.prefix}${dashboard.elements.where((e) => e.kind == ElementKind.rectangle).length + 1}',
        handlerSize: 25,
        kind: ElementKind.rectangle,
      )
        ..isDraggable = true
        ..isResizable = true
        ..isConnectable = false
        ..isDeletable = true,
    );
    setState(() {});
  }

  _removeDesk(FlowElement element) {
    dashboard.removeElement(element);
    setState(() {});
  }

  _doUndo() {
    // TODO
  }

  _doRedo() {
    // TODO
  }

  _saveMap([Offset? position]) {
    // TODO
  }

  Widget _buildHelpSidebar() {
    return Container(
      width: 220,
      color: const Color(0xFF019CE4),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHelpEntry(
              title: '1. Aggiungi la piantina',
              help:
                  'Aggiungi la piantina catastale da usare come base in formato PNG o PDF.',
              onTap: _addMap,
              done: dashboard.elements.firstOrNull?.kind == ElementKind.image,
            ),
            _buildHelpEntry(
              title: '2. Aggiungi la prima scrivania',
              help:
                  'Aggiungi la prima scrivania cliccando sulla piantina, quindi ridimensionala in modo che si sovrapponga al disegno della scrivania sottostante. '
                  'Per facilitare l\'immissione, le scrivanie successive avranno automaticamente la dimensione dell\'ultima scrivania inserita.',
              onTap: _addDesk,
              done:
                  dashboard.elements.lastOrNull?.kind == ElementKind.rectangle,
            ),
            _buildHelpEntry(
              title: '3. Aggiungi le altre scrivanie',

              help:
                  'Per ogni scrivania aggiungi un rettangolo e posizionalo esattamente sopra alla scrivania corrispondente. '
                  'Il nome deve corrispondere esattamente a quello inserito in fase di creazione dell\'ufficio, come ad es. "A1" o "SCR-1".',

              onTap: _addDesk,
              done: false, // FIXME: true se le ho messe tutte
            ),
            _buildHelpEntry(
              title: '4. Salva la piantina',
              // help: '',
              onTap: _saveMap,
              done: false,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHelpEntry({
    required String title,
    String? help,
    required VoidCallback onTap,
    required bool done,
  }) {
    final card = Opacity(
      opacity: done ? 0.5 : 1,
      child: Card(
        elevation: 4,
        margin: EdgeInsets.only(top: 12, right: 12, left: 12),
        color: const Color(0xFF00ADE6),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (help != null)
              Text(
                help,
                style: const TextStyle(color: Colors.white),
              ),
          ]),
        ),
      ),
    );
    return done
        ? Stack(alignment: Alignment.center, children: [
            card,
            Icon(Icons.check, color: Colors.lightGreen, size: 48)
          ])
        : InkWell(onTap: onTap, child: card);
  }
}
