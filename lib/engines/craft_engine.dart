import '../models/models.dart';

/// Result of a CraftEngine computation: cost breakdown + totals.
class CalcResult {
  const CalcResult({required this.breakdown, required this.custo, required this.preco});

  final Map<String, double> breakdown;
  final double custo;
  final double preco;
  double get lucro => preco - custo;

  static const empty = CalcResult(breakdown: {}, custo: 0, preco: 0);
}

/// Common surface needed by the shared "Risco & precificação" wizard step.
abstract class CalcState {
  double get risco;
  double get markup;
  CalcState withRiscoMarkup({double? risco, double? markup});
}

MaterialItem? matById(List<MaterialItem> materiais, String id) {
  for (final m in materiais) {
    if (m.id == id) return m;
  }
  return null;
}

Maquina? maqById(List<Maquina> maquinas, String id) {
  for (final m in maquinas) {
    if (m.id == id) return m;
  }
  return null;
}

// ── Impressão 3D ──────────────────────────────────────────────────────────

class Print3dState implements CalcState {
  const Print3dState({
    required this.materiais,
    required this.maquina,
    required this.tempoH,
    required this.tempoMin,
    required this.purga,
    required this.posproc,
    required this.posProcMin,
    required this.posProcInsumo,
    required this.posProcInsumoId,
    required this.maoMin,
    required this.setup,
    required this.risco,
    required this.markup,
  });

  factory Print3dState.defaults({double? risco, double? markup}) => Print3dState(
        materiais: const [MatQty(id: 'm1', qtd: 45)],
        maquina: 'mq1',
        tempoH: 4,
        tempoMin: 30,
        purga: 5,
        posproc: false,
        posProcMin: 0,
        posProcInsumo: 0,
        posProcInsumoId: 'm5',
        maoMin: 30,
        setup: 5,
        risco: risco ?? 8,
        markup: markup ?? 120,
      );

  final List<MatQty> materiais; // primeiro item = material principal
  final String maquina; // id da máquina
  final double tempoH; // horas de impressão
  final double tempoMin; // minutos de impressão
  final double purga; // g/ml descartados em purgas
  final bool posproc;
  final double posProcMin; // min de lavagem/cura
  final double posProcInsumo; // ml de insumo (álcool)
  final String posProcInsumoId;
  final double maoMin; // min de mão de obra (setup + acabamento)
  final double setup; // R$ taxa de configuração
  @override
  final double risco; // % risco de falha
  @override
  final double markup; // % markup

  Print3dState copyWith({
    List<MatQty>? materiais,
    String? maquina,
    double? tempoH,
    double? tempoMin,
    double? purga,
    bool? posproc,
    double? posProcMin,
    double? posProcInsumo,
    String? posProcInsumoId,
    double? maoMin,
    double? setup,
    double? risco,
    double? markup,
  }) {
    return Print3dState(
      materiais: materiais ?? this.materiais,
      maquina: maquina ?? this.maquina,
      tempoH: tempoH ?? this.tempoH,
      tempoMin: tempoMin ?? this.tempoMin,
      purga: purga ?? this.purga,
      posproc: posproc ?? this.posproc,
      posProcMin: posProcMin ?? this.posProcMin,
      posProcInsumo: posProcInsumo ?? this.posProcInsumo,
      posProcInsumoId: posProcInsumoId ?? this.posProcInsumoId,
      maoMin: maoMin ?? this.maoMin,
      setup: setup ?? this.setup,
      risco: risco ?? this.risco,
      markup: markup ?? this.markup,
    );
  }

  @override
  CalcState withRiscoMarkup({double? risco, double? markup}) => copyWith(risco: risco, markup: markup);
}

CalcResult computePrint3d(Print3dState s, AppConfig cfg, List<MaterialItem> materiais, List<Maquina> maquinas) {
  final principal = s.materiais.isNotEmpty ? matById(materiais, s.materiais.first.id) : null;

  double mat = 0;
  for (final m in s.materiais) {
    final mt = matById(materiais, m.id);
    if (mt == null) continue;
    mat += custoUnit(mt.preco, mt.qtd) * m.qtd;
  }

  final purgaMat = principal != null ? custoUnit(principal.preco, principal.qtd == 0 ? 1 : principal.qtd) * s.purga : 0.0;

  final maq = maqById(maquinas, s.maquina);
  final horas = s.tempoH + s.tempoMin / 60;
  final energia = cfg.kwhEfetivo * ((maq?.potencia ?? 0) / 1000) * horas;
  final deprec = (maq?.deprecHora ?? 0) * horas;

  double consum = 0;
  if (maq != null && maq.tipo == MaquinaTipo.slaMsla) {
    consum += (maq.telaCusto) / (maq.telaVida == 0 ? 1 : maq.telaVida) * horas;
    consum += (maq.fepCusto) / (maq.fepVida == 0 ? 1 : maq.fepVida);
  }
  if (s.posproc) {
    final ins = matById(materiais, s.posProcInsumoId);
    if (ins != null) consum += custoUnit(ins.preco, ins.qtd) * s.posProcInsumo;
  }

  final maoHoras = (s.maoMin + (s.posproc ? s.posProcMin : 0)) / 60;
  final mao = maoHoras * cfg.maoObra;
  final setup = s.setup;

  final subBase = mat + purgaMat + energia + deprec + consum + mao + setup;
  final risco = subBase * (s.risco / 100);
  final custo = subBase + risco;
  final preco = custo * (1 + s.markup / 100);

  return CalcResult(
    breakdown: {
      'Material': mat + purgaMat,
      'Energia': energia,
      'Consumíveis': consum,
      'Depreciação': deprec,
      'Mão de obra': mao,
      'Setup': setup,
      'Risco': risco,
    },
    custo: custo,
    preco: preco,
  );
}

// ── Crochê ────────────────────────────────────────────────────────────────

class CrocheState implements CalcState {
  const CrocheState({
    required this.fios,
    required this.acessorios,
    required this.tempo,
    required this.energia,
    required this.risco,
    required this.markup,
  });

  factory CrocheState.defaults({double? risco, double? markup}) => CrocheState(
        fios: const [MatQty(id: 'm6', qtd: 120)],
        acessorios: const [MatQty(id: 'm9', qtd: 2)],
        tempo: 6,
        energia: false,
        risco: risco ?? 5,
        markup: markup ?? 110,
      );

  final List<MatQty> fios;
  final List<MatQty> acessorios;
  final double tempo; // horas de produção
  final bool energia;
  @override
  final double risco;
  @override
  final double markup;

  CrocheState copyWith({
    List<MatQty>? fios,
    List<MatQty>? acessorios,
    double? tempo,
    bool? energia,
    double? risco,
    double? markup,
  }) {
    return CrocheState(
      fios: fios ?? this.fios,
      acessorios: acessorios ?? this.acessorios,
      tempo: tempo ?? this.tempo,
      energia: energia ?? this.energia,
      risco: risco ?? this.risco,
      markup: markup ?? this.markup,
    );
  }

  @override
  CalcState withRiscoMarkup({double? risco, double? markup}) => copyWith(risco: risco, markup: markup);
}

CalcResult computeCroche(CrocheState s, AppConfig cfg, List<MaterialItem> materiais) {
  double sumQty(List<MatQty> items) {
    double total = 0;
    for (final m in items) {
      final mt = matById(materiais, m.id);
      if (mt == null) continue;
      total += custoUnit(mt.preco, mt.qtd) * m.qtd;
    }
    return total;
  }

  final fios = sumQty(s.fios);
  final acess = sumQty(s.acessorios);
  final mao = s.tempo * cfg.maoObra;
  final energia = s.energia ? 0.6 : 0.0;

  final subBase = fios + acess + mao + energia;
  final risco = subBase * (s.risco / 100);
  final custo = subBase + risco;
  final preco = custo * (1 + s.markup / 100);

  return CalcResult(
    breakdown: {
      'Fios': fios,
      'Acessórios': acess,
      'Mão de obra': mao,
      'Energia': energia,
      'Risco': risco,
    },
    custo: custo,
    preco: preco,
  );
}
