import 'package:flutter_test/flutter_test.dart';
import 'package:habla_fluido/datos/tutor_simulado.dart';
import 'package:habla_fluido/dominio/almacen.dart';
import 'package:habla_fluido/dominio/frase.dart';
import 'package:habla_fluido/dominio/nivel.dart';
import 'package:habla_fluido/dominio/tutor.dart';
import 'package:habla_fluido/presentacion/vm/aprendizaje_vm.dart';

class AlmacenMemoria implements AlmacenAvance {
  Map<String, Object?>? datos;

  @override
  Future<Map<String, Object?>?> cargar() async => datos;

  @override
  Future<void> guardar(Map<String, Object?> datos) async => this.datos = datos;
}

void main() {
  group('Tutor y aprendizaje', () {
    test('el tutor corrige reglas frecuentes de inglés', () async {
      final respuesta = await TutorSimulado()
          .corregir(nivel: NivelCefr.a1, texto: 'i am agree');
      expect(respuesta.correcciones, isNotEmpty);
      expect(respuesta.textoCorregido, contains('I agree'));
    });

    test('la conversación devuelve ánimo y una nueva pregunta', () async {
      final respuesta = await TutorSimulado().conversar(
        nivel: NivelCefr.a1,
        historial: const [Mensaje(true, 'I live in Dolores Hidalgo')],
      );
      expect(respuesta.respuesta, isNotEmpty);
      expect(respuesta.siguientePregunta, isNotEmpty);
    });

    test('registrar un intento guarda progreso y crea una tarjeta', () async {
      final almacen = AlmacenMemoria();
      final vm =
          AprendizajeViewModel(almacen, reloj: () => DateTime(2026, 11, 22));
      await vm.registrarIntento(Habilidad.pronunciacion, .9,
          frase: catalogoFrases.first);
      expect(vm.progreso.de(Habilidad.pronunciacion)!.intentos, 1);
      expect(vm.mazo.todas, hasLength(1));
      expect(almacen.datos, isNotNull);
    });

    test('carga el avance previamente almacenado', () async {
      final almacen = AlmacenMemoria();
      final primero =
          AprendizajeViewModel(almacen, reloj: () => DateTime(2026, 11, 22));
      await primero.registrarIntento(Habilidad.lectura, .8);
      final segundo = AprendizajeViewModel(almacen);
      await segundo.cargar();
      expect(segundo.progreso.dominioDe(Habilidad.lectura), .8);
    });
  });
}
