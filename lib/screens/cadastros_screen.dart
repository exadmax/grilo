import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/models.dart';
import '../providers/providers.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';
import '../widgets/badges.dart';
import '../widgets/buttons.dart';
import '../widgets/inputs.dart';
import '../widgets/surfaces.dart';

enum _CadTab { materiais, maquinas, config }

class CadastrosScreen extends ConsumerStatefulWidget {
  const CadastrosScreen({super.key});

  @override
  ConsumerState<CadastrosScreen> createState() => _CadastrosScreenState();
}

class _CadastrosScreenState extends ConsumerState<CadastrosScreen> {
  _CadTab _tab = _CadTab.materiais;

  @override
  Widget build(BuildContext context) {
    final c = context.gc;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: SegmentedControl<_CadTab>(
            value: _tab,
            onChanged: (v) => setState(() => _tab = v),
            options: [
              (_CadTab.materiais, 'Materiais', (on) => Icon(Icons.inventory_2_outlined, size: 17, color: on ? c.accent : c.tx3)),
              (_CadTab.maquinas, 'Máquinas', (on) => Icon(Icons.build_outlined, size: 17, color: on ? c.accent : c.tx3)),
              (_CadTab.config, 'Configurações', (on) => Icon(Icons.settings_outlined, size: 17, color: on ? c.accent : c.tx3)),
            ],
          ),
        ),
        const SizedBox(height: 24),
        switch (_tab) {
          _CadTab.materiais => const _MateriaisTab(),
          _CadTab.maquinas => const _MaquinasTab(),
          _CadTab.config => const _ConfigTab(),
        },
      ],
    );
  }
}

/// `.cols-2` — two columns above 760px viewport width, single column below.
class _Cols2 extends StatelessWidget {
  const _Cols2({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.sizeOf(context).width < 760) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [for (var i = 0; i < children.length; i++) ...[if (i > 0) const SizedBox(height: 16), children[i]]],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < children.length; i++) ...[
          Expanded(child: children[i]),
          if (i < children.length - 1) const SizedBox(width: 16),
        ],
      ],
    );
  }
}

/// Uppercase table header cell.
class _Th extends StatelessWidget {
  const _Th(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    final c = context.gc;
    return Text(label.toUpperCase(), style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: .55, color: c.tx3));
  }
}

// ── Materiais ────────────────────────────────────────────────────────────

class _MateriaisTab extends ConsumerStatefulWidget {
  const _MateriaisTab();

  @override
  ConsumerState<_MateriaisTab> createState() => _MateriaisTabState();
}

class _MateriaisTabState extends ConsumerState<_MateriaisTab> {
  String _q = '';
  CraftEngineId? _filt;

  @override
  Widget build(BuildContext context) {
    final c = context.gc;
    final materiais = ref.watch(materiaisProvider);
    final list = materiais.where((m) {
      if (_filt != null && !m.tipo.engines.contains(_filt)) return false;
      if (_q.isNotEmpty) {
        final q = _q.toLowerCase();
        if (!m.nome.toLowerCase().contains(q) && !m.marca.toLowerCase().contains(q)) return false;
      }
      return true;
    }).toList();

    const colW = [220.0, 120.0, 140.0, 160.0, 100.0, 76.0];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 12,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            SizedBox(
              width: 280,
              child: GriloTextField(
                placeholder: 'Buscar material ou marca…',
                prefixIcon: Icons.search,
                onChanged: (v) => setState(() => _q = v),
              ),
            ),
            SegmentedControl<CraftEngineId?>(
              value: _filt,
              compact: true,
              onChanged: (v) => setState(() => _filt = v),
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
            GriloButton(
              label: 'Novo material',
              icon: Icons.add,
              variant: GriloButtonVariant.primary,
              hideLabelOnNarrow: true,
              onPressed: () => _openModal(null),
            ),
          ],
        ),
        const SizedBox(height: 18),
        GriloCard(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: colW.fold(0, (a, b) => a + b)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        SizedBox(width: colW[0], child: const _Th('Material')),
                        SizedBox(width: colW[1], child: const _Th('Tipo')),
                        SizedBox(width: colW[2], child: const _Th('Custo unitário')),
                        SizedBox(width: colW[3], child: const _Th('Estoque')),
                        SizedBox(width: colW[4], child: const _Th('Compatível')),
                        SizedBox(width: colW[5]),
                      ],
                    ),
                  ),
                  Container(height: 1, color: c.line),
                  if (list.isEmpty) const EmptyState(icon: Icons.inventory_2_outlined, message: 'Nenhum material encontrado.'),
                  for (final m in list) _MaterialRow(m: m, colW: colW, onEdit: () => _openModal(m), onDelete: () => ref.read(materiaisProvider.notifier).remover(m.id)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _openModal(MaterialItem? mat) {
    showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: .6),
      builder: (_) => _MaterialModal(
        mat: mat,
        onSave: (m) {
          ref.read(materiaisProvider.notifier).salvar(m, originalId: mat?.id);
          Navigator.of(context).pop();
        },
      ),
    );
  }
}

class _MaterialRow extends StatelessWidget {
  const _MaterialRow({required this.m, required this.colW, required this.onEdit, required this.onDelete});

  final MaterialItem m;
  final List<double> colW;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final c = context.gc;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: c.line))),
      child: Row(
        children: [
          SizedBox(
            width: colW[0],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(m.nome, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: c.tx)),
                Text(m.marca, style: TextStyle(fontSize: 12, color: c.tx3)),
              ],
            ),
          ),
          SizedBox(width: colW[1], child: GriloChip(label: m.tipo.label)),
          SizedBox(
            width: colW[2],
            child: Text.rich(
              TextSpan(children: [
                TextSpan(text: fmtBRL(m.custoUnitario), style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: c.tx)),
                TextSpan(text: ' /${m.tipo.unidade}', style: TextStyle(fontSize: 12, color: c.tx3, fontWeight: FontWeight.normal)),
              ]),
              style: const TextStyle(fontFeatures: [FontFeature.tabularFigures()]),
            ),
          ),
          SizedBox(
            width: colW[3],
            child: Wrap(
              spacing: 8,
              runSpacing: 4,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text('${fmtNum(m.estoque)} ${m.tipo.unidade}', style: TextStyle(fontSize: 14, color: c.tx, fontFeatures: const [FontFeature.tabularFigures()])),
                if (m.estoqueBaixo)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: c.warnSoft, borderRadius: BorderRadius.circular(999)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.warning_amber_rounded, size: 12, color: c.warn),
                        const SizedBox(width: 4),
                        Text('baixo', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: c.warn)),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(
            width: colW[4],
            child: Row(children: [for (final e in m.tipo.engines) Padding(padding: const EdgeInsets.only(right: 4), child: EngineBadge(engine: e, withLabel: false))]),
          ),
          SizedBox(
            width: colW[5],
            child: Row(
              children: [
                GriloMiniButton(icon: Icons.edit_outlined, onPressed: onEdit),
                GriloMiniButton(icon: Icons.delete_outline, danger: true, onPressed: onDelete),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MaterialModal extends StatefulWidget {
  const _MaterialModal({required this.mat, required this.onSave});

  final MaterialItem? mat;
  final ValueChanged<MaterialItem> onSave;

  @override
  State<_MaterialModal> createState() => _MaterialModalState();
}

class _MaterialModalState extends State<_MaterialModal> {
  late final TextEditingController _nomeCtrl;
  late final TextEditingController _marcaCtrl;
  late TipoMaterial _tipo;
  late double _preco;
  late double _qtd;
  late double _estoque;

  @override
  void initState() {
    super.initState();
    final m = widget.mat;
    _nomeCtrl = TextEditingController(text: m?.nome ?? '');
    _marcaCtrl = TextEditingController(text: m?.marca ?? '');
    _tipo = m?.tipo ?? TipoMaterial.filamento;
    _preco = m?.preco ?? 0;
    _qtd = m?.qtd ?? 0;
    _estoque = m?.estoque ?? 0;
  }

  @override
  void dispose() {
    _nomeCtrl.dispose();
    _marcaCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.gc;
    final cu = (_preco > 0 && _qtd > 0) ? custoUnit(_preco, _qtd) : 0.0;
    final canSave = _nomeCtrl.text.trim().isNotEmpty && _preco > 0 && _qtd > 0;

    return _ModalShell(
      icon: Icons.inventory_2_outlined,
      title: widget.mat == null ? 'Novo material' : 'Editar material',
      onClose: () => Navigator.of(context).pop(),
      body: [
        FieldWrapper(
          label: 'Nome',
          child: GriloTextField(controller: _nomeCtrl, placeholder: 'Ex: PLA Vermelho, Fio Anne Bege', onChanged: (_) => setState(() {})),
        ),
        _Cols2(children: [
          FieldWrapper(
            label: 'Tipo',
            child: GriloDropdown<TipoMaterial>(
              value: _tipo,
              items: [for (final t in TipoMaterial.values) (t, t.label)],
              onChanged: (v) => setState(() => _tipo = v ?? _tipo),
            ),
          ),
          FieldWrapper(
            label: 'Marca',
            child: GriloTextField(controller: _marcaCtrl, placeholder: 'Opcional'),
          ),
        ]),
        _Cols2(children: [
          FieldWrapper(
            label: 'Preço de compra',
            child: NumField(value: _preco, onChanged: (v) => setState(() => _preco = v), prefix: 'R\$'),
          ),
          FieldWrapper(
            label: 'Quantidade da embalagem (${_tipo.unidade})',
            child: NumField(value: _qtd, onChanged: (v) => setState(() => _qtd = v), suffix: _tipo.unidade),
          ),
        ]),
        FieldWrapper(
          label: 'Estoque atual (${_tipo.unidade})',
          child: NumField(value: _estoque, onChanged: (v) => setState(() => _estoque = v), suffix: _tipo.unidade),
        ),
        ToggleRow(
          accentBg: true,
          leading: Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: c.surface, borderRadius: BorderRadius.circular(GriloRadius.md)),
            child: Icon(Icons.sell_outlined, size: 16, color: c.accent),
          ),
          title: 'Custo unitário derivado',
          subtitle: 'Calculado automaticamente: preço ÷ quantidade',
          trailing: Text.rich(
            TextSpan(children: [
              TextSpan(text: fmtBRL(cu), style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: c.tx)),
              TextSpan(text: ' /${_tipo.unidade}', style: TextStyle(fontSize: 12, color: c.tx3, fontWeight: FontWeight.normal)),
            ]),
          ),
        ),
      ],
      footer: [
        GriloButton(label: 'Cancelar', variant: GriloButtonVariant.ghost, onPressed: () => Navigator.of(context).pop()),
        GriloButton(
          label: 'Salvar material',
          icon: Icons.check,
          variant: GriloButtonVariant.primary,
          onPressed: canSave
              ? () => widget.onSave(MaterialItem(
                    id: widget.mat?.id ?? 'm${DateTime.now().millisecondsSinceEpoch}',
                    nome: _nomeCtrl.text.trim(),
                    tipo: _tipo,
                    marca: _marcaCtrl.text.trim(),
                    preco: _preco,
                    qtd: _qtd,
                    estoque: _estoque,
                  ))
              : null,
        ),
      ],
    );
  }
}

// ── Máquinas ─────────────────────────────────────────────────────────────

class _MaquinasTab extends ConsumerWidget {
  const _MaquinasTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.gc;
    final maquinas = ref.watch(maquinasProvider);
    const colW = [240.0, 110.0, 90.0, 150.0, 140.0, 76.0];

    void openModal(Maquina? mq) {
      showDialog<void>(
        context: context,
        barrierColor: Colors.black.withValues(alpha: .6),
        builder: (_) => _MaquinaModal(
          mq: mq,
          onSave: (m) {
            ref.read(maquinasProvider.notifier).salvar(m, originalId: mq?.id);
            Navigator.of(context).pop();
          },
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Spacer(),
            GriloButton(
              label: 'Nova máquina',
              icon: Icons.add,
              variant: GriloButtonVariant.primary,
              hideLabelOnNarrow: true,
              onPressed: () => openModal(null),
            ),
          ],
        ),
        const SizedBox(height: 18),
        GriloCard(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: colW.fold(0, (a, b) => a + b)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        SizedBox(width: colW[0], child: const _Th('Nome')),
                        SizedBox(width: colW[1], child: const _Th('Subtipo')),
                        SizedBox(width: colW[2], child: const _Th('Potência')),
                        SizedBox(width: colW[3], child: const _Th('Depreciação/hora')),
                        SizedBox(width: colW[4], child: const _Th('Consumíveis')),
                        SizedBox(width: colW[5]),
                      ],
                    ),
                  ),
                  Container(height: 1, color: c.line),
                  if (maquinas.isEmpty) const EmptyState(icon: Icons.build_outlined, message: 'Nenhuma máquina cadastrada.'),
                  for (final mq in maquinas)
                    _MaquinaRow(mq: mq, colW: colW, onEdit: () => openModal(mq), onDelete: () => ref.read(maquinasProvider.notifier).remover(mq.id)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _MaquinaRow extends StatelessWidget {
  const _MaquinaRow({required this.mq, required this.colW, required this.onEdit, required this.onDelete});

  final Maquina mq;
  final List<double> colW;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final c = context.gc;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: c.line))),
      child: Row(
        children: [
          SizedBox(
            width: colW[0],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(mq.nome, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: c.tx)),
                Text('${fmtBRL(mq.custo)} · ${fmtNum(mq.vidaH)} h vida útil', style: TextStyle(fontSize: 12, color: c.tx3)),
              ],
            ),
          ),
          SizedBox(
            width: colW[1],
            child: GriloChip(label: mq.tipo.label, bg: mq.tipo == MaquinaTipo.slaMsla ? c.accentSoft : null, fg: mq.tipo == MaquinaTipo.slaMsla ? c.accentTx : null),
          ),
          SizedBox(width: colW[2], child: Text('${fmtNum(mq.potencia)} W', style: TextStyle(fontSize: 14, color: c.tx, fontFeatures: const [FontFeature.tabularFigures()]))),
          SizedBox(
            width: colW[3],
            child: Text.rich(
              TextSpan(children: [
                TextSpan(text: fmtBRL(mq.deprecHora), style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: c.tx)),
                TextSpan(text: ' /h', style: TextStyle(fontSize: 12, color: c.tx3, fontWeight: FontWeight.normal)),
              ]),
              style: const TextStyle(fontFeatures: [FontFeature.tabularFigures()]),
            ),
          ),
          SizedBox(
            width: colW[4],
            child: mq.telaCusto > 0
                ? const GriloChip(label: 'Tela LCD + FEP')
                : Text('—', style: TextStyle(fontSize: 13, color: c.tx3)),
          ),
          SizedBox(
            width: colW[5],
            child: Row(
              children: [
                GriloMiniButton(icon: Icons.edit_outlined, onPressed: onEdit),
                GriloMiniButton(icon: Icons.delete_outline, danger: true, onPressed: onDelete),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MaquinaModal extends StatefulWidget {
  const _MaquinaModal({required this.mq, required this.onSave});

  final Maquina? mq;
  final ValueChanged<Maquina> onSave;

  @override
  State<_MaquinaModal> createState() => _MaquinaModalState();
}

class _MaquinaModalState extends State<_MaquinaModal> {
  late final TextEditingController _nomeCtrl;
  late MaquinaTipo _tipo;
  late double _potencia;
  late double _custo;
  late double _vidaH;
  late double _telaVida;
  late double _telaCusto;
  late double _fepVida;
  late double _fepCusto;

  @override
  void initState() {
    super.initState();
    final mq = widget.mq;
    _nomeCtrl = TextEditingController(text: mq?.nome ?? '');
    _tipo = mq?.tipo ?? MaquinaTipo.fdm;
    _potencia = mq?.potencia ?? 0;
    _custo = mq?.custo ?? 0;
    _vidaH = mq?.vidaH ?? 0;
    _telaVida = mq?.telaVida ?? 0;
    _telaCusto = mq?.telaCusto ?? 0;
    _fepVida = mq?.fepVida ?? 0;
    _fepCusto = mq?.fepCusto ?? 0;
  }

  @override
  void dispose() {
    _nomeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.gc;
    final isSla = _tipo == MaquinaTipo.slaMsla;
    final dh = (_custo > 0 && _vidaH > 0) ? _custo / _vidaH : 0.0;
    final canSave = _nomeCtrl.text.trim().isNotEmpty && _potencia > 0;

    return _ModalShell(
      icon: Icons.build_outlined,
      title: widget.mq == null ? 'Nova máquina' : 'Editar máquina',
      onClose: () => Navigator.of(context).pop(),
      body: [
        _Cols2(children: [
          FieldWrapper(
            label: 'Nome',
            child: GriloTextField(controller: _nomeCtrl, placeholder: 'Ex: Ender 3 V3', onChanged: (_) => setState(() {})),
          ),
          FieldWrapper(
            label: 'Subtipo',
            child: GriloDropdown<MaquinaTipo>(
              value: _tipo,
              items: [for (final t in MaquinaTipo.values) (t, t.label)],
              onChanged: (v) => setState(() => _tipo = v ?? _tipo),
            ),
          ),
        ]),
        _Cols2(children: [
          FieldWrapper(
            label: 'Potência',
            child: NumField(value: _potencia, onChanged: (v) => setState(() => _potencia = v), suffix: 'W'),
          ),
          FieldWrapper(
            label: 'Valor da máquina',
            child: NumField(value: _custo, onChanged: (v) => setState(() => _custo = v), prefix: 'R\$'),
          ),
        ]),
        FieldWrapper(
          label: 'Vida útil estimada (horas)',
          child: NumField(value: _vidaH, onChanged: (v) => setState(() => _vidaH = v), suffix: 'h'),
        ),
        if (isSla) ...[
          _Cols2(children: [
            FieldWrapper(
              label: 'Vida tela LCD (h)',
              child: NumField(value: _telaVida, onChanged: (v) => setState(() => _telaVida = v), suffix: 'h'),
            ),
            FieldWrapper(
              label: 'Custo tela LCD',
              child: NumField(value: _telaCusto, onChanged: (v) => setState(() => _telaCusto = v), prefix: 'R\$'),
            ),
          ]),
          _Cols2(children: [
            FieldWrapper(
              label: 'Vida filme FEP (impressões)',
              child: NumField(value: _fepVida, onChanged: (v) => setState(() => _fepVida = v), suffix: 'impr.'),
            ),
            FieldWrapper(
              label: 'Custo FEP',
              child: NumField(value: _fepCusto, onChanged: (v) => setState(() => _fepCusto = v), prefix: 'R\$'),
            ),
          ]),
        ],
        ToggleRow(
          accentBg: true,
          leading: Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: c.surface, borderRadius: BorderRadius.circular(GriloRadius.md)),
            child: Icon(Icons.access_time_outlined, size: 16, color: c.accent),
          ),
          title: 'Depreciação por hora derivada',
          subtitle: 'Valor da máquina ÷ vida útil',
          trailing: Text.rich(
            TextSpan(children: [
              TextSpan(text: fmtBRL(dh), style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: c.tx)),
              TextSpan(text: ' /h', style: TextStyle(fontSize: 12, color: c.tx3, fontWeight: FontWeight.normal)),
            ]),
          ),
        ),
      ],
      footer: [
        GriloButton(label: 'Cancelar', variant: GriloButtonVariant.ghost, onPressed: () => Navigator.of(context).pop()),
        GriloButton(
          label: 'Salvar máquina',
          icon: Icons.check,
          variant: GriloButtonVariant.primary,
          onPressed: canSave
              ? () => widget.onSave(Maquina(
                    id: widget.mq?.id ?? 'mq${DateTime.now().millisecondsSinceEpoch}',
                    nome: _nomeCtrl.text.trim(),
                    tipo: _tipo,
                    potencia: _potencia,
                    custo: _custo,
                    vidaH: _vidaH,
                    telaVida: isSla ? _telaVida : 0,
                    telaCusto: isSla ? _telaCusto : 0,
                    fepVida: isSla ? _fepVida : 0,
                    fepCusto: isSla ? _fepCusto : 0,
                  ))
              : null,
        ),
      ],
    );
  }
}

// ── Configurações ────────────────────────────────────────────────────────

class _ConfigTab extends ConsumerWidget {
  const _ConfigTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.gc;
    final config = ref.watch(configProvider);
    final notifier = ref.read(configProvider.notifier);
    final efetivo = config.kwhEfetivo;

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 820),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Energia
          GriloCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const CardHeader(icon: Icons.bolt_outlined, title: 'Energia'),
                Padding(
                  padding: griloCardPad,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _Cols2(children: [
                        FieldWrapper(
                          label: 'kWh base',
                          hint: 'Tarifa de energia sem bandeira nem impostos.',
                          child: NumField(value: config.kwh, onChanged: (v) => notifier.update((s) => s.copyWith(kwh: v)), prefix: 'R\$', suffix: '/kWh'),
                        ),
                        FieldWrapper(
                          label: 'ICMS (sugestão ${config.uf}: ${icmsUf[config.uf]?.toStringAsFixed(0) ?? '—'}%)',
                          child: Row(
                            children: [
                              SizedBox(
                                width: 90,
                                child: GriloDropdown<String>(
                                  value: config.uf,
                                  items: [for (final uf in icmsUf.keys) (uf, uf)],
                                  onChanged: (v) {
                                    if (v != null) notifier.update((s) => s.copyWith(uf: v, icms: icmsUf[v] ?? s.icms));
                                  },
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(child: NumField(value: config.icms, onChanged: (v) => notifier.update((s) => s.copyWith(icms: v)), suffix: '%')),
                            ],
                          ),
                        ),
                      ]),
                      const SizedBox(height: 18),
                      FieldWrapper(
                        label: 'Bandeira tarifária ativa',
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (final b in Bandeira.values)
                              _BandeiraChip(bandeira: b, selected: config.bandeira == b, onTap: () => notifier.update((s) => s.copyWith(bandeira: b))),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      ToggleRow(
                        accentBg: true,
                        leading: Container(
                          width: 34,
                          height: 34,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(color: c.surface, borderRadius: BorderRadius.circular(GriloRadius.md)),
                          child: Icon(Icons.bolt_outlined, size: 16, color: c.accent),
                        ),
                        title: 'kWh efetivo',
                        subtitle: '(base + bandeira) × (1 + ICMS)',
                        trailing: Text.rich(
                          TextSpan(children: [
                            TextSpan(text: fmtBRL(efetivo), style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: c.tx)),
                            TextSpan(text: ' /kWh', style: TextStyle(fontSize: 12, color: c.tx3, fontWeight: FontWeight.normal)),
                          ]),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Trabalho + Precificação
          _Cols2(children: [
            GriloCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const CardHeader(icon: Icons.access_time_outlined, title: 'Trabalho'),
                  Padding(
                    padding: griloCardPad,
                    child: FieldWrapper(
                      label: 'R\$/hora padrão',
                      hint: 'Valor da mão de obra aplicado por padrão.',
                      child: NumField(value: config.maoObra, onChanged: (v) => notifier.update((s) => s.copyWith(maoObra: v)), prefix: 'R\$', suffix: '/hora'),
                    ),
                  ),
                ],
              ),
            ),
            GriloCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const CardHeader(icon: Icons.sell_outlined, title: 'Precificação'),
                  Padding(
                    padding: griloCardPad,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FieldWrapper(
                          label: 'Markup padrão',
                          child: NumField(value: config.markupPadrao, onChanged: (v) => notifier.update((s) => s.copyWith(markupPadrao: v)), suffix: '%'),
                        ),
                        const SizedBox(height: 16),
                        FieldWrapper(
                          label: 'Risco padrão',
                          child: NumField(value: config.riscoPadrao, onChanged: (v) => notifier.update((s) => s.copyWith(riscoPadrao: v)), suffix: '%'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ]),
          const SizedBox(height: 16),
          // Comportamento
          GriloCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const CardHeader(icon: Icons.layers_outlined, title: 'Comportamento'),
                Padding(
                  padding: griloCardPad,
                  child: ToggleRow(
                    leading: GriloSwitch(value: config.debitarEstoque, onChanged: (v) => notifier.update((s) => s.copyWith(debitarEstoque: v))),
                    title: 'Debitar estoque automaticamente ao salvar ordem',
                    subtitle: 'O consumo de materiais é abatido do estoque a cada orçamento salvo.',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Backup
          GriloCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const CardHeader(icon: Icons.download_outlined, title: 'Backup & exportação'),
                Padding(
                  padding: griloCardPad,
                  child: Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      GriloButton(label: 'Exportar CSV', icon: Icons.download_outlined, onPressed: () {}),
                      GriloButton(label: 'Exportar JSON', icon: Icons.download_outlined, onPressed: () {}),
                      GriloButton(label: 'Backup em nuvem', icon: Icons.layers_outlined, onPressed: () {}),
                      Text(
                        'Mantenha seu histórico seguro mesmo se o aparelho quebrar.',
                        style: TextStyle(fontSize: 12.5, color: c.tx3),
                      ),
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

class _BandeiraChip extends StatelessWidget {
  const _BandeiraChip({required this.bandeira, required this.selected, required this.onTap});

  final Bandeira bandeira;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.gc;
    final color = bandeira.color;
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: .18) : c.chip,
          border: Border.all(color: selected ? color : c.line),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
            const SizedBox(width: 8),
            Text(bandeira.label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: selected ? color : c.tx2)),
            const SizedBox(width: 4),
            Text('+${fmtBRL(bandeira.add).replaceFirst('R\$ ', '')}', style: TextStyle(fontSize: 13, color: c.tx3, fontFeatures: const [FontFeature.tabularFigures()])),
          ],
        ),
      ),
    );
  }
}

// ── Shared modal shell ──────────────────────────────────────────────────

class _ModalShell extends StatelessWidget {
  const _ModalShell({required this.icon, required this.title, required this.onClose, required this.body, required this.footer});

  final IconData icon;
  final String title;
  final VoidCallback onClose;
  final List<Widget> body;
  final List<Widget> footer;

  @override
  Widget build(BuildContext context) {
    final c = context.gc;
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Container(
          decoration: BoxDecoration(
            color: c.surface,
            borderRadius: BorderRadius.circular(GriloRadius.xl),
            border: Border.all(color: c.line2),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: .5), blurRadius: 60, offset: const Offset(0, 30), spreadRadius: -30)],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
                decoration: BoxDecoration(border: Border(bottom: BorderSide(color: c.line))),
                child: Row(
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(color: c.accentSoft, borderRadius: BorderRadius.circular(GriloRadius.md)),
                      child: Icon(icon, size: 18, color: c.accent),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700))),
                    GriloMiniButton(icon: Icons.close, onPressed: onClose),
                  ],
                ),
              ),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [for (var i = 0; i < body.length; i++) ...[if (i > 0) const SizedBox(height: 16), body[i]]],
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                decoration: BoxDecoration(border: Border(top: BorderSide(color: c.line))),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [for (var i = 0; i < footer.length; i++) ...[if (i > 0) const SizedBox(width: 10), footer[i]]],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
