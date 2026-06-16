import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/seed_data.dart';
import '../models/models.dart';

// ── Materiais ───────────────────────────────────────────────────────────────

class MateriaisNotifier extends Notifier<List<MaterialItem>> {
  @override
  List<MaterialItem> build() => seedMateriais;

  void salvar(MaterialItem mat, {String? originalId}) {
    if (originalId != null) {
      state = [for (final m in state) if (m.id == originalId) mat else m];
    } else {
      state = [mat, ...state];
    }
  }

  void remover(String id) => state = state.where((m) => m.id != id).toList();
}

final materiaisProvider = NotifierProvider<MateriaisNotifier, List<MaterialItem>>(MateriaisNotifier.new);

// ── Máquinas ────────────────────────────────────────────────────────────────

class MaquinasNotifier extends Notifier<List<Maquina>> {
  @override
  List<Maquina> build() => seedMaquinas;

  void salvar(Maquina mq, {String? originalId}) {
    if (originalId != null) {
      state = [for (final m in state) if (m.id == originalId) mq else m];
    } else {
      state = [...state, mq];
    }
  }

  void remover(String id) => state = state.where((m) => m.id != id).toList();
}

final maquinasProvider = NotifierProvider<MaquinasNotifier, List<Maquina>>(MaquinasNotifier.new);

// ── Configurações ───────────────────────────────────────────────────────────

class ConfigNotifier extends Notifier<AppConfig> {
  @override
  AppConfig build() => seedConfig;

  void update(AppConfig Function(AppConfig) updater) => state = updater(state);
}

final configProvider = NotifierProvider<ConfigNotifier, AppConfig>(ConfigNotifier.new);

// ── Histórico de orçamentos ─────────────────────────────────────────────────

class OrdensNotifier extends Notifier<List<Ordem>> {
  @override
  List<Ordem> build() => seedOrdens;

  void adicionar(Ordem o) => state = [o, ...state];
}

final ordensProvider = NotifierProvider<OrdensNotifier, List<Ordem>>(OrdensNotifier.new);

// ── Tema ────────────────────────────────────────────────────────────────────

class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() => ThemeMode.dark;

  void set(ThemeMode mode) => state = mode;
}

final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(ThemeModeNotifier.new);

// ── Navegação ───────────────────────────────────────────────────────────────

enum AppRoute { calc, hist, cad }

class RouteNotifier extends Notifier<AppRoute> {
  @override
  AppRoute build() => AppRoute.calc;

  void set(AppRoute r) => state = r;
}

final routeProvider = NotifierProvider<RouteNotifier, AppRoute>(RouteNotifier.new);

// ── Toast ───────────────────────────────────────────────────────────────────

class ToastNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void show(String message) {
    state = message;
    Future.delayed(const Duration(milliseconds: 2600), () {
      if (state == message) state = null;
    });
  }
}

final toastProvider = NotifierProvider<ToastNotifier, String?>(ToastNotifier.new);

// ── Firebase Auth ───────────────────────────────────────────────────────────

final firebaseAuthProvider = Provider<FirebaseAuth>((ref) => FirebaseAuth.instance);

final authStateChangesProvider = StreamProvider<User?>((ref) {
  return ref.watch(firebaseAuthProvider).authStateChanges();
});
