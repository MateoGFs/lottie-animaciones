import 'package:flutter/material.dart'; //Esta línea importa las herramientas principales de Flutter para construir la interfaz.
import 'package:lottie/lottie.dart'; //paquete lottie para animaciones

void main() { //punto de entrada de una aplicación Dart
  runApp(const MyApp()); //le dice a flutter que MyApp es el widget raíz de la aplicación y que debe ejecutarse.
}

class MyApp extends StatelessWidget { //widget que no necesita manejar un estado que cambie durante su funcionamiento.
  const MyApp({super.key}); //constructor del widget principal.

  @override
  Widget build(BuildContext context) { //build() es la función encargada de describir qué interfaz debe mostrar el widget.
    return MaterialApp(
      debugShowCheckedModeBanner: false, //quita la etiqueta debug de la esquina superior derecha de la aplicación.
      title: 'Lottie Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue), //utiliza azul como color base para generar el esquema de colores.
        useMaterial3: true,
      ),
      home: const LottieDemoPage(), //home indica cuál será la primera pantalla que verá el usuario. en este caso es LottieDemoPage.
    );
  }
}

class LottieDemoPage extends StatefulWidget { //creacion de la pantalla donde esta la demostración. StatefulWidget (porque si cambia durante la ejecución).
  const LottieDemoPage({super.key});

  @override
  State<LottieDemoPage> createState() => _LottieDemoPageState(); //conecta el StatefulWidget con su clase de estado:
}

class _LottieDemoPageState extends State<LottieDemoPage>
    with SingleTickerProviderStateMixin { //Nos permite utilizar la pantalla como proveedor de tiempo (vsync) para un AnimationController.
  late AnimationController _controller; //controlador de la animación. Permite controlas cosas como pausa, reinicio, velocidad, etc.
  late Duration _duracionOriginal; //almacenara la duración original de la animación.
  double _velocidad = 1.0; //velocidad actual
//late (dice que la variable tendra un valor, pero se asignará más adelante, antes de que se use).
  bool _procesando = false; //para la simulacion de procesamiento de información con IA. Indica si el proceso está en curso.
  bool _completado = false; //indica si el proceso ha finalizado.

  Future<void> _procesar() async { // se ejecuta al presionar el botón "Procesar información". future<void> indica que la función es asíncrona y no devuelve ningún valor.
    setState(() {
      _procesando = true;
      _completado = false;
    });

    _controller.repeat(); //hace que la animación se repita mientras se procesa la información.

    await Future.delayed(const Duration(seconds: 4)); //simula un proceso que tarda 4 segundos en completarse.

    _controller.stop(); //se detiene la animacion.
    _controller.value = 1.0; //se pone el controlador al final de la animación.
  

    setState(() {
      _procesando = false;
      _completado = true;
    });
  }

  void _cambiarVelocidad(double nuevaVelocidad) {
    setState(() {
      _velocidad = nuevaVelocidad; //actualiza la velocidad que se ve en pantalla, la que el usuario seleccionó con el slider.
    });

    final posicionActual = _controller.value; //se guarda la posicion actual de la animación, porque no se quiere que al cambiar la velocidad se reinicie la animación desde el principio.

    _controller.stop(); //se detiene temporalmente la animación.

    _controller.duration = Duration(
      milliseconds: (_duracionOriginal.inMilliseconds / _velocidad).round(), //calcula la nueva duración de la animación en función de la velocidad seleccionada.
    ); //ej: si la duracion original es 2000 ms y la velocidad es 2.0, la nueva duración será 1000 ms.

    _controller.value = posicionActual; //se recupera la posición actual de la animación para que continúe desde donde estaba antes de cambiar la velocidad.

    _controller.repeat(); //se reproduce la animación.
  }

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose(); //libera los recursos utilizados por el AnimationController cuando el widget se elimina del árbol de widgets.
    super.dispose();
  }
  //contruccion de la interfaz.
  @override
  Widget build(BuildContext context) {
    return Scaffold( //Scaffold proporciona la estructura básica de una pantalla Flutter.
      appBar: AppBar(title: const Text('Animaciones Lottie')), //Esto crea la barra superior.

      body: Center( //Center centra su hijo en la pantalla.
        child: Column( //Column organiza sus hijos en una columna vertical.
          mainAxisAlignment: MainAxisAlignment.center, //centra los elementos de la columna verticalmente en la pantalla.
          children: [
            const Text(
              'Control de animación Lottie',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ), // muestra el titulo "Control de animación Lottie".

            const SizedBox(height: 20), //separación entre widgets.

            Lottie.asset( //aqui cargamos la animacion lottie
              'assets/animations/loading-success.json',

              controller: _controller, //Esto conecta la animación Lottie con nuestro: AnimationController, permitiendo controlar la animación desde el código.

              onLoaded: (composition) { //composition: representa la composición de la animación cargada. De ella podemos obtener información como su duración.
                _duracionOriginal = composition.duration; //guardamos la duración original.
                _controller.duration = composition.duration; //le decimos al controlador cuanto dura la animacion.
                _controller.repeat();
              },
              //tamaño de la animación.
              width: 250,
              height: 250,
            ),

            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () { // indica qué ocrurre cuando se pulsa.
                    _controller.forward(); //avance la animacion desde la pos actual hasta el final. Si ya está en el final, no hace nada.
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
              onPressed: () { // este boton funciona como: llevar la animación al comienzo y reproducirla desde el principio.
                _controller.reset(); //llevar la animación al comienzo. 
                _controller.forward(); //reproducir.
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Reiniciar'),
            ),

            const SizedBox(height: 20),

            Text(
              'Velocidad: ${_velocidad.toStringAsFixed(1)}x', //se muestra 1 como 1.0. redondea a un decimal.
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),

            Slider(
              value: _velocidad,
              min: 0.5,
              max: 2.0,
              divisions: 6, //divide el rango en varias posiciones seleccionables.
              label: '${_velocidad.toStringAsFixed(1)}x',
              onChanged: (value) {
                _cambiarVelocidad(value); //se le pasa el nuevo valor a la funcion que cambia la velocidad de la animación.
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
