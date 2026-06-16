# Arquitetura do Projeto

Documento de referencia para compreender a estrutura completa apos a execucao do plano.

---

## Visao Geral

Projeto Godot 4 com implementacao de modelo epidemiologico SEIRD sobre grafos.
Cada "ave" eh um no, conexoes entre nos representam contato direto (transmissivel).
A dinamica de infeccao segue o modelo SEIRD com parametros configuraveis por doenca.

Inclui 3 algoritmos classicos de grafos:
- BFS (propagacao em ondas a partir do paciente zero)
- DFS (trilha de contato a partir do paciente zero)
- Dijkstra (pior cenario - caminho mais distante)

---

## Camadas

### 1. Core (NAO modificar logica existente, mas pode receber metodos novos)
Responsabilidade: estado, logica epidemiologica, visualizacao minima.

| Arquivo | Papel | Interface Publica (todos os metodos adicionados em fases marcados com [N]) |
|---------|-------|-------------------|
| `seird_model.gd` | Logica SEIRD | `initialize()`, `step()`, `vaccinate()`, `isolate_infectious()`, `get_summary()`, `set_initial_infected(ids)` [F3], `agentes`, `adjacencia`, `dia` |
| `graph_generator.gd` | Topologias | `generate(num_nodes, layout) -> Dictionary{adjacency, positions}` |
| `simulation_view.gd` | Renderiza grafo | `passo_concluido`, `surto_encerrado`, `renderizar_estado_atual()`, `atualizar_adjacencia_visual()`, `injetar_autosim()` [F2], `start/pause/resume/stop_autosim()`, `set_speed_autosim()`, `injetar_registry()` [F5] |
| `main_simulation.gd` | Orquestra | Raiz da cena; monta todas as features em runtime via preload |
| `sim_config.gd` | Parametros | `params`, `reset_to_defaults()`, `is_valid()` |
| `hud.gd` | HUD basica | `atualizar_interface()`, sinais de intervencao |
| `metrics_view.gd` | Graficos basicos | `adicionar_ponto_grafico()`, `reset()` |

#### Metodos adicionados ao core (na Fase 1 e fases seguintes):
- `seird_model.gd::vaccinate()` - blindado contra fracao invalida [F1]
- `seird_model.gd::set_initial_infected(ids)` - novo hook publico [F3]
- `seird_model.gd::initialize()` - aceita `params.initial_infected` [F3]
- `simulation_view.gd::injetar_autosim/start/pause/resume/stop_autosim/set_speed_autosim/has_autosim()` - 6 metodos novos [F2]
- `simulation_view.gd::injetar_registry/get_registry()` - 2 metodos novos [F5]
- `main_simulation.gd` - toda a parte de `_montar_auto_sim`, `_montar_manual_infection`, `_montar_graph_registry`, `_montar_dfs`, `_montar_dijkstra` orquestra features sem alterar logica core

### 2. Core Extensions (Features adicionaveis)
Cada feature vive em diretorio proprio e nao depende de outra alem de declaracoes publicas do core.

```
scripts/core_extensions/
  auto_simulation/
    auto_simulation_controller.gd   # F2 - Timer + tick/finished
    control_panel.gd
    control_panel.tscn
  manual_infection/
    infection_selector.gd            # F3 - escolha de pacientes zero
    infection_selector.tscn
  graph_algorithms/
    graph_registry.gd                # F5 - registry nos visuais
    graph_control_panel.gd
    graph_control_panel.tscn
    bfs_runner.gd                    # F6 - BFS puro
    bfs_visualizer.gd
    dfs_runner.gd                    # F7 - DFS puro iterativo
    dfs_visualizer.gd
    dijkstra_runner.gd               # F8 - Dijkstra puro com pesos
    dijkstra_visualizer.gd
```

### 3. Utilities (scripts/utils/)
Scripts de teste/validacao headless, NAO parte da aplicacao.

```
scripts/utils/
  validate_graph.gd          # F1 - grafos gerados corretos
  validate_seird_full.gd     # F1 - SEIRD 30 steps + casos extremos
  validate_autosim.gd        # F2 - 7 cenarios de auto-sim
  validate_manual_infection.gd  # F3 - 4 cenarios de escolha manual
  validate_registry.gd       # F5 - 4 cenarios de registry
  validate_bfs.gd            # F6 - 4 cenarios de BFS
  validate_dfs.gd            # F7 - 3 cenarios de DFS
  validate_dijkstra.gd       # F8 - 3 cenarios de Dijkstra
```

---

## Fluxo de Dados

```
[SimConfig]                                    
   |                                           
   v                                           
[GraphGenerator] --> adjacency + positions --> [SEIRDModel] (estado)
                                              |       |
                                              v       v (no step)
                              [GraphRegistry] <-- core_extensions/graph_algorithms/
                                              |
                       +----------------------+----------------------+
                       v                      v                      v
             [BFSVisualizer]        [DFSVisualizer]       [DijkstraVisualizer]
                       |                      |                      |
                       +-> cor_temporaria()   +-> cor_temporaria()    +-> cor_temporaria() + destacar_caminho()

[SimulationView] <-- [main_simulation orquestra]
   |
   v
[GraphEdit visual]
```

A cada `step()`:
1. SEIRDModel atualiza estados
2. Emite `step_completed(dados)`
3. SimulationView recebe, atualiza cores dos GraphNodes (manda para GraphRegistry guardar cor_base)
4. HUD atualiza labels via main_simulation
5. MetricsView adiciona ponto no grafico

Quando usuario clica "BFS a partir do paciente zero":
1. main_simulation chama BFSVisualizer.preparar(origem)
2. Visualizer chama BFSRunner.executar (calcula niveis/arvore)
3. main_simulation chama avancar() ate terminar
4. Visualizer pinta cor por nivel via GraphRegistry

---

## Convencoes de Codigo

### Nomenclatura
- Classes: PascalCase (via `class_name` ou nome de arquivo)
- Variaveis locais: snake_case (`agente_atual`, `qtde_infectados`)
- Constantes: SCREAMING_SNAKE_CASE
- Enums: PascalCase + valores em CAPS (`Estado.S`, `Estado.I`)

### Tipagem
- Variaveis de membros: tipadas quando possivel (`var _dict: Dictionary = {}`)
- Retornos de funcao: tipados (`-> Dictionary`, `-> void`)
- Parametros: tipados

### Comentarios
- Cabecalho de arquivo: breve descricao do papel
- Codigo autoexplicativo > comentario redundante
- Comentarios inline so em trechos nao obvios

### Estrutura GDScript (referencia geral)
```gdscript
extends BaseClass

# === CONSTANTES ===

# === ESTADO ===

# === SINAIS ===
signal nome_sinal(params: Type)

# === METODOS PUBLICOS ===

# === METODOS PRIVADOS (prefixo _) ===
```

---

## Como Adicionar Nova Feature (template)

1. Criar branch: `git checkout review && git checkout -b feature/nova-coisa`
2. Criar diretorio isolado: `scripts/core_extensions/nova_coisa/`
3. Criar script + cena isolados
4. Se precisar de hook no core: adicionar INTERFACE PUBLICA (sinal/metodo novo). NUNCA modificar logica existente do core
5. Testar com `scripts/utils/validate_<feature>.gd` headless
6. Commits granulares (`feat(nova-coisa): ...`)
7. `git checkout review && git merge feature/nova-coisa`

---

## Como Remover Feature

1. `git checkout review`
2. Localizar commit: `git log --oneline --all` ou buscar hash no CHANGELOG.md
3. `git revert <hash>` ou `git reset --hard <hash-antes-da-feature>`
4. Deletar diretorio `core_extensions/<feature>/`
5. Remover metodos/sinais adicionados ao core (sera trivial pq foram minimos e isolados)

Exemplo para reverter Dijkstra:
```bash
git checkout review
git log --oneline -- scripts/core_extensions/graph_algorithms/dijkstra_runner.gd
# pega o hash do commit
git revert <hash>
rm -rf scripts/core_extensions/graph_algorithms/dijkstra_runner.gd
rm -rf scripts/core_extensions/graph_algorithms/dijkstra_visualizer.gd
# remover tambem a secao "_montar_dijkstra" e constantes no main_simulation.gd
```

---

## Layout da UI

Elementos adicionados via codigo (em main_simulation.gd) na ordem abaixo. Coordenadas aproximadas:

```
   (0,0)┌──────────────────────────────────────────────────┐
        │                                                  │
        │       [ GraphEdit - 1000x700 ]                    │
        │                                                  │
        │                                                  │
        │   [Controles de Grafo: Resetar Grafo]             │  (640, 10)
        │   [Botao] BFS a partir do paciente zero           │  (640, 80)
        │   [Botao] Cancelar BFS                            │  (640, 120)
        │   [Botao] DFS a partir do paciente zero           │  (640, 160)
        │   [Botao] Dijkstra - Pior cenario...              │  (640, 200)
        │   [Label] resultado dijkstra                      │  (640, 240)
        │                                                  │
        │                                  ┌────────────┐  │
        │                                  │  HUD       │  │  (1052, 0)
        │                                  │  [stats]   │  │
        │                                  │  [stats]   │  │
        │                                  │  [vac][iso]│  │
        │                                  └────────────┘  │
        │   [Botao] Escolher Infectados                     │  (1052, 460)
        │   [Panel auto-sim] Play Pause Stop [velocidade]  │  (1052, 500)
        │                                  ┌────────────┐  │
        │                                  │  Metrics   │  │  (1052, 232)
        │                                  │  Grafico   │  │
        │                                  └────────────┘  │
        └──────────────────────────────────────────────────┘
```

---

## Validacao

Todos os 8 testes headless devem passar:
```bash
cd "C:\Users\Leonardo\Documents\ProjetoGrafos\projeto_v_2"
for script in scripts/utils/validate_*.gd; do
  echo "=== $script ==="
  "C:\Program Files\Godot\Godot.exe" --headless --quit --script "$script" 2>&1 | grep -E "OK|FAIL|VALIDATE"
done
"C:\Program Files\Godot\Godot.exe" --headless --quit-after 120   # valida cena principal
```

Todos devem retornar `VALIDATE_*_OK` e cena principal com `EXIT 0` sem erros novos.
