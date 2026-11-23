import 'package:flutter_test/flutter_test.dart';
import 'package:habla_fluido/dominio/nivel.dart';
import 'package:habla_fluido/dominio/plan_diario.dart';
import 'package:habla_fluido/dominio/progreso.dart';
import 'package:habla_fluido/dominio/reglas.dart';

void main() {
  group('Progreso y plan diario', () {
    test('inicia en A1 con dominio neutral', () {
      final progreso = Progreso();
      expect(progreso.nivel, NivelCefr.a1);
      expect(progreso.dominioDe(Habilidad.escucha), Reglas.dominioSinEvaluar);
    });

    test('actualiza el dominio con promedio móvil y limita el puntaje', () {
      final progreso = Progreso();
      final hoy = DateTime(2026, 11, 22);
      progreso.registrar(Habilidad.escucha, 2, hoy);
      progreso.registrar(Habilidad.escucha, 0, hoy);
      expect(progreso.de(Habilidad.escucha)!.intentos, 2);
      expect(progreso.dominioDe(Habilidad.escucha),
          closeTo(1 - Reglas.pesoUltimoIntento, 0.0001));
    });

    test('calcula la racha por días consecutivos', () {
      final progreso = Progreso();
      progreso.registrar(Habilidad.lectura, .7, DateTime(2026, 11, 20));
      progreso.registrar(Habilidad.lectura, .8, DateTime(2026, 11, 21));
      progreso.registrar(Habilidad.lectura, .9, DateTime(2026, 11, 21));
      expect(progreso.racha, 2);
      progreso.registrar(Habilidad.lectura, .9, DateTime(2026, 11, 24));
      expect(progreso.racha, 1);
    });

    test('reparte exactamente veinte minutos y refuerza una habilidad', () {
      final plan = generarPlan(Progreso());
      expect(plan, hasLength(Habilidad.values.length));
      expect(plan.fold<int>(0, (suma, bloque) => suma + bloque.minutos), 20);
      expect(plan.where((bloque) => bloque.esRefuerzo), hasLength(1));
    });

    test('serializa y restaura el avance', () {
      final progreso = Progreso();
      progreso.registrar(Habilidad.escritura, .85, DateTime(2026, 11, 22));
      final copia = Progreso.desdeJson(progreso.aJson());
      expect(copia.dominioDe(Habilidad.escritura), .85);
      expect(copia.racha, 1);
    });

    test('sube de nivel al cumplir los intentos y reinicia habilidades', () {
      final progreso = Progreso();
      for (final habilidad in Habilidad.values) {
        for (var i = 0; i < Reglas.intentosParaSubir; i++) {
          progreso.registrar(habilidad, 1, DateTime(2026, 11, 22));
        }
      }
      expect(progreso.puedeSubirDeNivel, isTrue);
      expect(progreso.subirDeNivel(), isTrue);
      expect(progreso.nivel, NivelCefr.a2);
      expect(progreso.de(Habilidad.escucha), isNull);
    });
  });
}
