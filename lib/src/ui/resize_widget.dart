import 'package:flutter/material.dart';
import 'package:flutter_flow_chart/flutter_flow_chart.dart';
import 'package:flutter_flow_chart/src/ui/handler_widget.dart';

import '../objects/rectangle_widget.dart';

/// The widget to press and drag to resize the element
class ResizeWidget extends StatefulWidget {
  ///
  const ResizeWidget({
    required this.element,
    required this.dashboard,
    required this.child,
    super.key,
  });

  ///
  final Dashboard dashboard;

  ///
  final FlowElement element;

  ///
  final Widget child;

  @override
  State<ResizeWidget> createState() => _ResizeWidgetState();
}

class _ResizeWidgetState extends State<ResizeWidget> {
  late Size elementStartSize;
  late Offset elementStartPosition;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.element.size.width,
      height: widget.element.size.height,
      child: Stack(
        children: [
          // widget.child,
          _draggableWidget(),
          _bottomRightHandler(),
        ],
      ),
    );
  }

  Widget _bottomRightHandler() {
    return Listener(
      onPointerDown: (event) {
        elementStartSize = widget.element.size;
      },
      onPointerMove: (event) {
        elementStartSize += event.localDelta;
        widget.element.changeSize(elementStartSize);
      },
      onPointerUp: (event) {
        widget.dashboard.setElementResizable(widget.element, false);
      },
      child: const Align(
        alignment: Alignment.bottomRight,
        child: HandlerWidget(
          width: 30,
          height: 30,
          icon: Icon(Icons.compare_arrows),
        ),
      ),
    );
  }

  Offset delta = Offset.zero;

  Widget _draggableWidget() {
    var tapLocation = Offset.zero;
    var secondaryTapDownPos = Offset.zero;
    final element = RectangleWidget(element: widget.element);
    return GestureDetector(
      onTapDown: (details) => tapLocation = details.globalPosition,
      onSecondaryTapDown: (details) =>
          secondaryTapDownPos = details.globalPosition,
      // onTap: () {
      //   widget.onElementPressed?.call(context, tapLocation);
      // },
      // onSecondaryTap: () {
      //   widget.onElementSecondaryTapped?.call(context, secondaryTapDownPos);
      // },
      // onLongPress: () {
      //   widget.onElementLongPressed?.call(context, tapLocation);
      // },
      // onSecondaryLongPress: () {
      //   widget.onElementSecondaryLongTapped
      //       ?.call(context, secondaryTapDownPos);
      // },
      child: Listener(
        onPointerDown: (event) {
          delta = event.localPosition;
        },
        child: Draggable<FlowElement>(
          data: widget.element,
          dragAnchorStrategy: childDragAnchorStrategy,
          childWhenDragging: const SizedBox.shrink(),
          feedback: Material(
            color: Colors.transparent,
            child: element,
          ),
          // child: ElementHandlers(
          //   dashboard: widget.dashboard,
          //   element: widget.element,
          //   handlerSize: widget.element.handlerSize,
          //   onHandlerPressed: widget.onHandlerPressed,
          //   onHandlerSecondaryTapped: widget.onHandlerSecondaryTapped,
          //   onHandlerLongPressed: widget.onHandlerLongPressed,
          //   onHandlerSecondaryLongTapped: widget.onHandlerSecondaryLongTapped,
          //   child: element,
          // ),
          child: element,
          onDragUpdate: (details) {
            widget.element.changePosition(
              details.globalPosition - widget.dashboard.position - delta,
            );
          },
          onDragEnd: (details) {
            widget.element
                .changePosition(details.offset - widget.dashboard.position);
          },
        ),
      ),
    );
  }
}
