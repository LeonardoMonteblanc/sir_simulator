# Arquitetura do Projeto

Documento de referencia para compreender a estrutura completa apos a execucao do plano.

---

## Visao Geral

Projeto Godot 4 com implementacao de modelo epidemiologico SEIRD sobre grafos.
Cada "ave" eh um no, conexoes entre nos representam contato direto (transmissivel).
A dinamica de infeccao segue o modelo SEIRD com parametros configuraveis por doenca.

---

## Camadas

### 1. Core (NUNCA modificar/quebrar)
Responsabilidade: estado, logica epidemiologica, visualizacao minima.

| Arquivo | Papel | Interface Publica |
|---------|-------|-------------------|
| `seird_model.gd` | Logica SEIRD | `initialize()`, `step()`, `vaccinate()`, `isolate_infectious()`, `set_initial_infected()` (Fase 3), `agentes`, `adjacencia`, `dia` |
| `graph_generator.gd` | Gera topologias | `generate(num_nodes, layout) -> Dictionary{adjacency, positions}` |
| `simulation_view.gd` | Renderiza grafo | `passo_concluido`, `surto_encerrado`, `renderizar_estado_atual()`, `atualizar_adjacencia_visual()` |
| `main_simulation.gd` | Orquestra | raiz da cena |
| `sim_config.gd` | Parametros | `params`, `reset_to_defaults()`, `is_valid()` |
| `hud.gd` | HUD basica | `atualizar_interface()`, sinais de intervencao |
| `metrics_view.gd` | Graficos basicos | `adicionar_ponto_grafico()`, `reset()` |

### 2. Core Extensions (Features adicionaveis)
Cada feature vive em diretorio proprio e nao depende de outra alem de declaracoes publicas do core.

| Feature | Diretorio | Proposito |
|---------|-----------|-----------|
| Auto Simulacao | `core_extensions/auto_simulation/` | Timer + auto-step |
| Controles | `core_extensions/play_pause_stop/` | Botoes Play/Pause/Stop |
| Manual Infection | `core_extensions/manual_infection/` | UI para escolher infectados |
| Mode Switcher | `core_extensions/mode_switcher/` | Alterna modo simulacao/grafo |
| Algoritmos | `core_extensions/graph_algorithms/` | BFS, DFS, Dijkstra + reset panel |

---

## Fluxo de Dados

```
[SimConfig]
   |
   v
[GraphGenerator] --> adjacency + positions --> [SEIRDModel] (estado)
   |                       |
   v                       v
[SimulationView] <-- [main_simulation orquestra]
   |
   v
[GraphEdit visual]
```

A cada `step()`:
1. SEIRDModel atualiza estados
2. Emite `step_completed(dados)`
3. SimulationView recebe, atualiza cores dos GraphNodes
4. HUD atualiza labels
5. MetricsView adiciona ponto no grafico

---

## Convencoes de Codigo

### Nomenclatura
- Classes: PascalCase (`SEIRDModel`, `GraphGenerator`)
- Variaveis locais: snake_case (`agente_atual`, `qtde_infectados`)
- Constantes: SCREAMING_SNAKE_CASE
- Enums: PascalCase + valores em CAPS (`Estado.S`, `Estado.I`)

### Tipagem
- Variaveis de classe: tipadas quando possivel
- Retornos de funcao: tipados
- Parametros: tipados quando nao vem do editor

### Comentarios
- Cabecalho de arquivo: breve descricao do papel
- Comentarios inline: apenas em trechos nao obvios
- Codigo autoexplicativo > comentario redundante

### Estrutura GDScript
```gdscript
class_name NomeClasse
extends BaseClass

# === CONSTANTES ===

# === ESTADO ===

# === SINAIS ===
signal nome_sinal(params: Type)

# === METODOS PUBLICOS ===

# === METODOS PRIVADOS (prefixo _ ou func privada) ===
```

---

## Como Adicionar Nova Feature (template)

1. Criar branch: `git checkout review && git checkout -b feature/nova-coisa`
2. Criar diretorio: `scripts/core_extensions/nova-coisa/`
3. Criar script + cena isolados
4. Se precisar de hook no core, adicionar INTERFACE PUBLICA (sinal ou metodo novo)
   - Nunca modificar logica existente do core
5. Testar localmente
6. Commits granulares
7. Merge em review

---

## Como Remover Feature

1. `git checkout review`
2. Localizar commit: `git log --oneline --all`
3. `git revert <hash>` ou `git reset --hard <hash-pre>`
4. Deletar diretorio `core_extensions/<feature>/`
5. Se hook foi adicionado no core, remover manualmente (sera trivial pq sao minimos)

---

## Modo Dual (futuro - Fase 4)

Apos implementacao:
- Modo Simulacao: comportamento atual (HUD SEIRD, botoes de intervencao)
- Modo Grafo: HUD SEIRD escondida, controles de algoritmos visiveis
- Alternancia via aba/botao
- BFS/DFS/Dijkstra so funcionam no Modo Grafo
