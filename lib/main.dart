import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      home: const Scaffold(
        body: Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(
            child: SizedBox(
              width: 300, // max allowed width
              child: CountdownAndRestart(),
            ),
          ),
        ),
      ),
    );
  }
}

/// Main demo UI (countdown + restart button)
class CountdownAndRestart extends StatefulWidget {
  const CountdownAndRestart({super.key});

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
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            TimerCircleWidget(
              value: _value,
            ),
            Text(
              _counter > _maxCounter
                  ? "0"
                  : ((_maxCounter - _counter) / 1000000).ceil().toString(),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 120,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            ElevatedButton(
              onPressed: () {
                _paused ? onResumed() : onPaused();
              },
              child: Text(
                _paused ? "Resume" : "Pause",
                style: const TextStyle(fontSize: 28),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () {
                resetTimer();
              },
              child: const Text(
                'Restart',
                style: TextStyle(fontSize: 28),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  double get _value =>
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
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox.square(
            dimension: 300,
            child: CircularProgressIndicator(
              value: value,
              strokeWidth: 20,
              strokeCap: StrokeCap.round,
              strokeAlign: CircularProgressIndicator.strokeAlignInside,
              color: Theme.of(context).primaryColor,
            ),
          ),
          SizedBox.square(
            dimension: 300,
            child: CircularProgressIndicator(
              value: 100,
              strokeWidth: 20,
              strokeCap: StrokeCap.round,
              strokeAlign: CircularProgressIndicator.strokeAlignInside,
              color: Theme.of(context).primaryColor.withAlpha(200),
            ),
          ),
        ],
      ),
    );
  }
}
