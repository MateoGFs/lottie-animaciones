import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Lottie Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const LottieDemoPage(),
    );
  }
}

class LottieDemoPage extends StatefulWidget {
  const LottieDemoPage({super.key});

  @override
  State<LottieDemoPage> createState() => _LottieDemoPageState();
}

class _LottieDemoPageState extends State<LottieDemoPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Duration _duracionOriginal;
  double _velocidad = 1.0;

  bool _procesando = false;
  bool _completado = false;
  Future<void> _procesar() async {
    setState(() {
      _procesando = true;
      _completado = false;
    });

    _controller.repeat();

    await Future.delayed(const Duration(seconds: 4));

    _controller.stop();
    _controller.value = 1.0;

    setState(() {
      _procesando = false;
      _completado = true;
    });
  }

  void _cambiarVelocidad(double nuevaVelocidad) {
    setState(() {
      _velocidad = nuevaVelocidad;
    });

    final posicionActual = _controller.value;

    _controller.stop();

    _controller.duration = Duration(
      milliseconds: (_duracionOriginal.inMilliseconds / _velocidad).round(),
    );

    _controller.value = posicionActual;

    _controller.repeat();
  }

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Animaciones Lottie')),

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Control de animación Lottie',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            Lottie.asset(
              'assets/animations/loading-success.json',

              controller: _controller,

              onLoaded: (composition) {
                _duracionOriginal = composition.duration;
                _controller.duration = composition.duration;
                _controller.repeat();
              },

              width: 250,
              height: 250,
            ),

            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    _controller.forward();
                  },
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Reproducir'),
                ),

                const SizedBox(width: 10),

                ElevatedButton.icon(
                  onPressed: () {
                    _controller.stop();
                  },
                  icon: const Icon(Icons.pause),
                  label: const Text('Pausar'),
                ),
              ],
            ),

            const SizedBox(height: 10),

            ElevatedButton.icon(
              onPressed: () {
                _controller.reset();
                _controller.forward();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Reiniciar'),
            ),

            const SizedBox(height: 20),

            Text(
              'Velocidad: ${_velocidad.toStringAsFixed(1)}x',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),

            Slider(
              value: _velocidad,
              min: 0.5,
              max: 2.0,
              divisions: 6,
              label: '${_velocidad.toStringAsFixed(1)}x',
              onChanged: (value) {
                _cambiarVelocidad(value);
              },
            ),

            const Text(
              '🤖 Procesamiento con IA',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            Text(
              _procesando
                  ? 'Analizando información...'
                  : _completado
                  ? 'Proceso completado ✓'
                  : 'Listo para procesar',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),

            ElevatedButton.icon(
              onPressed: _procesando ? null : _procesar,
              icon: const Icon(Icons.auto_awesome),
              label: const Text('Procesar información'),
            ),
          ],
        ),
      ),
    );
  }
}
