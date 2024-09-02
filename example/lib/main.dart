// ignore_for_file: public_member_api_docs

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flow_chart/flutter_flow_chart.dart';

import '../platforms/hooks_mobile.dart'
    if (dart.library.js) '../platforms/hooks_web.dart';

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
            onPressed: () => dashboard.setZoomFactor(1.5 * dashboard.zoomFactor,
                focalPoint: Offset.zero),
            icon: Icons.zoom_in,
            tooltip: 'Zoom in',
          ),
          _buildAppBarIcon(
            onPressed: () => dashboard.setZoomFactor(dashboard.zoomFactor / 1.5,
                focalPoint: Offset.zero),
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
                if (hasMap) {
                  _addDesk(position);
                } else {
                  _addMap();
                }
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

  Offset get dashboardCenter => Offset(
      dashboard.dashboardSize.width / 2, dashboard.dashboardSize.height / 2);

  bool get hasMap => dashboard.elements.firstOrNull?.kind == ElementKind.image;

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
        ..isDraggable = false
        ..isResizable = false
        ..isConnectable = false,
      position: 0,
    );
    // dashboard.setGridBackgroundParams(GridBackgroundParams(
    //   backgroundImage: pickResult.files.single.bytes!,
    // ));

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
    saveDashboard(dashboard);
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
              done: hasMap,
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
