import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/providers.dart';
import '../theme/app_theme.dart';
import '../widgets/buttons.dart';
import '../widgets/grilo_icons.dart';
import 'cadastros_screen.dart';
import 'calculadora_screen.dart';
import 'historico_screen.dart';

const _mobileBreakpoint = 760.0;

String _resolveUserName(User? user) {
  if (user == null) return 'Usuário';
  final displayName = user.displayName?.trim();
  if (displayName != null && displayName.isNotEmpty) return displayName;
  final email = user.email?.trim();
  if (email != null && email.contains('@')) return email.split('@').first;
  if (email != null && email.isNotEmpty) return email;
  return 'Usuário';
}

String _resolveUserEmail(User? user) {
  final email = user?.email?.trim();
  if (email != null && email.isNotEmpty) return email;
  return 'Sem e-mail';
}

String _resolveUserInitials(User? user) {
  final parts = _resolveUserName(user).split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
  if (parts.isEmpty) return 'U';
  if (parts.length == 1) {
    final one = parts.first;
    return one.length >= 2 ? one.substring(0, 2).toUpperCase() : one.substring(0, 1).toUpperCase();
  }
  return (parts[0][0] + parts[1][0]).toUpperCase();
}

class AppShell extends ConsumerWidget {
  const AppShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.gc;
    final isMobile = MediaQuery.sizeOf(context).width < _mobileBreakpoint;

    return Scaffold(
      backgroundColor: c.bg,
      drawer: isMobile
          ? Drawer(
              backgroundColor: Colors.transparent,
              width: 248,
              child: const _Sidebar(),
            )
          : null,
      body: SafeArea(
        child: Stack(
          children: [
            Row(
              children: [
                if (!isMobile) const _Sidebar(),
                Expanded(
                  child: Column(
                    children: [
                      _Topbar(isMobile: isMobile),
                      const Expanded(child: _Content()),
                    ],
                  ),
                ),
              ],
            ),
            const _ToastOverlay(),
          ],
        ),
      ),
    );
  }
}

class _Sidebar extends ConsumerWidget {
  const _Sidebar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.gc;
    final route = ref.watch(routeProvider);
    final themeMode = ref.watch(themeModeProvider);
    final user = ref.watch(authStateChangesProvider).asData?.value;
    final userName = _resolveUserName(user);
    final userEmail = _resolveUserEmail(user);
    final userInitials = _resolveUserInitials(user);
    final isMobile = MediaQuery.sizeOf(context).width < _mobileBreakpoint;

    Widget navItem(AppRoute r, String label, IconData icon) {
      final on = route == r;
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 1.5),
        child: Material(
          color: on ? c.accentSoft : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: () {
              ref.read(routeProvider.notifier).set(r);
              if (isMobile) Navigator.of(context).maybePop();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: on ? Border.all(color: c.accent.withValues(alpha: .22)) : Border.all(color: Colors.transparent),
              ),
              child: Row(
                children: [
                  Icon(icon, size: 19, color: on ? c.accentTx : c.tx3),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Text(
                      label,
                      maxLines: 2,
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: on ? c.accentTx : c.tx2),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    Widget navLabel(String label) => Padding(
          padding: const EdgeInsets.fromLTRB(10, 16, 10, 7),
          child: Text(
            label.toUpperCase(),
            style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, letterSpacing: .94, color: c.tx3),
          ),
        );

    Widget themeButton(String label, IconData icon, ThemeMode mode) {
      final on = themeMode == mode;
      return Expanded(
        child: Material(
          color: on ? c.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () => ref.read(themeModeProvider.notifier).set(mode),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 7),
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), boxShadow: on ? c.shadow : null),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 15, color: on ? c.tx : c.tx2),
                  const SizedBox(width: 6),
                  Text(label, style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: on ? c.tx : c.tx2)),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      width: 248,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
      decoration: BoxDecoration(
        border: Border(right: BorderSide(color: c.line)),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [c.surface, Color.lerp(c.surface, c.bg, .14)!],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 6, 8, 16),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(11),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [c.accent, c.accent2],
                    ),
                    boxShadow: [BoxShadow(color: c.accent.withValues(alpha: .4), blurRadius: 16, offset: const Offset(0, 6), spreadRadius: -6)],
                  ),
                  alignment: Alignment.center,
                  child: const GriloCubeIcon(size: 20, color: Colors.white),
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Grilo', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 19, letterSpacing: -.38, color: c.tx, height: 1)),
                      const SizedBox(height: 3),
                      Text('Custos de artesanato', style: TextStyle(fontSize: 11, color: c.tx3, letterSpacing: .11), overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
              ],
            ),
          ),
          navLabel('Trabalho'),
          navItem(AppRoute.calc, 'Calculadora', Icons.calculate_outlined),
          navItem(AppRoute.hist, 'Histórico & Dashboard', Icons.bar_chart_outlined),
          navLabel('Configuração'),
          navItem(AppRoute.cad, 'Cadastros', Icons.inventory_2_outlined),
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(color: c.chip, borderRadius: BorderRadius.circular(11)),
            child: Row(
              children: [
                themeButton('Claro', Icons.light_mode_outlined, ThemeMode.light),
                themeButton('Escuro', Icons.dark_mode_outlined, ThemeMode.dark),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(11), border: Border.all(color: c.line)),
            child: Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: c.surface2, borderRadius: BorderRadius.circular(9)),
                  child: Text(userInitials, style: TextStyle(color: c.accent, fontWeight: FontWeight.w700, fontSize: 13)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(userName, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: c.tx), overflow: TextOverflow.ellipsis),
                      Text(userEmail, style: TextStyle(fontSize: 11, color: c.tx3), overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

const _titles = <AppRoute, (String, String)>{
  AppRoute.calc: ('Calculadora', 'Selecione o motor e siga os passos para precificar sua peça.'),
  AppRoute.hist: ('Histórico & Dashboard', 'Acompanhe orçamentos, custos e margens.'),
  AppRoute.cad: ('Cadastros', 'Materiais, máquinas e configurações fixas — compartilhados entre os motores.'),
};

class _Topbar extends ConsumerWidget {
  const _Topbar({required this.isMobile});

  final bool isMobile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.gc;
    final route = ref.watch(routeProvider);
    final user = ref.watch(authStateChangesProvider).asData?.value;
    final userName = _resolveUserName(user);
    final userInitials = _resolveUserInitials(user);
    final (title, subtitle) = _titles[route]!;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 18 : 30, vertical: isMobile ? 14 : 18),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: c.line))),
      child: Row(
        children: [
          if (isMobile) ...[
            GriloIconButton(icon: Icons.menu, onPressed: () => Scaffold.of(context).openDrawer()),
            const SizedBox(width: 14),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(title, style: TextStyle(fontSize: 21, fontWeight: FontWeight.w700, letterSpacing: -.42, color: c.tx)),
                const SizedBox(height: 2),
                Text(subtitle, style: TextStyle(fontSize: 13, color: c.tx2), maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          if (!isMobile)
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Tooltip(
                message: userName,
                waitDuration: const Duration(milliseconds: 250),
                child: Row(
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(color: c.surface2, borderRadius: BorderRadius.circular(9)),
                      child: Text(userInitials, style: TextStyle(color: c.accent, fontWeight: FontWeight.w700, fontSize: 12)),
                    ),
                    const SizedBox(width: 8),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 180),
                      child: Text(
                        userName,
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: c.tx2),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (route != AppRoute.calc) ...[
            const SizedBox(width: 10),
            GriloButton(
              label: 'Novo orçamento',
              icon: Icons.add,
              variant: GriloButtonVariant.primary,
              hideLabelOnNarrow: isMobile,
              onPressed: () => ref.read(routeProvider.notifier).set(AppRoute.calc),
            ),
          ],
          const SizedBox(width: 10),
          GriloIconButton(
            icon: Icons.logout,
            onPressed: () async {
              await ref.read(firebaseAuthProvider).signOut();
            },
          ),
        ],
      ),
    );
  }
}

class _Content extends ConsumerWidget {
  const _Content();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final route = ref.watch(routeProvider);
    final isMobile = MediaQuery.sizeOf(context).width < _mobileBreakpoint;

    final body = switch (route) {
      AppRoute.calc => const CalculadoraScreen(),
      AppRoute.hist => const HistoricoScreen(),
      AppRoute.cad => const CadastrosScreen(),
    };

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        isMobile ? 18 : 30,
        26,
        isMobile ? 18 : 30,
        60,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1080),
          child: body,
        ),
      ),
    );
  }
}

class _ToastOverlay extends ConsumerWidget {
  const _ToastOverlay();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.gc;
    final toast = ref.watch(toastProvider);
    if (toast == null) return const SizedBox.shrink();

    return Positioned(
      bottom: 24,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
          decoration: BoxDecoration(
            color: c.elev,
            border: Border.all(color: c.line2),
            borderRadius: BorderRadius.circular(GriloRadius.md),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: .5), blurRadius: 40, offset: const Offset(0, 20), spreadRadius: -16)],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle_outline, size: 18, color: c.good),
              const SizedBox(width: 10),
              Text(toast, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: c.tx)),
            ],
          ),
        ),
      ),
    );
  }
}
