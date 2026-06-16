import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/models.dart';
import '../providers/providers.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';
import '../widgets/badges.dart';
import '../widgets/buttons.dart';
import '../widgets/charts.dart';
import '../widgets/grilo_icons.dart';
import '../widgets/surfaces.dart';

Ordem? _findOrdem(List<Ordem> ordens, String? id) {
  for (final o in ordens) {
    if (o.id == id) return o;
  }
  return null;
}

class HistoricoScreen extends ConsumerStatefulWidget {
  const HistoricoScreen({super.key});

  @override
  ConsumerState<HistoricoScreen> createState() => _HistoricoScreenState();
}

class _HistoricoScreenState extends ConsumerState<HistoricoScreen> {
  String? _selId;
  CraftEngineId? _kpiFilt;

  @override
  Widget build(BuildContext context) {
    final ordens = ref.watch(ordensProvider);

    final order = _findOrdem(ordens, _selId) ?? (ordens.isNotEmpty ? ordens.first : null);

    final filtered = _kpiFilt == null ? ordens : ordens.where((o) => o.engine == _kpiFilt).toList();
    final totFat = filtered.fold<double>(0, (a, o) => a + o.preco);
    final totLucro = filtered.fold<double>(0, (a, o) => a + o.lucro);
    final totCusto = filtered.fold<double>(0, (a, o) => a + o.custo);
    final margMedia = totCusto > 0 ? totLucro / totCusto * 100 : 0.0;

    final bdData = order == null
        ? <(String, double, Color)>[]
        : [
            for (final e in order.breakdown.entries)
              if (e.value > 0) (e.key, e.value, breakdownColors[e.key] ?? const Color(0xFF9AA0A8)),
          ];

    final width = MediaQuery.sizeOf(context).width;
    final statCols = width < 820 ? 2 : 4;
    final stackedDash = width < 980;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: SegmentedControl<CraftEngineId?>(
            value: _kpiFilt,
            compact: true,
            onChanged: (v) => setState(() => _kpiFilt = v),
            options: [
              (null, 'Todos', null),
              (
                CraftEngineId.print3d,
                'Impressão 3D',
                (on) => Container(width: 8, height: 8, decoration: BoxDecoration(color: dotPrint3d, borderRadius: BorderRadius.circular(3))),
              ),
              (
                CraftEngineId.croche,
                'Crochê',
                (on) => Container(width: 8, height: 8, decoration: BoxDecoration(color: dotCroche, borderRadius: BorderRadius.circular(3))),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        GridView.count(
          crossAxisCount: statCols,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.55,
          children: [
            StatTile(
              icon: Icons.sell_outlined,
              label: 'Orçamentos',
              value: '${filtered.length}',
              delta: _kpiFilt == null ? 'todos os motores' : _kpiFilt!.nome,
            ),
            StatTile(
              icon: Icons.trending_up,
              label: 'Faturamento potencial',
              value: fmtBRL(totFat),
              delta: '+18% vs. abr',
              deltaUp: true,
            ),
            StatTile(
              icon: Icons.bolt_outlined,
              label: 'Lucro projetado',
              value: fmtBRL(totLucro),
              delta: '+12% vs. abr',
              deltaUp: true,
            ),
            StatTile(
              icon: Icons.layers_outlined,
              label: 'Margem média',
              value: '${fmtNum(margMedia)}%',
              delta: 'markup médio',
            ),
          ],
        ),
        const SizedBox(height: 22),
        if (stackedDash)
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _OrdersCard(ordens: ordens, selId: order?.id, onSelect: (id) => setState(() => _selId = id), onQuote: _showQuote),
              const SizedBox(height: 22),
              _CompositionCard(order: order, bdData: bdData, onQuote: _showQuote),
            ],
          )
        else
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 14,
                child: _OrdersCard(ordens: ordens, selId: order?.id, onSelect: (id) => setState(() => _selId = id), onQuote: _showQuote),
              ),
              const SizedBox(width: 22),
              Expanded(
                flex: 10,
                child: _CompositionCard(order: order, bdData: bdData, onQuote: _showQuote),
              ),
            ],
          ),
      ],
    );
  }

  void _showQuote(Ordem order) {
    showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: .6),
      builder: (_) => _QuoteModal(order: order),
    );
  }
}

class _OrdersCard extends StatelessWidget {
  const _OrdersCard({required this.ordens, required this.selId, required this.onSelect, required this.onQuote});

  final List<Ordem> ordens;
  final String? selId;
  final ValueChanged<String> onSelect;
  final ValueChanged<Ordem> onQuote;

  @override
  Widget build(BuildContext context) {
    final c = context.gc;
    return GriloCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const CardHeader(icon: Icons.history_outlined, title: 'Histórico de orçamentos'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Expanded(flex: 3, child: _Th('Peça')),
                Expanded(flex: 2, child: _Th('Motor')),
                Expanded(flex: 2, child: _Th('Custo')),
                Expanded(flex: 2, child: _Th('Preço')),
                const SizedBox(width: 38),
              ],
            ),
          ),
          Container(height: 1, color: c.line),
          for (final o in ordens) _OrderRow(o: o, selected: o.id == selId, onTap: () => onSelect(o.id), onQuote: () => onQuote(o)),
        ],
      ),
    );
  }
}

class _Th extends StatelessWidget {
  const _Th(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    final c = context.gc;
    return Text(
      label.toUpperCase(),
      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: .55, color: c.tx3),
    );
  }
}

class _OrderRow extends StatelessWidget {
  const _OrderRow({required this.o, required this.selected, required this.onTap, required this.onQuote});

  final Ordem o;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback onQuote;

  @override
  Widget build(BuildContext context) {
    final c = context.gc;
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: selected ? c.accentSoft : null,
          border: Border(bottom: BorderSide(color: c.line)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(o.nome, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: c.tx)),
                  Text(fmtDate(o.data), style: TextStyle(fontSize: 12, color: c.tx3)),
                ],
              ),
            ),
            Expanded(flex: 2, child: EngineBadge(engine: o.engine)),
            Expanded(flex: 2, child: Text(fmtBRL(o.custo), style: TextStyle(fontSize: 14, color: c.tx2, fontFeatures: const [FontFeature.tabularFigures()]))),
            Expanded(flex: 2, child: Text(fmtBRL(o.preco), style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: c.tx, fontFeatures: const [FontFeature.tabularFigures()]))),
            SizedBox(
              width: 38,
              child: GriloMiniButton(icon: Icons.person_outline, onPressed: onQuote),
            ),
          ],
        ),
      ),
    );
  }
}

class _CompositionCard extends StatelessWidget {
  const _CompositionCard({required this.order, required this.bdData, required this.onQuote});

  final Ordem? order;
  final List<(String, double, Color)> bdData;
  final ValueChanged<Ordem> onQuote;

  @override
  Widget build(BuildContext context) {
    final c = context.gc;
    return GriloCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const CardHeader(icon: Icons.layers_outlined, title: 'Composição de custo'),
          if (order != null)
            Padding(
              padding: griloCardPad,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(order!.nome, style: TextStyle(fontSize: 13, color: c.tx2)),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 26,
                    runSpacing: 18,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      DonutChart(data: bdData, centerLabel: 'custo', centerValue: fmtBRL(order!.custo)),
                      ConstrainedBox(
                        constraints: const BoxConstraints(minWidth: 180, maxWidth: 320),
                        child: DonutLegend(data: bdData, format: fmtBRL),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  GriloButton(
                    label: 'Gerar card para o cliente',
                    icon: Icons.person_outline,
                    variant: GriloButtonVariant.primary,
                    expand: true,
                    onPressed: () => onQuote(order!),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _QuoteModal extends StatelessWidget {
  const _QuoteModal({required this.order});

  final Ordem order;

  @override
  Widget build(BuildContext context) {
    final c = context.gc;
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              decoration: BoxDecoration(
                color: c.surface,
                borderRadius: BorderRadius.circular(GriloRadius.xl),
                border: Border.all(color: c.line),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: .5), blurRadius: 60, offset: const Offset(0, 30), spreadRadius: -30)],
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [c.accent, c.accent2],
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 30,
                              height: 30,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(color: Colors.white.withValues(alpha: .2), borderRadius: BorderRadius.circular(9)),
                              child: const GriloCubeIcon(size: 18, color: Colors.white),
                            ),
                            const SizedBox(width: 10),
                            const Text('Grilo Ateliê', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16)),
                          ],
                        ),
                        const SizedBox(height: 18),
                        Text(order.nome, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 24, letterSpacing: -.48)),
                        const SizedBox(height: 5),
                        Text(
                          'Orçamento · ${fmtDate(order.data, long: true)}',
                          style: const TextStyle(color: Colors.white, fontSize: 13).copyWith(color: Colors.white.withValues(alpha: .85)),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 4, bottom: 6),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text('Valor total', style: TextStyle(fontSize: 14, color: c.tx2, fontWeight: FontWeight.w600)),
                              Text(
                                fmtBRL(order.preco),
                                style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800, color: c.tx, letterSpacing: -.6, fontFeatures: const [FontFeature.tabularFigures()]),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Orçamento válido por 15 dias. Prazo de produção combinado na confirmação.',
                          style: TextStyle(fontSize: 12, color: c.tx3, height: 1.6),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GriloButton(label: 'Copiar', icon: Icons.copy_outlined, onPressed: () {}),
                const SizedBox(width: 10),
                GriloButton(label: 'Baixar imagem', icon: Icons.download_outlined, variant: GriloButtonVariant.primary, onPressed: () {}),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
