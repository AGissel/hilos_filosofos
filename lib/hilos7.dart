import 'dart:async';
import 'dart:math';
import 'dart:isolate';

class Filosofo {
  int numero;
  String nombre;
  int cantidadComida;
  Tenedor tenedorIzquierdo;
  Tenedor tenedorDerecho;

  Filosofo(this.numero, this.nombre, this.cantidadComida, this.tenedorIzquierdo, this.tenedorDerecho);

  Future<void> run(dynamic _) async {
    while (cantidadComida > 0) {
      print('$nombre está pensando...');
      await Future.delayed(Duration(milliseconds: Random().nextInt(1000)));
      await tenedorIzquierdo.acquire();
      print('$nombre tiene el tenedor izquierdo.');
      await tenedorDerecho.acquire();
      print('$nombre tiene ambos tenedores y va a comer.');

      while (cantidadComida > 0) {
        await Future.delayed(Duration(milliseconds: 500));
        if (tenedorIzquierdo.disponible && tenedorDerecho.disponible) {
          tenedorIzquierdo.disponible = false;
          tenedorDerecho.disponible = false;
          cantidadComida--;
          print('$nombre comió un bocado.');
        } else {
          print('$nombre no puede comer.');
        }
      }

      tenedorIzquierdo.release();
      tenedorDerecho.release();
      print('$nombre ha terminado de comer y ha liberado ambos tenedores.');
    }
  }
}

class Tenedor {
  int numero;
  bool disponible;

  Tenedor(this.numero, this.disponible);

  final _completer = Completer();

  Future<void> acquire() async {
    if (!disponible) {
      await _completer.future;
    }
    disponible = false;
  }

  void release() {
    disponible = true;
    _completer.complete();
  }
}

void main() {
  final n = 5; // número de filósofos y tenedores
  final tenedores = List.generate(n, (i) => Tenedor(i, true));
  final filosofos = List.generate(n, (i) {
    final nombre = 'Filósofo $i';
    final cantidadComida = Random().nextInt(10) + 1;
    final tenedorIzquierdo = tenedores[i];
    final tenedorDerecho = tenedores[(i + 1) % n];
    return Filosofo(i, nombre, cantidadComida, tenedorIzquierdo, tenedorDerecho);
  });

 for (var filosofo in filosofos) {
   Isolate.spawn(filosofo.run, "filosofo_isolate");
 }

}
