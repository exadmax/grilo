import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../engines/craft_engine.dart';
import '../models/models.dart';
import '../providers/providers.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';
import '../widgets/badges.dart';
import '../widgets/buttons.dart';
import '../widgets/charts.dart';
import '../widgets/grilo_icons.dart';
import '../widgets/inputs.dart';
import '../widgets/surfaces.dart';

typedef _StepDef = (String id, String title, String desc);

const _print3dSteps = <_StepDef>[
  ('mat', 'Material & máquina', 'Escolha o filamento ou resina e a impressora.'),
  ('imp', 'Impressão', 'Tempo, energia e perdas de purga.'),
  ('pos', 'Pós-processo & mão de obra', 'Lavagem, cura e tempo de trabalho.'),
  ('fin', 'Risco & precificação', 'Margem de falha e markup final.'),
];

const _crocheSteps = <_StepDef>[
  ('mat', 'Fios & acessórios', 'Selecione os fios e materiais extras.'),
  ('imp', 'Produção', 'Tempo de trabalho — o principal custo no crochê.'),
  ('fin', 'Risco & precificação', 'Margem de refação e markup final.'),
];

MatQty? _findQty(List<MatQty> list, String id) {
  for (final m in list) {
    if (m.id == id) return m;
  }
  return null;
}

class CalculadoraScreen extends ConsumerStatefulWidget {
  const CalculadoraScreen({super.key});

  @override
  ConsumerState<CalculadoraScreen> createState() => _CalculadoraScreenState();
}

class _CalculadoraScreenState extends ConsumerState<CalculadoraScreen> {
  CraftEngineId _engine = CraftEngineId.print3d;
  int _step = 0;
  late final TextEditingController _nomeCtrl;
  late Print3dState _print3d;
  late CrocheState _croche;

  @override
  void initState() {
    super.initState();
    _nomeCtrl = TextEditingController();
    final cfg = ref.read(configProvider);
    _print3d = Print3dState.defaults(risco: cfg.riscoPadrao, markup: cfg.markupPadrao);
    _croche = CrocheState.defaults(risco: cfg.riscoPadrao, markup: cfg.markupPadrao);
  }

  @override
  void dispose() {
    _nomeCtrl.dispose();
    super.dispose();
  }

  void _switchEngine(CraftEngineId id) {
    final cfg = ref.read(configProvider);
    setState(() {
      _engine = id;
      _step = 0;
      if (id == CraftEngineId.print3d) {
        _print3d = Print3dState.defaults(risco: cfg.riscoPadrao, markup: cfg.markupPadrao);
      } else {
        _croche = CrocheState.defaults(risco: cfg.riscoPadrao, markup: cfg.markupPadrao);
      }
    });
  }

  void _updP(Print3dState Function(Print3dState) f) => setState(() => _print3d = f(_print3d));
  void _updC(CrocheState Function(CrocheState) f) => setState(() => _croche = f(_croche));

  void _save(CalcResult res) {
    final nome = _nomeCtrl.text.trim();
    final ordem = Ordem(
      id: 'o${DateTime.now().millisecondsSinceEpoch}',
      nome: nome.isEmpty ? 'Orçamento sem título' : nome,
      engine: _engine,
      data: DateTime.now(),
      preco: res.preco,
      custo: res.custo,
      breakdown: res.breakdown,
    );
    ref.read(ordensProvider.notifier).adicionar(ordem);
    ref.read(toastProvider.notifier).show('Orçamento salvo no histórico');
    ref.read(routeProvider.notifier).set(AppRoute.hist);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.gc;
    final materiais = ref.watch(materiaisProvider);
    final maquinas = ref.watch(maquinasProvider);
    final config = ref.watch(configProvider);

    final steps = _engine == CraftEngineId.print3d ? _print3dSteps : _crocheSteps;
    final stepIndex = _step.clamp(0, steps.length - 1);
    final res = _engine == CraftEngineId.print3d
        ? computePrint3d(_print3d, config, materiais, maquinas)
        : computeCroche(_croche, config, materiais);
    final markup = _engine == CraftEngineId.print3d ? _print3d.markup : _croche.markup;

    final stepBody = _engine == CraftEngineId.print3d
        ? _print3dStepBody(steps[stepIndex].$1, materiais, maquinas, config)
        : _crocheStepBody(steps[stepIndex].$1, materiais, config);

    final wizardCard = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _StepsTracker(steps: steps, current: stepIndex, onTap: (i) => setState(() => _step = i)),
        const SizedBox(height: 22),
        GriloCard(
          child: Padding(
            padding: griloCardPad,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(steps[stepIndex].$2, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, letterSpacing: -.17, color: c.tx)),
                const SizedBox(height: 4),
                Text(steps[stepIndex].$3, style: TextStyle(fontSize: 13.5, color: c.tx2)),
                const SizedBox(height: 20),
                stepBody,
                Container(
                  margin: const EdgeInsets.only(top: 24),
                  padding: const EdgeInsets.only(top: 20),
                  decoration: BoxDecoration(border: Border(top: BorderSide(color: c.line))),
                  child: Row(
                    children: [
                      GriloButton(
                        label: 'Voltar',
                        icon: Icons.arrow_back,
                        variant: GriloButtonVariant.ghost,
                        onPressed: stepIndex == 0 ? null : () => setState(() => _step = stepIndex - 1),
                      ),
                      const Spacer(),
                      if (stepIndex < steps.length - 1)
                        GriloButton(
                          label: 'Próximo',
                          icon: Icons.arrow_forward,
                          iconAfter: true,
                          variant: GriloButtonVariant.primary,
                          onPressed: () => setState(() => _step = stepIndex + 1),
                        )
                      else
                        GriloButton(
                          label: 'Salvar orçamento',
                          icon: Icons.check,
                          variant: GriloButtonVariant.primary,
                          onPressed: () => _save(res),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );

    final resultPanel = _ResultPanel(engine: _engine, res: res, nomeController: _nomeCtrl, markup: markup);

    final isWide = MediaQuery.sizeOf(context).width >= 1080;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: SegmentedControl<CraftEngineId>(
            value: _engine,
            onChanged: _switchEngine,
            options: [
              (CraftEngineId.print3d, CraftEngineId.print3d.nome, (on) => Icon(Icons.print_outlined, size: 18, color: on ? c.accent : c.tx3)),
              (CraftEngineId.croche, CraftEngineId.croche.nome, (on) => GriloYarnIcon(size: 18, color: on ? c.accent : c.tx3)),
            ],
          ),
        ),
        const SizedBox(height: 22),
        if (isWide)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: wizardCard),
              const SizedBox(width: 24),
              SizedBox(width: 380, child: resultPanel),
            ],
          )
        else
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              wizardCard,
              const SizedBox(height: 24),
              resultPanel,
            ],
          ),
      ],
    );
  }

  // ── Print3D step bodies ─────────────────────────────────────────────────

  Widget _print3dStepBody(String stepId, List<MaterialItem> materiais, List<Maquina> maquinas, AppConfig config) {
    return switch (stepId) {
      'mat' => _print3dMatStep(materiais, maquinas),
      'imp' => _print3dImpStep(materiais, maquinas, config),
      'pos' => _print3dPosStep(),
      _ => _priceStep(_print3d.risco, _print3d.markup, 'Risco de falha', (v) => _updP((s) => s.copyWith(risco: v)), (v) => _updP((s) => s.copyWith(markup: v))),
    };
  }

  Widget _print3dMatStep(List<MaterialItem> materiais, List<Maquina> maquinas) {
    final filaments = materiais.where((m) => m.tipo == TipoMaterial.filamento || m.tipo == TipoMaterial.resina).toList();
    final principal = _print3d.materiais.isNotEmpty ? _print3d.materiais.first : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FieldWrapper(
          label: 'Material principal',
          child: Column(
            children: [
              for (final m in filaments)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _MatOption(
                    m: m,
                    qtd: principal?.id == m.id ? principal!.qtd : null,
                    selected: principal?.id == m.id,
                    unitLabel: m.tipo.unidade,
                    onSelect: () => _updP((s) => s.copyWith(materiais: [MatQty(id: m.id, qtd: principal?.qtd ?? 45)])),
                    onQtd: (v) => _updP((s) => s.copyWith(materiais: [MatQty(id: m.id, qtd: v)])),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        FieldWrapper(
          label: 'Impressora',
          hint: 'A potência e depreciação vêm do cadastro de máquinas.',
          child: GriloDropdown<String>(
            value: _print3d.maquina,
            items: [for (final mq in maquinas) (mq.id, '${mq.nome} · ${mq.tipo.label} · ${fmtNum(mq.potencia)}W')],
            onChanged: (v) {
              if (v != null) _updP((s) => s.copyWith(maquina: v));
            },
          ),
        ),
      ],
    );
  }

  Widget _print3dImpStep(List<MaterialItem> materiais, List<Maquina> maquinas, AppConfig config) {
    final c = context.gc;
    final principal = _print3d.materiais.isNotEmpty ? _print3d.materiais.first : null;
    final selMat = principal != null ? matById(materiais, principal.id) : null;
    final un = selMat?.tipo.unidade ?? 'g';
    final isResina = selMat?.tipo == TipoMaterial.resina;
    final maq = maqById(maquinas, _print3d.maquina);
    final horas = _print3d.tempoH + _print3d.tempoMin / 60;
    final energiaVal = config.kwhEfetivo * ((maq?.potencia ?? 0) / 1000) * horas;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Cols2(children: [
          FieldWrapper(
            label: 'Tempo de impressão',
            hint: '${fmtNum(horas, 2)} h no total.',
            child: Row(
              children: [
                Expanded(child: NumField(value: _print3d.tempoH, onChanged: (v) => _updP((s) => s.copyWith(tempoH: v)), suffix: 'h')),
                const SizedBox(width: 10),
                Expanded(child: NumField(value: _print3d.tempoMin, onChanged: (v) => _updP((s) => s.copyWith(tempoMin: v)), suffix: 'min')),
              ],
            ),
          ),
          FieldWrapper(
            label: isResina ? 'Volume da peça' : 'Peso da peça',
            hint: isResina ? 'Volume de resina consumido.' : 'Peso de filamento da peça.',
            child: NumField(
              value: principal?.qtd ?? 0,
              onChanged: (v) => _updP((s) => s.copyWith(materiais: [MatQty(id: principal?.id ?? '', qtd: v)])),
              suffix: un,
            ),
          ),
        ]),
        const SizedBox(height: 18),
        FieldWrapper(
          label: 'Perdas / purga (troca de cor)',
          hint: 'Material descartado em purgas e trocas — perda invisível somada ao custo.',
          child: NumField(value: _print3d.purga, onChanged: (v) => _updP((s) => s.copyWith(purga: v)), suffix: un),
        ),
        const SizedBox(height: 18),
        ToggleRow(
          leading: Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: c.accentSoft, borderRadius: BorderRadius.circular(GriloRadius.md)),
            child: Icon(Icons.bolt_outlined, size: 16, color: c.accent),
          ),
          title: 'Custo de energia (ao vivo)',
          subtitle: '${fmtBRL(config.kwhEfetivo)}/kWh efetivo × ${fmtNum(maq?.potencia ?? 0)}W × ${fmtNum(horas, 2)}h',
          trailing: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(fmtBRL(energiaVal), style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: c.tx, fontFeatures: const [FontFeature.tabularFigures()])),
              const SizedBox(height: 6),
              BandeiraBadge(bandeira: config.bandeira),
            ],
          ),
        ),
      ],
    );
  }

  Widget _print3dPosStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ToggleRow(
          leading: GriloSwitch(value: _print3d.posproc, onChanged: (v) => _updP((s) => s.copyWith(posproc: v))),
          title: 'Pós-processamento (lavagem / cura)',
          subtitle: 'Para peças em resina SLA.',
        ),
        if (_print3d.posproc) ...[
          const SizedBox(height: 16),
          _Cols2(children: [
            FieldWrapper(
              label: 'Tempo de lavagem/cura',
              child: NumField(value: _print3d.posProcMin, onChanged: (v) => _updP((s) => s.copyWith(posProcMin: v)), suffix: 'min'),
            ),
            FieldWrapper(
              label: 'Insumo (álcool)',
              child: NumField(value: _print3d.posProcInsumo, onChanged: (v) => _updP((s) => s.copyWith(posProcInsumo: v)), suffix: 'ml'),
            ),
          ]),
        ],
        const SizedBox(height: 16),
        _Cols2(children: [
          FieldWrapper(
            label: 'Tempo de mão de obra',
            hint: 'Setup, remoção de suportes, acabamento.',
            child: NumField(value: _print3d.maoMin, onChanged: (v) => _updP((s) => s.copyWith(maoMin: v)), suffix: 'min'),
          ),
          FieldWrapper(
            label: 'Taxa de configuração',
            child: NumField(value: _print3d.setup, onChanged: (v) => _updP((s) => s.copyWith(setup: v)), prefix: 'R\$'),
          ),
        ]),
      ],
    );
  }

  // ── Crochê step bodies ───────────────────────────────────────────────────

  Widget _crocheStepBody(String stepId, List<MaterialItem> materiais, AppConfig config) {
    return switch (stepId) {
      'mat' => _crocheMatStep(materiais),
      'imp' => _crocheImpStep(config),
      _ => _priceStep(_croche.risco, _croche.markup, 'Risco / refação', (v) => _updC((s) => s.copyWith(risco: v)), (v) => _updC((s) => s.copyWith(markup: v))),
    };
  }

  Widget _crocheMatStep(List<MaterialItem> materiais) {
    final c = context.gc;
    final fios = materiais.where((m) => m.tipo == TipoMaterial.fioAlgodao || m.tipo == TipoMaterial.fioLa).toList();
    final acess = materiais.where((m) => m.tipo == TipoMaterial.acessorio).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Fios', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: c.tx2)),
        const SizedBox(height: 7),
        for (final m in fios)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _MatOption(
              m: m,
              qtd: _findQty(_croche.fios, m.id)?.qtd,
              selected: _findQty(_croche.fios, m.id) != null,
              multi: true,
              unitLabel: m.tipo.unidade,
              onSelect: () => _updC((s) {
                final exists = _findQty(s.fios, m.id) != null;
                return s.copyWith(fios: exists ? [for (final f in s.fios) if (f.id != m.id) f] : [...s.fios, MatQty(id: m.id, qtd: 80)]);
              }),
              onQtd: (v) => _updC((s) => s.copyWith(fios: [for (final f in s.fios) if (f.id == m.id) f.copyWith(qtd: v) else f])),
            ),
          ),
        const SizedBox(height: 22),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('Acessórios', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: c.tx2)),
            const SizedBox(width: 6),
            Text('(olhos, enchimento, zíper…)', style: TextStyle(fontSize: 11.5, color: c.tx3)),
          ],
        ),
        const SizedBox(height: 7),
        for (final m in acess)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _MatOption(
              m: m,
              qtd: _findQty(_croche.acessorios, m.id)?.qtd,
              selected: _findQty(_croche.acessorios, m.id) != null,
              multi: true,
              unitLabel: m.tipo.unidade,
              onSelect: () => _updC((s) {
                final exists = _findQty(s.acessorios, m.id) != null;
                return s.copyWith(acessorios: exists ? [for (final f in s.acessorios) if (f.id != m.id) f] : [...s.acessorios, MatQty(id: m.id, qtd: 1)]);
              }),
              onQtd: (v) => _updC((s) => s.copyWith(acessorios: [for (final f in s.acessorios) if (f.id == m.id) f.copyWith(qtd: v) else f])),
            ),
          ),
      ],
    );
  }

  Widget _crocheImpStep(AppConfig config) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FieldWrapper(
          label: 'Tempo de produção',
          hint: 'No crochê, a mão de obra costuma ser o maior custo — ${fmtNum(config.maoObra)} R\$/h.',
          child: NumField(value: _croche.tempo, onChanged: (v) => _updC((s) => s.copyWith(tempo: v)), suffix: 'horas'),
        ),
        const SizedBox(height: 16),
        ToggleRow(
          leading: GriloSwitch(value: _croche.energia, onChanged: (v) => _updC((s) => s.copyWith(energia: v))),
          title: 'Incluir energia',
          subtitle: 'Iluminação / equipamentos. Geralmente baixo.',
        ),
      ],
    );
  }

  Widget _priceStep(double risco, double markup, String riscoLabel, ValueChanged<double> onRisco, ValueChanged<double> onMarkup) {
    final c = context.gc;
    Widget sliderField(String label, double value, double max, double step, ValueChanged<double> onChanged, String hint) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: c.tx2)),
              Text('${value.round()}%', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: c.tx, fontFeatures: const [FontFeature.tabularFigures()])),
            ],
          ),
          GriloSlider(value: value, max: max, divisions: (max / step).round(), onChanged: onChanged),
          Text(hint, style: TextStyle(fontSize: 11.5, color: c.tx3)),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        sliderField(riscoLabel, risco, 30, 1, onRisco, 'Percentual sobre o custo para cobrir falhas e retrabalho.'),
        const SizedBox(height: 22),
        sliderField('Markup / margem de lucro', markup, 300, 5, onMarkup, 'Aplicado sobre o custo total para chegar ao preço de venda.'),
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
        children: [for (var i = 0; i < children.length; i++) ...[if (i > 0) const SizedBox(height: 18), children[i]]],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < children.length; i++) ...[
          Expanded(child: children[i]),
          if (i < children.length - 1) const SizedBox(width: 18),
        ],
      ],
    );
  }
}

/// `.mat-opt` — selectable material/yarn row with an inline quantity field.
class _MatOption extends StatelessWidget {
  const _MatOption({
    required this.m,
    required this.qtd,
    required this.selected,
    required this.onSelect,
    required this.onQtd,
    required this.unitLabel,
    this.multi = false,
  });

  final MaterialItem m;
  final double? qtd;
  final bool selected;
  final VoidCallback onSelect;
  final ValueChanged<double> onQtd;
  final String unitLabel;
  final bool multi;

  @override
  Widget build(BuildContext context) {
    final c = context.gc;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
      decoration: BoxDecoration(
        color: selected ? c.accentSoft : c.surface2,
        border: Border.all(color: selected ? c.accent : c.line2),
        borderRadius: BorderRadius.circular(GriloRadius.md),
      ),
      child: Row(
        children: [
          InkWell(borderRadius: BorderRadius.circular(GriloRadius.md), onTap: onSelect, child: const MaterialSwatch()),
          const SizedBox(width: 13),
          Expanded(
            child: InkWell(
              onTap: onSelect,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(m.nome, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: c.tx)),
                  Text('${m.marca} · ${fmtBRL(m.custoUnitario)}/$unitLabel', style: TextStyle(fontSize: 12, color: c.tx2)),
                ],
              ),
            ),
          ),
          const SizedBox(width: 13),
          if (selected)
            SizedBox(width: 120, child: NumField(value: qtd ?? 0, onChanged: onQtd, suffix: unitLabel))
          else
            InkWell(
              onTap: onSelect,
              borderRadius: BorderRadius.circular(7),
              child: Container(
                width: 22,
                height: 22,
                alignment: Alignment.center,
                decoration: BoxDecoration(border: Border.all(color: c.line2, width: 1.5), borderRadius: BorderRadius.circular(7)),
                child: multi ? Icon(Icons.add, size: 14, color: c.tx3) : null,
              ),
            ),
        ],
      ),
    );
  }
}

enum _StepState { idle, on, done }

/// `.steps` — horizontal step tracker above the wizard card.
class _StepsTracker extends StatelessWidget {
  const _StepsTracker({required this.steps, required this.current, required this.onTap});

  final List<_StepDef> steps;
  final int current;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final narrow = MediaQuery.sizeOf(context).width < 620;
    return Row(
      children: [
        for (var i = 0; i < steps.length; i++) ...[
          if (i > 0) const SizedBox(width: 8),
          if (narrow)
            _StepChip(
              step: steps[i],
              index: i,
              state: i == current ? _StepState.on : (i < current ? _StepState.done : _StepState.idle),
              narrow: true,
              onTap: () => onTap(i),
            )
          else
            Expanded(
              child: _StepChip(
                step: steps[i],
                index: i,
                state: i == current ? _StepState.on : (i < current ? _StepState.done : _StepState.idle),
                narrow: false,
                onTap: () => onTap(i),
              ),
            ),
        ],
      ],
    );
  }
}

class _StepChip extends StatelessWidget {
  const _StepChip({required this.step, required this.index, required this.state, required this.narrow, required this.onTap});

  final _StepDef step;
  final int index;
  final _StepState state;
  final bool narrow;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.gc;
    var bg = c.surface;
    var border = Border.all(color: c.line);
    if (state == _StepState.on) {
      bg = c.accentSoft;
      border = Border.all(color: c.accent.withValues(alpha: .35));
    }

    var numBg = c.surface2;
    var numFg = c.tx3;
    Border? numBorder = Border.all(color: c.line);
    if (state == _StepState.on) {
      numBg = c.accent;
      numFg = Colors.white;
      numBorder = null;
    } else if (state == _StepState.done) {
      numBg = c.goodSoft;
      numFg = c.good;
      numBorder = null;
    }

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(GriloRadius.md),
      child: InkWell(
        borderRadius: BorderRadius.circular(GriloRadius.md),
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: narrow ? 10 : 14, vertical: narrow ? 10 : 12),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(GriloRadius.md), border: border),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 26,
                height: 26,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: numBg, border: numBorder, borderRadius: BorderRadius.circular(8)),
                child: state == _StepState.done
                    ? Icon(Icons.check, size: 15, color: numFg)
                    : Text('${index + 1}', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: numFg)),
              ),
              if (!narrow) ...[
                const SizedBox(width: 10),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(step.$2, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: c.tx), overflow: TextOverflow.ellipsis),
                      Text('Passo ${index + 1}', style: TextStyle(fontSize: 11, color: c.tx3)),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// `.card.result` — sticky live breakdown panel.
class _ResultPanel extends StatelessWidget {
  const _ResultPanel({required this.engine, required this.res, required this.nomeController, required this.markup});

  final CraftEngineId engine;
  final CalcResult res;
  final TextEditingController nomeController;
  final double markup;

  @override
  Widget build(BuildContext context) {
    final c = context.gc;
    final data = <(String, double, Color)>[
      for (final e in res.breakdown.entries)
        if (e.value > 0.0001) (e.key, e.value, breakdownColors[e.key] ?? c.tx3),
    ];

    return ClipRRect(
      borderRadius: BorderRadius.circular(GriloRadius.lg),
      child: Container(
        decoration: BoxDecoration(
          color: c.surface,
          border: Border.all(color: c.line),
          boxShadow: c.shadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 22, 24, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: nomeController,
                    decoration: InputDecoration(
                      isDense: true,
                      isCollapsed: true,
                      border: InputBorder.none,
                      hintText: 'Nome do orçamento…',
                      hintStyle: TextStyle(color: c.tx3, fontWeight: FontWeight.w600, fontSize: 15),
                    ),
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: c.tx),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    fmtBRL(res.preco),
                    style: TextStyle(fontSize: 38, fontWeight: FontWeight.w800, letterSpacing: -1.14, color: c.tx, fontFeatures: const [FontFeature.tabularFigures()]),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      EngineBadge(engine: engine),
                      const SizedBox(width: 8),
                      Text('preço sugerido', style: TextStyle(fontSize: 13, color: c.tx2)),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 14),
              child: BreakdownBar(data: data),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Column(
                children: [
                  for (final d in data)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 11),
                      child: Row(
                        children: [
                          Container(width: 9, height: 9, decoration: BoxDecoration(color: d.$3, borderRadius: BorderRadius.circular(3))),
                          const SizedBox(width: 12),
                          Expanded(child: Text(d.$1, style: TextStyle(fontSize: 13.5, color: c.tx2))),
                          Text(fmtBRL(d.$2), style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: c.tx, fontFeatures: const [FontFeature.tabularFigures()])),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(border: Border(top: BorderSide(color: c.line))),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Custo total', style: TextStyle(fontSize: 13, color: c.tx2, fontWeight: FontWeight.w600)),
                  Text(fmtBRL(res.custo), style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: c.tx, fontFeatures: const [FontFeature.tabularFigures()])),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 13),
              color: c.goodSoft,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Lucro (${fmtNum(markup)}% markup)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: c.good)),
                  Text('+ ${fmtBRL(res.lucro)}', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: c.good, fontFeatures: const [FontFeature.tabularFigures()])),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
