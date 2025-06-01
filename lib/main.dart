import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  bool useCustomPainter = true;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      home: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: SizedBox(
              width: 300, // max allowed width
              child: CountdownAndRestart(
                useCustomPainter: useCustomPainter,
              ),
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            setState(() {
              useCustomPainter = !useCustomPainter;
            });
          },
          label: Text("UseCustomPainter : $useCustomPainter"),
        ),
      ),
    );
  }
}

/// Main demo UI (countdown + restart button)
class CountdownAndRestart extends StatefulWidget {
  const CountdownAndRestart({
    super.key,
    this.useCustomPainter = false,
  });

  final bool useCustomPainter;

  @override
  CountdownAndRestartState createState() => CountdownAndRestartState();
}

class CountdownAndRestartState extends State<CountdownAndRestart>
    with TickerProviderStateMixin {
  static const maxWidth = 300.0;
  static const int _maxCounter = 10000000;

  Duration _elapsed = Duration.zero;
  late final Ticker _ticker;

  int _counter = 0;

  int _cachedCounter = 0;
  bool _paused = false;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker((elapsed) {
      setState(() {
        _elapsed = elapsed;
        _counter = _elapsed.inMicroseconds + _cachedCounter;
      });
      if (_counter > _maxCounter) {
        _ticker.stop();
      }
    });
    _ticker.start();
  }

  void resetTimer() {
    _ticker.stop();
    setState(() {
      _counter = 0;
      _cachedCounter = 0;
      _paused = false;
    });
    _ticker.start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void onPaused() {
    _ticker.stop();
    _paused = true;
    _cachedCounter = _counter;
  }

  void onResumed() {
    _paused = false;
    _ticker.start();
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 4 / 5,
      child: Stack(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              widget.useCustomPainter
                  ? TimerCircleWidgetUseCustomPainter(value: _indicatorValue)
                  : TimerCircleWidget(value: _indicatorValue),
              Text(
                _counterValue,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 120,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ],
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: ElevatedButton(
              onPressed: () {
                _paused ? onResumed() : onPaused();
              },
              child: Text(
                _paused ? "Resume" : "Pause",
                style: const TextStyle(fontSize: 28),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: ElevatedButton(
              onPressed: () {
                resetTimer();
              },
              child: const Text(
                'Restart',
                style: TextStyle(fontSize: 28),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String get _counterValue {
    return _counter > _maxCounter
        ? "0"
        : ((_maxCounter - _counter) / 1000000).ceil().toString();
  }

  double get _indicatorValue =>
      _counter > _maxCounter ? 0 : 1 - (_counter / _maxCounter);
}

class TimerCircleWidget extends StatelessWidget {
  const TimerCircleWidget({
    super.key,
    required this.value,
  });

  final double value;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: 300,
      child: CircularProgressIndicator(
        value: value,
        strokeWidth: 20,
        strokeCap: StrokeCap.round,
        valueColor: AlwaysStoppedAnimation(Theme.of(context).primaryColor),
        backgroundColor: Theme.of(context).focusColor,
      ),
    );
  }
}

class TimerCircleWidgetUseCustomPainter extends StatelessWidget {
  const TimerCircleWidgetUseCustomPainter({
    super.key,
    required this.value,
  });

  final double value;

  static const _baseColor = Colors.lightGreen;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: 300,
      child: CustomPaint(
        painter: TimerCirclePainter(
          baseColor: _baseColor,
          value: value,
        ),
      ),
    );
  }
}

class TimerCirclePainter extends CustomPainter {
  final Color _baseColor;
  final double _value;

  TimerCirclePainter({
    super.repaint,
    required Color baseColor,
    required double value,
  })  : _baseColor = baseColor,
        _value = value;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = _baseColor
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 20
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..addArc(
        Rect.fromLTRB(0, 0, size.width, size.height),
        3 * math.pi / 2,
        2 * math.pi * _value,
      );

    canvas.drawPath(path, paint);

    paint.color = _baseColor.withAlpha(100);

    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      size.height / 2,
      paint,
    );
  }

  @override
  bool shouldRepaint(TimerCirclePainter oldDelegate) =>
      oldDelegate._value != _value;

  @override
  bool shouldRebuildSemantics(TimerCirclePainter oldDelegate) => false;
}
