import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class TwoDiScrollAreaWidget extends StatelessWidget {
  TwoDiScrollAreaWidget({
    super.key,
    required this.child
  });
  final Widget child;
  final ScrollController c1 = ScrollController();
  final ScrollController c2 = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      controller: c1,
      thumbVisibility: true,
      child: Scrollbar(
        controller: c2,
        thumbVisibility: true,
        child: TwoDimensionalGridView(
          verticalDetails: ScrollableDetails.vertical(controller: c1),
          horizontalDetails: ScrollableDetails.horizontal(controller: c2),
          diagonalDragBehavior: DiagonalDragBehavior.free,
          delegate: TwoDimensionalChildBuilderDelegate(
              maxXIndex: 0,
              maxYIndex: 0,
              builder: (BuildContext context, ChildVicinity vicinity) {
                return OverflowBox(
                  child: child
                );
              }),
        ),
      ),
    );
  }
}

class TwoDimensionalGridView extends TwoDimensionalScrollView {
  const TwoDimensionalGridView({
    super.key,
    super.primary,
    super.mainAxis = Axis.vertical,
    super.verticalDetails = const ScrollableDetails.vertical(),
    super.horizontalDetails = const ScrollableDetails.horizontal(),
    required TwoDimensionalChildBuilderDelegate delegate,
    super.cacheExtent,
    super.diagonalDragBehavior = DiagonalDragBehavior.none,
    super.dragStartBehavior = DragStartBehavior.start,
    super.keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.manual,
    super.clipBehavior = Clip.hardEdge,
  }) : super(delegate: delegate);

  @override
  Widget buildViewport(
    BuildContext context,
    ViewportOffset verticalOffset,
    ViewportOffset horizontalOffset,
  ) {
    return TwoDimensionalGridViewport(
      horizontalOffset: horizontalOffset,
      horizontalAxisDirection: horizontalDetails.direction,
      verticalOffset: verticalOffset,
      verticalAxisDirection: verticalDetails.direction,
      mainAxis: mainAxis,
      delegate: delegate as TwoDimensionalChildBuilderDelegate,
      cacheExtent: cacheExtent,
      clipBehavior: clipBehavior,
    );
  }
}

class TwoDimensionalGridViewport extends TwoDimensionalViewport {
  const TwoDimensionalGridViewport({
    super.key,
    required super.verticalOffset,
    required super.verticalAxisDirection,
    required super.horizontalOffset,
    required super.horizontalAxisDirection,
    required TwoDimensionalChildBuilderDelegate super.delegate,
    required super.mainAxis,
    super.cacheExtent,
    super.clipBehavior = Clip.hardEdge,
  });

  @override
  RenderTwoDimensionalViewport createRenderObject(BuildContext context) {
    return RenderTwoDimensionalGridViewport(
      horizontalOffset: horizontalOffset,
      horizontalAxisDirection: horizontalAxisDirection,
      verticalOffset: verticalOffset,
      verticalAxisDirection: verticalAxisDirection,
      mainAxis: mainAxis,
      delegate: delegate as TwoDimensionalChildBuilderDelegate,
      childManager: context as TwoDimensionalChildManager,
      cacheExtent: cacheExtent,
      clipBehavior: clipBehavior,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderTwoDimensionalGridViewport renderObject,
  ) {
    renderObject
      ..horizontalOffset = horizontalOffset
      ..horizontalAxisDirection = horizontalAxisDirection
      ..verticalOffset = verticalOffset
      ..verticalAxisDirection = verticalAxisDirection
      ..mainAxis = mainAxis
      ..delegate = delegate
      ..cacheExtent = cacheExtent
      ..clipBehavior = clipBehavior;
  }
}

class RenderTwoDimensionalGridViewport extends RenderTwoDimensionalViewport {
  RenderTwoDimensionalGridViewport({
    required super.horizontalOffset,
    required super.horizontalAxisDirection,
    required super.verticalOffset,
    required super.verticalAxisDirection,
    required TwoDimensionalChildBuilderDelegate delegate,
    required super.mainAxis,
    required super.childManager,
    super.cacheExtent,
    super.clipBehavior = Clip.hardEdge,
  }) : super(delegate: delegate);

  @override
  void layoutChildSequence() {
    final ChildVicinity vicinity = ChildVicinity(xIndex: 0, yIndex: 0);
    final RenderBox child = buildOrObtainChildFor(vicinity)!;
    double height = child.getMaxIntrinsicHeight(double.maxFinite) + 200;
    double width = child.getMaxIntrinsicWidth(double.maxFinite) + 200;
    //print('$height, $width');
    child.layout(BoxConstraints(minHeight: height, maxHeight: height, minWidth: width, maxWidth: width));
    parentDataOf(child).layoutOffset = Offset(-horizontalOffset.pixels, -verticalOffset.pixels);
    // child.size.height;
    // child.size.width;
    verticalOffset.applyContentDimensions(
      0.0,
      clampDouble(height - viewportDimension.height, 0.0, double.infinity),
    );
    
    horizontalOffset.applyContentDimensions(
      0.0,
      clampDouble(width - viewportDimension.width, 0.0, double.infinity),
    );
  }
  
}
