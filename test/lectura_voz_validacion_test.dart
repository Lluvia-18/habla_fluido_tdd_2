import 'package:flutter_test/flutter_test.dart';
import 'package:habla_fluido/datos/voz_simulada.dart';
import 'package:habla_fluido/dominio/excepciones.dart';
import 'package:habla_fluido/dominio/lectura.dart';
import 'package:habla_fluido/dominio/nivel.dart';
import 'package:habla_fluido/dominio/tutor.dart';

void main() {
  group('Catálogo de lectura', () {
    test('filtra las lecturas según el nivel MCER', () {
      final lecturas = lecturasDeNivel(NivelCefr.a1);
      expect(lecturas, isNotEmpty);
      expect(
          lecturas.every((lectura) => lectura.nivel == NivelCefr.a1), isTrue);
    });

    test('cada pregunta tiene una respuesta válida', () {
      for (final lectura in catalogoLecturas) {
        for (final pregunta in lectura.preguntas) {
          expect(pregunta.correcta,
              inInclusiveRange(0, pregunta.opciones.length - 1));
        }
      }
    });
  });

  group('Voz simulada', () {
    test('registra textos y velocidades pronunciadas', () async {
      final voz = VozSimulada();
      await voz.hablar('Hello', velocidad: .6);
      expect(voz.dichos, ['Hello']);
      expect(voz.velocidades, [.6]);
    });

    test('devuelve respuestas programadas en orden', () async {
      final voz = VozSimulada(['one', 'two']);
      expect(await voz.escuchar(), 'one');
      expect(await voz.escuchar(), 'two');
      expect(await voz.escuchar(), isNull);
      expect(voz.escuchas, 3);
    });
  });

  group('Validación de respuestas del tutor', () {
    test('acepta JSON incluso cuando viene envuelto en texto', () {
      final respuesta = RespuestaTutor.desdeTexto(
        'Resultado: {"respuesta":"Good job","siguientePregunta":"Why?"}',
      );
      expect(respuesta.respuesta, 'Good job');
      expect(respuesta.siguientePregunta, 'Why?');
    });

    test('rechaza respuestas sin JSON válido', () {
      expect(
        () => RespuestaTutor.desdeTexto('respuesta insegura'),
        throwsA(isA<TutorInvalidoException>()),
      );
    });
  });
}
