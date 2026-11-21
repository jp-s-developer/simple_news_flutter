
import 'package:flutter/material.dart';

class AutoScrollText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final double speed;

  const AutoScrollText({
    super.key,
    required this.text,
    this.style,
    this.speed = 40,
  });

  @override
  State<AutoScrollText> createState() => _AutoScrollTextState();
}

class _AutoScrollTextState extends State<AutoScrollText>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  double textWidth = 0;
  double containerWidth = 0;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    );

    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final style = widget.style ??
            Theme.of(context).textTheme.titleMedium;

        final painter = TextPainter(
          text: TextSpan(
            text: widget.text,
            style: style,
          ),
          maxLines: 1,
          textDirection: Directionality.of(context),
        )..layout();

        textWidth = painter.width;
        containerWidth = constraints.maxWidth;

        if (textWidth <= containerWidth) {
          return SizedBox(
            width: containerWidth,
            child: Text(
              widget.text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: style,
            ),
          );
        }

        const gap = 40.0;
        final distance = textWidth + gap;

        final duration = Duration(
          milliseconds:
          (distance / widget.speed * 1000).round(),
        );

        if (_controller.duration != duration) {
          _controller.duration = duration;
        }

        return ClipRect(
          child: SizedBox(
            width: containerWidth,
            height: painter.height + 4,
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                final offset = -distance * _controller.value;

                return Stack(
                  clipBehavior: Clip.hardEdge,
                  children: [
                    Positioned(
                      left: offset,
                      top: 0,
                      child: child!,
                    ),
                    Positioned(
                      left: offset + distance,
                      top: 0,
                      child: child,
                    ),
                  ],
                );
              },
              child: Text(
                widget.text,
                maxLines: 1,
                softWrap: false,
                style: style,
              ),
            ),
          ),
        );
      },
    );
  }
}
