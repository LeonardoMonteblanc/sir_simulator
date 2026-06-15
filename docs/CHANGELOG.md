# Changelog

Registro de todas as mudancas feitas no projeto pelas fases do plano.
Formato: data, fase, branch, commits, resumo.

---

## [Pendente - Pre-Fase 1]

### Backup Inicial
- Documentos criados: PLANO.md, CHANGELOG.md, ARCHITECTURE.md
- Branch base: `review`
- Working tree limpo

---

## Fase 1 - Correcao de Bugs Criticos (CONCLUIDA)
**Branch:** `bugfix/critical` -> mergeada em `review`
**Status:** CONCLUIDA

### Commits:
- `bbd16c0` fix(graph_generator): remove debug prints, valida num_nodes<=0, evita arestas duplicadas
- `434aa44` fix(seird_model): valida num_females, robustez em _get_infection_prob, vaccinate seguro
- `c4e4cbb` fix(main_simulation): corrige caminho de node, sincroniza params, ativa metrics_view, is_instance_valid guards
- `b49d128` fix(simulation_view): is_instance_valid, renderizar_estado_atual restaura conexoes

### Testes adicionados:
- scripts/utils/validate_graph.gd: grafos (single/two_poles/free_range) todos conectados
- scripts/utils/validate_seird_full.gd: 30 steps Newcastle, c2 num_agents=0, c3 clamp fem, c4 vaccinate

---

## Fase 2 - Simulacao Automatica + Play/Pause/Stop (CONCLUIDA)
**Branch:** `feature/auto-sim` -> mergeada em `review`

### Commits:
- `feat(auto-sim): controller Timer play/pause/stop + panel UI + injecao opcional na view`

### Arquivos criados:
- `scripts/core_extensions/auto_simulation/auto_simulation_controller.gd`: Timer Node com start/pause/resume/stop/set_speed + signal tick + finished
- `scripts/core_extensions/auto_simulation/control_panel.gd`: UI botoes play/pause/stop + slider velocidade com feedback
- `scripts/core_extensions/auto_simulation/control_panel.tscn`: cena do painel

### Core modificado (interface minima):
- `simulation_view.gd`: hooks publicos injetar_autosim/start_autosim/pause_autosim/resume_autosim/stop_autosim/set_speed_autosim/has_autosim
- `main_simulation.gd`: monta controller + panel em runtime, conecta sinais

### Teste:
- scripts/utils/validate_autosim.gd: 7 cenarios (start, ticks, pause, resume, set_speed, stop, finished) - todos OK

---

## Fase 3 - Manipulacao Manual de Infectados (CONCLUIDA)
**Branch:** `feature/manual-infection` -> mergeada em `review`

### Commits:
- `feat(manual_infection): UI para escolher pacientes zero + set_initial_infected no model`

### Arquivos criados:
- `scripts/core_extensions/manual_infection/infection_selector.gd`: panel com checkboxes, sinais confirmar/cancelar
- `scripts/core_extensions/manual_infection/infection_selector.tscn`: cena com grid + botoes

### Core modificado:
- `seird_model.gd`: novo hook `set_initial_infected(ids)` + suporte a `params.initial_infected` no initialize

### Teste:
- scripts/utils/validate_manual_infection.gd: 4 cenarios (lista pre-definida, fallback aleatorio, lista vazia, ids invalidos) - OK

---

## Fase 5 - Graph Registry + Reset (CONCLUIDA)
**Branch:** `feature/graph-controls` -> mergeada em `review`

### Commits:
- `feat(graph-controls): registry de nos + painel reset (base para algoritmos)`

### Arquivos criados:
- `scripts/core_extensions/graph_algorithms/graph_registry.gd`: Node que registra id->GraphNode, gerencia cores SEIRD base + cores de algoritmo (temporarias), destaca caminhos
- `scripts/core_extensions/graph_algorithms/graph_control_panel.gd`: botao reset
- `scripts/core_extensions/graph_algorithms/graph_control_panel.tscn`: cena do painel

### Core modificado:
- `simulation_view.gd`: hook `injetar_registry()` + registro automatico de nos no construir_grafo

### Teste:
- scripts/utils/validate_registry.gd: 4 cenarios - OK

---

## Fase 6 - BFS - Propagacao em Ondas (CONCLUIDA)
**Branch:** `feature/bfs` -> mergeada em `review`

### Commits:
- `feat(bfs): runner puro + visualizador + botao na cena`

### Arquivos criados:
- `scripts/core_extensions/graph_algorithms/bfs_runner.gd`: BFS que retorna niveis/ordem_visita/arvore (static, testa headless)
- `scripts/core_extensions/graph_algorithms/bfs_visualizer.gd`: aplica cor por nivel de onda

### Integracao:
- `main_simulation.gd`: cria BFSVisualizer, botoes "BFS a partir do paciente zero" + "Cancelar BFS"

### Teste:
- scripts/utils/validate_bfs.gd: 4 cenarios (arvore, ciclo, desconexo, adj formato int) - OK

---

## Fase 7 - DFS - Trilha de Contato (CONCLUIDA)
**Branch:** `feature/dfs` -> mergeada em `review`

### Commits:
- `feat(dfs): runner iterativo + visualizador + botao + caminho_para`

### Arquivos criados:
- `scripts/core_extensions/graph_algorithms/dfs_runner.gd`: DFS iterativo (sem stack overflow), retorna ordem_visita/arvore, helper caminho_para(dest)
- `scripts/core_extensions/graph_algorithms/dfs_visualizer.gd`: aplica cor por passo + destaca caminho especifico

### Integracao:
- `main_simulation.gd`: cria DFSVisualizer, botao "DFS a partir do paciente zero"

### Teste:
- scripts/utils/validate_dfs.gd: 3 cenarios (arvore, caminho_para, ciclo) - OK

---

## Fase 8 - Dijkstra - Pior Cenario (CONCLUIDA)
**Branch:** `feature/dijkstra` -> mergeada em `review`

### Commits:
- `feat(dijkstra): runner com pesos + visualizador + botao`

### Arquivos criados:
- `scripts/core_extensions/graph_algorithms/dijkstra_runner.gd`: Dijkstra com fila de prioridade (array ordenado), suporta pesos nas arestas, retorna distancias/predecessores/pior_caminho
- `scripts/core_extensions/graph_algorithms/dijkstra_visualizer.gd`: destaca caminho com cor verde + redesenha arestas

### Integracao:
- `main_simulation.gd`: cria DijkstraVisualizer, botao + label com texto do resultado "orig X -> Y (dist Z) caminho: ..."

### Teste:
- scripts/utils/validate_dijkstra.gd: 3 cenarios (arvore, pesos, reconstruir caminho) - OK

---

## Status Final

### Branch `review` contem:
- Fase 1: 4 commits de bugfix
- Fase 2: 1 commit (auto-sim)
- Fase 3: 1 commit (manual infection)
- Fase 5: 1 commit (graph controls)
- Fase 6: 1 commit (BFS)
- Fase 7: 1 commit (DFS)
- Fase 8: 1 commit (Dijkstra)
- Docs iniciais: 2 commits

### Total: 12 commits locais, todos em `review`, NUNCA pushados para origin.

### Quantidade de testes:
- validate_graph.gd
- validate_seird_full.gd
- validate_autosim.gd
- validate_manual_infection.gd
- validate_registry.gd
- validate_bfs.gd
- validate_dfs.gd
- validate_dijkstra.gd
- TOTAL: 8 utilities de teste

### Procedimento para rodar validacoes:
```bash
cd "C:\Users\Leonardo\Documents\ProjetoGrafos\projeto_v_2"
"C:\Program Files\Godot\Godot.exe" --headless --quit --script scripts/utils/validate_graph.gd
"C:\Program Files\Godot\Godot.exe" --headless --quit --script scripts/utils/validate_seird_full.gd
"C:\Program Files\Godot\Godot.exe" --headless --quit --script scripts/utils/validate_autosim.gd
"C:\Program Files\Godot\Godot.exe" --headless --quit --script scripts/utils/validate_manual_infection.gd
"C:\Program Files\Godot\Godot.exe" --headless --quit --script scripts/utils/validate_registry.gd
"C:\Program Files\Godot\Godot.exe" --headless --quit --script scripts/utils/validate_bfs.gd
"C:\Program Files\Godot\Godot.exe" --headless --quit --script scripts/utils/validate_dfs.gd
"C:\Program Files\Godot\Godot.exe" --headless --quit --script scripts/utils/validate_dijkstra.gd
"C:\Program Files\Godot\Godot.exe" --headless --quit-after 120   # valida cena principal inteira
```

### Como reverter:
- Cada fase tem branch propria (deletada). Para reverter:
  - `git revert <hash>` do commit da fase
  - ou `git reset --hard <hash-antes-da-fase>`
- Core scripts `seird_model.gd`, `simulation_view.gd`, `graph_generator.gd`, `main_simulation.gd`, `sim_config.gd`, `hud.gd`, `metrics_view.gd` ficaram em `scripts/` (sem mover) para preservar UIDs das cenas. EFEITO: para reverter modificacoes no core, olhar `git log scripts/seird_model.gd` etc.
