import 'package:flutter/material.dart';

/// Material types -> label, base unit, which engines consume them.
enum TipoMaterial {
  filamento,
  resina,
  consumivelSla,
  fioAlgodao,
  fioLa,
  acessorio,
  agulha,
}

extension TipoMaterialX on TipoMaterial {
  String get label => switch (this) {
        TipoMaterial.filamento => 'Filamento',
        TipoMaterial.resina => 'Resina',
        TipoMaterial.consumivelSla => 'Consumível SLA',
        TipoMaterial.fioAlgodao => 'Fio de algodão',
        TipoMaterial.fioLa => 'Fio de lã',
        TipoMaterial.acessorio => 'Acessório',
        TipoMaterial.agulha => 'Agulha',
      };

  /// Base unit (g, ml, un...).
  String get unidade => switch (this) {
        TipoMaterial.filamento => 'g',
        TipoMaterial.resina => 'ml',
        TipoMaterial.consumivelSla => 'ml',
        TipoMaterial.fioAlgodao => 'g',
        TipoMaterial.fioLa => 'g',
        TipoMaterial.acessorio => 'un',
        TipoMaterial.agulha => 'un',
      };

  List<CraftEngineId> get engines => switch (this) {
        TipoMaterial.filamento || TipoMaterial.resina || TipoMaterial.consumivelSla => [CraftEngineId.print3d],
        TipoMaterial.fioAlgodao ||
        TipoMaterial.fioLa ||
        TipoMaterial.acessorio ||
        TipoMaterial.agulha =>
          [CraftEngineId.croche],
      };
}

/// CraftEngine ids — each is an independent calculator module.
enum CraftEngineId { print3d, croche }

extension CraftEngineIdX on CraftEngineId {
  String get nome => switch (this) {
        CraftEngineId.print3d => 'Impressão 3D',
        CraftEngineId.croche => 'Crochê',
      };

  String get desc => switch (this) {
        CraftEngineId.print3d => 'Filamento (FDM) e resina (SLA/MSLA)',
        CraftEngineId.croche => 'Fios, agulhas e acessórios',
      };

  IconData get icon => switch (this) {
        CraftEngineId.print3d => Icons.print_outlined,
        CraftEngineId.croche => Icons.timeline_outlined,
      };

  Color get dotColor => switch (this) {
        CraftEngineId.print3d => const Color(0xFF6AA9E0),
        CraftEngineId.croche => const Color(0xFFD68AB0),
      };
}

/// Bandeiras tarifárias (adicional em R$/kWh) — referência ANEEL.
enum Bandeira { verde, amarela, vermelha1, vermelha2 }

extension BandeiraX on Bandeira {
  String get label => switch (this) {
        Bandeira.verde => 'Verde',
        Bandeira.amarela => 'Amarela',
        Bandeira.vermelha1 => 'Vermelha P1',
        Bandeira.vermelha2 => 'Vermelha P2',
      };

  double get add => switch (this) {
        Bandeira.verde => 0,
        Bandeira.amarela => 0.01885,
        Bandeira.vermelha1 => 0.04463,
        Bandeira.vermelha2 => 0.07877,
      };

  Color get color => switch (this) {
        Bandeira.verde => const Color(0xFF4CC38A),
        Bandeira.amarela => const Color(0xFFE0A23E),
        Bandeira.vermelha1 => const Color(0xFFE5573F),
        Bandeira.vermelha2 => const Color(0xFFC0392B),
      };
}

/// Sugestão de ICMS por UF (%).
const Map<String, double> icmsUf = {
  'SP': 18, 'RJ': 20, 'MG': 18, 'RS': 30, 'PR': 19, 'SC': 17,
  'BA': 20.5, 'PE': 18, 'CE': 20, 'GO': 19, 'DF': 20, 'ES': 17,
  'PA': 25, 'AM': 20,
};

double custoUnit(double preco, double qtd) => qtd > 0 ? preco / qtd : 0;

/// Unified material registry entry — shared between engines.
@immutable
class MaterialItem {
  const MaterialItem({
    required this.id,
    required this.nome,
    required this.tipo,
    required this.marca,
    required this.preco,
    required this.qtd,
    required this.estoque,
  });

  final String id;
  final String nome;
  final TipoMaterial tipo;
  final String marca;
  final double preco;
  final double qtd;
  final double estoque;

  double get custoUnitario => custoUnit(preco, qtd);
  bool get estoqueBaixo => estoque < qtd * 0.25;

  MaterialItem copyWith({
    String? id,
    String? nome,
    TipoMaterial? tipo,
    String? marca,
    double? preco,
    double? qtd,
    double? estoque,
  }) {
    return MaterialItem(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      tipo: tipo ?? this.tipo,
      marca: marca ?? this.marca,
      preco: preco ?? this.preco,
      qtd: qtd ?? this.qtd,
      estoque: estoque ?? this.estoque,
    );
  }
}

enum MaquinaTipo { fdm, slaMsla }

extension MaquinaTipoX on MaquinaTipo {
  String get label => switch (this) {
        MaquinaTipo.fdm => 'FDM',
        MaquinaTipo.slaMsla => 'SLA-MSLA',
      };
}

/// Printer / machine registry entry.
@immutable
class Maquina {
  const Maquina({
    required this.id,
    required this.nome,
    required this.tipo,
    required this.potencia,
    required this.custo,
    required this.vidaH,
    this.telaVida = 0,
    this.telaCusto = 0,
    this.fepVida = 0,
    this.fepCusto = 0,
  });

  final String id;
  final String nome;
  final MaquinaTipo tipo;
  final double potencia; // W
  final double custo; // R$
  final double vidaH; // horas de vida útil
  final double telaVida; // SLA: vida da tela LCD (h)
  final double telaCusto; // SLA: custo da tela LCD
  final double fepVida; // SLA: vida do filme FEP (impressões)
  final double fepCusto; // SLA: custo do FEP

  /// Depreciação por hora derivada do valor da máquina / vida útil.
  double get deprecHora => vidaH > 0 ? custo / vidaH : 0;

  Maquina copyWith({
    String? id,
    String? nome,
    MaquinaTipo? tipo,
    double? potencia,
    double? custo,
    double? vidaH,
    double? telaVida,
    double? telaCusto,
    double? fepVida,
    double? fepCusto,
  }) {
    return Maquina(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      tipo: tipo ?? this.tipo,
      potencia: potencia ?? this.potencia,
      custo: custo ?? this.custo,
      vidaH: vidaH ?? this.vidaH,
      telaVida: telaVida ?? this.telaVida,
      telaCusto: telaCusto ?? this.telaCusto,
      fepVida: fepVida ?? this.fepVida,
      fepCusto: fepCusto ?? this.fepCusto,
    );
  }
}

/// Global fixed configuration (energy tariff, labor rate, pricing defaults).
@immutable
class AppConfig {
  const AppConfig({
    required this.kwh,
    required this.bandeira,
    required this.icms,
    required this.uf,
    required this.maoObra,
    required this.markupPadrao,
    required this.riscoPadrao,
    required this.debitarEstoque,
  });

  final double kwh; // R$ por kWh (base)
  final Bandeira bandeira;
  final double icms; // %
  final String uf;
  final double maoObra; // R$ por hora padrão
  final double markupPadrao; // %
  final double riscoPadrao; // %
  final bool debitarEstoque;

  /// kWh efetivo = (base + bandeira) com ICMS embutido.
  double get kwhEfetivo => (kwh + bandeira.add) * (1 + icms / 100);

  AppConfig copyWith({
    double? kwh,
    Bandeira? bandeira,
    double? icms,
    String? uf,
    double? maoObra,
    double? markupPadrao,
    double? riscoPadrao,
    bool? debitarEstoque,
  }) {
    return AppConfig(
      kwh: kwh ?? this.kwh,
      bandeira: bandeira ?? this.bandeira,
      icms: icms ?? this.icms,
      uf: uf ?? this.uf,
      maoObra: maoObra ?? this.maoObra,
      markupPadrao: markupPadrao ?? this.markupPadrao,
      riscoPadrao: riscoPadrao ?? this.riscoPadrao,
      debitarEstoque: debitarEstoque ?? this.debitarEstoque,
    );
  }
}

/// A saved budget/order in the history.
@immutable
class Ordem {
  const Ordem({
    required this.id,
    required this.nome,
    required this.engine,
    required this.data,
    required this.preco,
    required this.custo,
    required this.breakdown,
  });

  final String id;
  final String nome;
  final CraftEngineId engine;
  final DateTime data;
  final double preco;
  final double custo;
  final Map<String, double> breakdown;

  double get lucro => preco - custo;
}

/// A material reference with a quantity (used inside calc states).
@immutable
class MatQty {
  const MatQty({required this.id, required this.qtd});
  final String id;
  final double qtd;

  MatQty copyWith({String? id, double? qtd}) => MatQty(id: id ?? this.id, qtd: qtd ?? this.qtd);
}
