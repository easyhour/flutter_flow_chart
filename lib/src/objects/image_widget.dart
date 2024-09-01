import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_flow_chart/src/elements/flow_element.dart';

/// A kind of element
class ImageWidget extends StatelessWidget {
  /// Requires element.data to be an ImageProvider.
  ImageWidget({
    required this.element,
    super.key,
  })  : assert(
          element.data is ImageProvider ||
              (element.serializedData?.isNotEmpty ?? false),
          'Missing image ("data" parameter should be an ImageProvider)',
        ),
        imageProvider = element.serializedData?.isNotEmpty ?? false
            ? Image.memory(base64Decode(element.serializedData!)).image
            : element.data as ImageProvider;

  ///
  final FlowElement element;

  /// The image to render
  final ImageProvider imageProvider;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<(ImageInfo?, String?)>(
        future: _loadImageData(context),
        builder: (_, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.data!.$2 != null) {
            return Center(child: Text(snapshot.error.toString()));
          } else {
            debugPrint('Rendering ImageWidget ${element.id} '
                'from provider ${imageProvider.runtimeType}');
            return ColoredBox(
              color: Colors.black12,
              child: Image(
                image: imageProvider,
                width: element.size.width,
                height: element.size.height,
                fit: BoxFit.contain,
              ),
            );
          }
        });
  }

  Future<(ImageInfo?, String?)> _loadImageData(BuildContext context) async {
    debugPrint('Loading image data for ImageWidget ${element.id}');

    final imageStream =
        imageProvider.resolve(createLocalImageConfiguration(context));
    final completer = Completer<(ImageInfo?, String?)>();
    final listener = ImageStreamListener(
      (imageInfo, _) async {
        if (!completer.isCompleted) {
          completer.complete((imageInfo, null));
        }
      },
      onError: (exception, stackTrace) {
        debugPrintStack(stackTrace: stackTrace);
        if (!completer.isCompleted) {
          completer.complete((null, exception.toString()));
        }
      },
    );
    imageStream.addListener(listener);
    final imageInfoOrError = await completer.future;
    imageStream.removeListener(listener);

    // Apply size
    if (element.size == Size.zero) {
      element.changeSize(
        imageInfoOrError.$1 != null
            ? Size(
                imageInfoOrError.$1!.image.width.toDouble(),
                imageInfoOrError.$1!.image.height.toDouble(),
              )
            : const Size(200, 150),
      );
    }

    if (imageInfoOrError.$1 != null) {
      // Serialize image to save/load dashboard
      final imageData = await imageInfoOrError.$1!.image
          .toByteData(format: ImageByteFormat.png);
      element.serializedData = base64Encode(imageData!.buffer.asUint8List());
    }

    return imageInfoOrError;
  }
}
