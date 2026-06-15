# Plano de Melhorias - Projeto SEIRD + Grafos

## Contexto

Projeto Godot implementando modelo SEIRD (Suscetivel-Exposto-Infectado-Recuperado-Morto)
para visualizar dinamica epidemiologica em grafos (galinheiro simulado).

Disciplina: Teoria dos Grafos.

Objetivo duplo:
1. Simular surto epidemiologico real
2. Demonstrar algoritmos classicos de grafos (BFS, DFS, Dijkstra) aplicados a este contexto

---

## Principios Arquiteturais

### A) Isolamento de Features
- Cada feature = diretorio proprio em `scripts/core_extensions/<feature>/`
- Features NAO modificam arquivos do `core/` exceto por minima interface publica
- Remover feature = deletar diretorio + reverter commits

### B) Codigo Limpo
- Sem complexidade alem da necessaria
- Padroes Godot 4: typing explicito, snake_case para variaveis, PascalCase para classes
- Comentarios breves em trechos nao obvios
- Foco em legibilidade, nao otimizacao prematura

### C) Commits Granulares
- 1 commit por mudanca atomica
- Mensagens no padrao `<tipo>: <descricao concisa>`
- Tipos: `feat`, `fix`, `refactor`, `docs`, `test`

### D) Git Local Exclusivo
- Branches: `review` (base), `feature/<nome>` (por feature)
- NUNCA fazer push sem autorizacao explicita do usuario
- Merge em `review` so apos feature validada

---

## Estrutura de Diretorios Proposta

Estrutura proposta (FINAL = descrita em `docs/ARCHITECTURE.md`):
- Core scripts permanecem em `scripts/` (preservar UIDs das cenas)
- Features em `scripts/core_extensions/<feature>/`
- Sem sub-diretorios `core/` ou `scenes/features/` reais (sao apenas scaffolding)

```
res://
scripts/
  # CORE - logica existente preservada, nao foi movida
  seird_model.gd
  graph_generator.gd
  simulation_view.gd
  main_simulation.gd
  sim_config.gd
  hud.gd
  metrics_view.gd

  core_extensions/               # FEATURES ISOLADAS - adicionaveis
    auto_simulation/             # F2
      auto_simulation_controller.gd
      control_panel.gd
      control_panel.tscn
    manual_infection/            # F3
      infection_selector.gd
      infection_selector.tscn
    graph_algorithms/            # F5, F6, F7, F8
      graph_registry.gd          #   F5
      graph_control_panel.gd     #   F5
      graph_control_panel.tscn   #   F5
      bfs_runner.gd              #   F6
      bfs_visualizer.gd          #   F6
      dfs_runner.gd              #   F7
      dfs_visualizer.gd          #   F7
      dijkstra_runner.gd         #   F8
      dijkstra_visualizer.gd     #   F8

  utils/                         # testes headless (NAO parte da app)
    validate_*.gd

scenes/
  mainSimulation.tscn            # cena principal
  simulationView.tscn
  hud.tscn
  metricsView.tscn
  relatorio.tscn
```

NOTA: A Fase 4 (mode switcher / modo dual) e os diretorios `mode_switcher/` e
`play_pause_stop/` planejados originalmente NAO foram implementados — os algoritmos
funcionam sem troca de aba. Ver `docs/CHANGELOG.md` (secao "Roadmap completo")
para justificativa. Os diretorios `scripts/core_extensions/mode_switcher/` e
`scripts/core_extensions/play_pause_stop/` existem apenas como `.gitkeep` (vazios)
para preservar o espaco no git; podem ser apagados sem efeito.

---

## Fases de Implementacao

### FASE 1: Correcao de Bugs Criticos
**Branch:** `bugfix/critical`
**Base:** `review`

Bugs a corrigir (lista completa abaixo):
- [ ] Remover `print()` debug em `graph_generator.gd:18,33`
- [ ] Validar array vazio em `seird_model.gd:138-141`
- [ ] Validar `qtde_femeas <= num_agents` em `seird_model.gd:113`
- [ ] Sincronizar `parametros_globais` em `main_simulation.gd`
- [ ] Descomentar/desativar linhas comentadas em `main_simulation.gd:32,53`
- [ ] Validar `is_instance_valid` em `simulation_view.gd:126-132`
- [ ] Validar `_check_outbreak_over()` antes de usar em `simulation_view.gd:108`
- [ ] Tratar `num_nodes <= 0` em `graph_generator.gd:10`
- [ ] Evitar grafo duplicado em `_garantir_conectividade`
- [ ] Validar `viz.weight` em `_get_infection_prob`

### FASE 2: Simulacao Automatica + Play/Pause/Stop
**Branch:** `feature/auto-sim`
**Depende:** Fase 1

**Arquivos novos:**
- `scripts/core_extensions/play_pause_stop/play_pause_panel.gd`
- `scripts/core_extensions/play_pause_stop/play_pause_panel.tscn`
- `scripts/core_extensions/auto_simulation/simulation_runner.gd`

**Core modificado (minimo):**
- `simulation_view.gd`: adicionar hooks publicos para start/pause/stop
- `hud.gd`: adicionar 3 botoes (Play, Pause, Stop)

**Isolamento:** sem play_pause_stop/ folder, controles manuais de passo funcionam normalmente.

### FASE 3: Manipulacao Manual de Infectados
**Branch:** `feature/manual-infection`
**Depende:** Fase 1

**Arquivos novos:**
- `scripts/core_extensions/manual_infection/infect_selection.gd`
- `scripts/core_extensions/manual_infection/infect_selection.tscn`

**Core modificado (minimo):**
- `seird_model.gd`: adicionar metodo `set_initial_infected(ids: Array)` + parametro opcional em `initialize()`
- `sim_config.gd`: adicionar `initial_infected: Array`

**Isolamento:** se remover, apenas deletar pasta + remover param do initialize.

### FASE 4: Modo Dual (Simulacao | Grafo)
**Branch:** `feature/mode-switcher`
**Depende:** Fase 2

**Arquivos novos:**
- `scripts/core_extensions/mode_switcher/mode_switcher.gd`
- `scripts/core_extensions/mode_switcher/mode_switcher.tscn`

**Core modificado (minimo):**
- `main_simulation.gd`: integrar mode_switcher (adicionar como filho)
- `simulation_view.gd`: expor sinais publicos de modo

**Funcionalidade:** Tab/aba alterna entre:
- Modo A: Simulacao (HUD + metrics normais)
- Modo B: Grafo (esconde HUD SEIRD, mostra controles de algoritmo)

### FASE 5: Reset Visual do Grafo + Botao Limpar
**Branch:** `feature/graph-controls`
**Depende:** Fase 2 (reusa play/pause/stop)

**Arquivos novos:**
- `scripts/core_extensions/graph_algorithms/graph_control_panel.gd`
- `scripts/core_extensions/graph_algorithms/graph_control_panel.tscn`

**Core modificado:** nenhum
**Funcionalidade:** Painel com botao "Resetar Grafos" - limpa todos os highlights visuais de algoritmos anteriores.

### FASE 6: BFS - Propagacao em Ondas
**Branch:** `feature/bfs`
**Depende:** Fase 4 + 5

**Arquivos novos:**
- `scripts/core_extensions/graph_algorithms/bfs_visualizer.gd`
- `scripts/core_extensions/graph_algorithms/bfs_runner.gd`

**Funcionalidade:**
- Botao "Executar BFS" no modo grafo
- Recebe no inicial (paciente zero ou selecionado)
- Marca nos por nivel (frame temporal) - cor propria por nivel
- Animacao controlada pelos controles universais (play/pause/stop da Fase 2)

### FASE 7: DFS - Trilha de Contato
**Branch:** `feature/dfs`
**Depende:** Fase 4 + 5

**Arquivos novos:**
- `scripts/core_extensions/graph_algorithms/dfs_visualizer.gd`
- `scripts/core_extensions/graph_algorithms/dfs_runner.gd`

**Funcionalidade:**
- Clique em no infectado no modo grafo
- Botao "Executar DFS"
- Anima caminho percorrido no a no, destacando cadeia
- Reusa controles universais

### FASE 8: Dijkstra - Pior Cenario
**Branch:** `feature/dijkstra`
**Depende:** Fase 4 + 5 + 6 (BFS)

**Arquivos novos:**
- `scripts/core_extensions/graph_algorithms/dijkstra_visualizer.gd`
- `scripts/core_extensions/graph_algorithms/dijkstra_runner.gd`

**Funcionalidade:**
- Botao "Pior Cenario (Dijkstra)" no modo grafo
- Calcula menor caminho (em hops) do paciente zero ate no mais distante
- Destaca caminho final com cor propria
- Reusa controles universais

---

## Mapa de Dependencias (REAL - implementada)

```
Fase 1 (bugs) <- BASE ESTAVEL
   |
   +--> Fase 2 (auto-sim + controles) <-+
   |                                    |
   +--> Fase 3 (manual infection) [independente]
   |
   +--> Fase 5 (graph registry + reset) <-+
                                         |
                                         +--> Fase 6 (BFS)
                                         +--> Fase 7 (DFS)
                                         +--> Fase 8 (Dijkstra)

OBS: Fase 4 (modo dual) NAO implementada - ver nota de estrutura.
```

OBS2: o grafo original previa dependência "Fase 6/7/8 dependem de Fase 4 + 5" mas a Fase 4
foi desconsiderada na execução real porque os botões dos algoritmos funcionam sem troca
de aba (a UI foi adaptada para ter todos botoes visíveis lado a lado).

---

## Como Remover uma Feature

```bash
# Manual:
git checkout review
git branch backup
git log --oneline --all              # localizar commit da feature
git revert <hash-do-commit>

# Ou reset:
git reset --hard <hash-antes-da-feature>

# Depois deleta arquivos:
rm -rf scripts/core_extensions/graph_algorithms/bfs_*
```

---

## Testes por Feature

Cada fase so eh marcada como concluida apos:
1. Sintaxe verificada (godot --check-only se disponivel)
2. Cenarios principais executados sem crash
3. Logs do console sem erros/warnings novos
4. Commit feito na branch correta
5. Merge em `review` sem conflitos

---

## Cenarios de Teste (resumo)

### Fase 1 (bugs)
- [ ] Simular com `num_agents=0` → nao crasha
- [ ] Simular com `num_females > num_agents` → clampa
- [ ] Console limpo durante simulacao normal

### Fase 2 (auto-sim)
- [ ] Play inicia timer, avanca passos automaticamente
- [ ] Pause para timer, retoma de onde parou
- [ ] Stop reseta timer

### Fase 3 (manual infection)
- [ ] Painel lista todos os agentes
- [ ] Marcar X agentes → confirmar → X ficam infectados
- [ ] Marcar 0 agentes → comportamento padrao (1 aleatorio)

### Fases 6/7/8 (algoritmos)
- [ ] BFS: rodar sobre grafo 10+ nos, ver animacao por nivel
- [ ] DFS: clique em no + executar → caminho animado
- [ ] Dijkstra: executar → menor caminho destacado
- [ ] Reset: limpar todos os highlights
