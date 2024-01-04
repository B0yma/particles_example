import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  final onCounterChanged = ValueNotifier(0);

  void _incrementCounter() {
    setState(() {
      _counter++;
      onCounterChanged.value = _counter;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: const ParticleSystemWithEmitters(),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class ParticleSystemWithEmitters extends StatefulWidget {
  const ParticleSystemWithEmitters({Key? key}) : super(key: key);

  @override
  State<ParticleSystemWithEmitters> createState() => _ParticleSystemWithEmittersState();
}

class _ParticleSystemWithEmittersState extends State<ParticleSystemWithEmitters> with SingleTickerProviderStateMixin {
  late List<Emitter> emitters;
  late Ticker _ticker;

  @override
  void initState() {
    super.initState();
    emitters = List.empty(growable: true);
    _ticker = createTicker((elapsed) {
      setState(() {});
    });
    _ticker.start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Tap on the screen to display Particles'),
      ),
      body: GestureDetector(
        onTapDown: (details) {
          emitters.add(Emitter(position: details.localPosition));
        },
        onPanUpdate: (details){
          emitters.add(Emitter(position: details.localPosition));
        },
        child: SizedBox(
          height: size.height,
          width: size.width,
          child: CustomPaint(
            painter: _ParticlePainter(
              emitters: emitters,
            ),
          ),
        ),
      ),
    );
  }
}

class _ParticlePainter extends CustomPainter {
  final List<Emitter> emitters;
  final maxEmitters = 3;

  _ParticlePainter({
    required this.emitters,
  });

  @override
  void paint(Canvas canvas, Size size) {
    emitters.removeWhere((element) => element.particles[0].finished());
    for (int i = 0; i < emitters.length; i++) {
      final emitter = emitters[i];
      emitter.update();
      for (var particle in emitter.particles) {
        particle.update();
        canvas.drawCircle(
          Offset(particle.x, particle.y),
          doubleInRange(0, 5),
          Paint()
            ..color = Color.fromARGB(
              particle.alpha,
              255,
              255,
              255,
            ),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class Particle {
  double x, y;
  double vx = doubleInRange(-1, 1);
  double vy = doubleInRange(-1, 1);
  int alpha = 255;

  Particle({
    required this.x,
    required this.y,
  });

  update() {
    x += vx;
    y += vy;
    alpha -= 15;
  }

  bool finished() {
    return alpha <= 0;
  }
}

class Emitter {
  final Offset position;
  List<Particle> particles;
  List<Particle> particlesToRemove = List.empty(growable: true);

  Emitter({required this.position})
      : particles = List.generate(
          1,
          (index) => Particle(
            x: position.dx,
            y: position.dy,
          ),
        );

  update() {
    //particles.add(Particle(x: position.dx, y: position.dy));
    for (var particle in particles) {
      if (particle.finished()) particlesToRemove.add(particle);
    }

    for (var particle in particlesToRemove) {
      particles.remove(particle);
    }
  }
}

double doubleInRange(num start, num end) => _random.nextDouble() * (end - start) + start;

Random _random = Random();
