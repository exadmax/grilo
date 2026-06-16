import '../models/models.dart';

/// Seed data ported from data.js — used to initialize app state.

final List<MaterialItem> seedMateriais = [
  const MaterialItem(id: 'm1', nome: 'PLA Vermelho', tipo: TipoMaterial.filamento, marca: '3D Lab', preco: 110, qtd: 1000, estoque: 640),
  const MaterialItem(id: 'm2', nome: 'PLA Preto', tipo: TipoMaterial.filamento, marca: 'Voolt3D', preco: 99, qtd: 1000, estoque: 220),
  const MaterialItem(id: 'm3', nome: 'PETG Translúcido', tipo: TipoMaterial.filamento, marca: '3D Fila', preco: 135, qtd: 1000, estoque: 880),
  const MaterialItem(id: 'm4', nome: 'Resina Cinza ABS', tipo: TipoMaterial.resina, marca: 'Anycubic', preco: 189, qtd: 1000, estoque: 410),
  const MaterialItem(id: 'm5', nome: 'Álcool Isopropílico', tipo: TipoMaterial.consumivelSla, marca: 'Genérico', preco: 28, qtd: 1000, estoque: 1500),
  const MaterialItem(id: 'm6', nome: 'Fio Anne Bege', tipo: TipoMaterial.fioAlgodao, marca: 'Círculo', preco: 9.9, qtd: 65, estoque: 480),
  const MaterialItem(id: 'm7', nome: 'Fio Amigurumi Rosa', tipo: TipoMaterial.fioAlgodao, marca: 'Círculo', preco: 12.5, qtd: 100, estoque: 300),
  const MaterialItem(id: 'm8', nome: 'Lã Mollet Vinho', tipo: TipoMaterial.fioLa, marca: 'Pingouin', preco: 14, qtd: 100, estoque: 200),
  const MaterialItem(id: 'm9', nome: 'Olhos de Segurança 12mm', tipo: TipoMaterial.acessorio, marca: 'Genérico', preco: 18, qtd: 50, estoque: 44),
  const MaterialItem(id: 'm10', nome: 'Enchimento Fibra Siliconada', tipo: TipoMaterial.acessorio, marca: 'Fiber', preco: 32, qtd: 500, estoque: 380),
];

final List<Maquina> seedMaquinas = [
  const Maquina(id: 'mq1', nome: 'Ender 3 V3', tipo: MaquinaTipo.fdm, potencia: 270, custo: 1800, vidaH: 4000),
  const Maquina(id: 'mq2', nome: 'Bambu A1', tipo: MaquinaTipo.fdm, potencia: 350, custo: 4750, vidaH: 5000),
  const Maquina(
    id: 'mq3', nome: 'Mars 4 Ultra', tipo: MaquinaTipo.slaMsla, potencia: 120, custo: 3600, vidaH: 3000,
    telaVida: 2000, telaCusto: 320, fepVida: 60, fepCusto: 45,
  ),
];

const AppConfig seedConfig = AppConfig(
  kwh: 0.92,
  bandeira: Bandeira.amarela,
  icms: 18,
  uf: 'SP',
  maoObra: 25,
  markupPadrao: 120,
  riscoPadrao: 8,
  debitarEstoque: false,
);

final List<Ordem> seedOrdens = [
  Ordem(
    id: 'o1', nome: 'Vaso Espiral G', engine: CraftEngineId.print3d, data: DateTime(2026, 5, 24),
    preco: 84.50, custo: 41.20,
    breakdown: const {'Material': 14.5, 'Energia': 3.1, 'Consumíveis': 0, 'Depreciação': 4.6, 'Mão de obra': 15.0, 'Risco': 4.0},
  ),
  Ordem(
    id: 'o2', nome: 'Amigurumi Raposa', engine: CraftEngineId.croche, data: DateTime(2026, 5, 22),
    preco: 145.00, custo: 62.30,
    breakdown: const {'Fios': 18.3, 'Acessórios': 9.0, 'Mão de obra': 30.0, 'Risco': 5.0},
  ),
  Ordem(
    id: 'o3', nome: 'Suporte Headset', engine: CraftEngineId.print3d, data: DateTime(2026, 5, 20),
    preco: 56.00, custo: 27.80,
    breakdown: const {'Material': 9.8, 'Energia': 2.0, 'Consumíveis': 0, 'Depreciação': 3.0, 'Mão de obra': 10.0, 'Risco': 3.0},
  ),
  Ordem(
    id: 'o4', nome: 'Boneca Amigurumi', engine: CraftEngineId.croche, data: DateTime(2026, 5, 15),
    preco: 198.00, custo: 88.00,
    breakdown: const {'Fios': 26.0, 'Acessórios': 14.0, 'Mão de obra': 42.0, 'Risco': 6.0},
  ),
  Ordem(
    id: 'o5', nome: 'Miniatura Dragão', engine: CraftEngineId.print3d, data: DateTime(2026, 5, 11),
    preco: 120.00, custo: 58.40,
    breakdown: const {'Material': 16.0, 'Energia': 1.4, 'Consumíveis': 12.0, 'Depreciação': 9.0, 'Mão de obra': 16.0, 'Risco': 4.0},
  ),
];
