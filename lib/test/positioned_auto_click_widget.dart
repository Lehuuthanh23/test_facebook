import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class PositionedAutoClickWidget extends StatefulWidget {
  final double size;
  /// The location of the point is clicked inside the child
  final Offset position;

  /// When the value is set to true, the click action will be performed at the position
  final ValueNotifier<bool> clickNotifier;

  const PositionedAutoClickWidget({
    super.key,
    required this.position,
    this.size = 1,
    required this.clickNotifier,
  });

  @override
  State<PositionedAutoClickWidget> createState() =>
      _PositionedAutoClickWidgetState();
}

class _PositionedAutoClickWidgetState extends State<PositionedAutoClickWidget> {
  @override
  void initState() {
    widget.clickNotifier.addListener(_onClickNotifierListener);

    super.initState();
  }

  @override
  void dispose() {
    widget.clickNotifier.removeListener(_onClickNotifierListener);

    super.dispose();
  }

  void _onClickNotifierListener() {
    if (widget.clickNotifier.value) {
      _simulateClick();
      widget.clickNotifier.value = false;
    }
  }

  void _simulateClick() {
    if (context.mounted) {
      final clickPosition = Offset(widget.position.dx + widget.size / 2,
          widget.position.dy + widget.size / 2);

      GestureBinding.instance.handlePointerEvent(PointerDownEvent(
        position: clickPosition,
      ));

      Future.delayed(const Duration(milliseconds: 50), () {
        GestureBinding.instance.handlePointerEvent(PointerUpEvent(
          position: clickPosition,
        ));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: widget.position.dx - widget.size / 2,
      top: widget.position.dy - widget.size / 2,
      child: ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(widget.size / 2)),
        child: Container(
          //color: Colors.red.withOpacity(0.6),
          width: widget.size,
          height: widget.size,
          child: Center(
            child: ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(widget.size * 0.1)),
              child: Container(
                width: widget.size * 0.2,
                height: widget.size * 0.2,
                color: Colors.black.withOpacity(0.7),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
