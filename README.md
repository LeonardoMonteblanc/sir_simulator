# SEIRD Graph Simulator

Visualizador epidemiologico SEIRD (Suscetivel - Exposto - Infectado - Recuperado - Morto)
sobre grafos, com algoritmos classicos de busca (BFS, DFS, Dijkstra) aplicados a
cadeia de contagio. Projeto academico da disciplina de Teoria dos Grafos.

Desenvolvido em Godot 4.6 com GDScript, sem plugins externos, sem dependencias
nativas alem da engine.

---

## Indice

1. [O que o projeto faz](#o-que-o-projeto-faz)
2. [Instalacao e execucao](#instalacao-e-execucao)
3. [Documentacao tecnica](#documentacao-tecnica)
4. [Controles e interface](#controles-e-interface)
5. [Arquitetura](#arquitetura)
6. [Algoritmos de grafos](#algoritmos-de-grafos)
7. [Testes](#testes)
8. [Git workflow](#git-workflow)
9. [Roadmap completo](#roadmap-completo)
10. [Notas finais](#notas-finais)

---

## O que o projeto faz

Simula a propagacao de uma doenca infecciosa em uma populacao de "aves" (no
academico) que se misturam em um galinheiro simulado. Cada ave eh um no do grafo;
arestas representam contato direto capaz de transmitir a doenca.

A dinamica segue o modelo SEIRD padrao:
- **S**: suscetivel (pode pegar)
- **E**: exposto (em periodo de latencia)
- **I**: infectado (transmitindo)
- **R**: recuperado (imunizado)
- **D**: morto

### Features implementadas

| Feature | Descricao | Branch |
|---------|-----------|--------|
| Simulacao manual | Passo a passo via botao | core |
| Simulacao automatica | Play/Pause/Stop com velocidade configuravel | `feature/auto-sim` |
| Grafos configuraveis | Layouts `free_range`, `two_poles`, `single_pole` | core |
| Doencas pre-configuradas | Newcastle, HPAI H5N1, Marek, Bronquite | core |
| Escolha de pacientes zero | UI para marcar manualmente os primeiros infectados | `feature/manual-infection` |
| BFS | Propagacao visual em ondas concêntricas | `feature/bfs` |
| DFS | Trilha de contato com reconstrucao de caminho | `feature/dfs` |
| Dijkstra | Pior cenario (caminho de maior distancia) | `feature/dijkstra` |
| Reset visual | Limpa marcacoes de algoritmo sem resetar a simulacao | `feature/graph-controls` |
| Metricas em grafico | Evolucao S/E/I/R/D ao longo do tempo | core |
| Relatorio final | Encerramento automatico ao fim do surto | core |

---

## Instalacao e execucao

### Requisitos

- Godot 4.6+ ([download](https://godotengine.org/download))
- Nenhuma dependencia externa. Sem GDExtensions, sem plugins, sem bibliotecas.

### Rodar localmente

```bash
# 1. Abrir o projeto no Godot
"C:\Program Files\Godot\Godot.exe" --path "C:\Users\Leonardo\Documents\ProjetoGrafos\projeto_v_2"

# 2. No editor: Project > Run (F5)
```

### Rodar a cena principal via linha de comando (headless)

```bash
cd "C:\Users\Leonardo\Documents\ProjetoGrafos\projeto_v_2"
"C:\Program Files\Godot\Godot.exe" --headless --quit-after 120
```

O modo headless eh usado para validacao automatica (ver [Testes](#testes)).

---

## Documentacao tecnica

Documentos em `docs/`:

| Arquivo | O que tem |
|---------|-----------|
| `docs/PLANO.md` | Roadmap de todas as fases, criterios de pronto, dependencias entre features |
| `docs/CHANGELOG.md` | Log cronologico de cada commit por fase, branch, arquivo criado/modificado |
| `docs/ARCHITECTURE.md` | Camadas (core vs extensions), fluxo de dados, convencoes, como adicionar/remover feature |
| `docs/CHECKPOINT.md` | Estado atual, hash dos commits, comandos de validacao |
| `docs/AGENT_PLAN.md` | Workflow do agente autonomo (escopo restrito, anti-esgotamento de contexto) |
| `docs/algorithm.md` | Pseudocodigo do modelo SEIRD (matematica do modelo, nao editar) |

---

## Controles e interface

### Botoes na cena principal (da esquerda pra direita / de cima pra baixo):

```
[ Resetar Grafo ]                         limpa cores de algoritmos

[ BFS a partir do paciente zero ]         visualiza propagacao em ondas
[ Cancelar BFS ]                          interrompe BFS em execucao

[ DFS a partir do paciente zero ]         trilha de contato
[ Dijkstra - Pior cenario... ]            marca ate o no mais distante
[ Resultado: 0 -> 7 (dist 3.0) caminho: 0 -> 2 -> 5 -> 7 ]

[ BtnPasso ]                              avanca 1 dia manual

[ HUD - Estatisticas ]                    S E I R D totals + dia
[ Vacinar ] / [ Isolar Infectados ]       intervencoes
[ Encerrar Simulacao ]                    para e mostra relatorio

[ Escolher Infectados ]                   abre UI de selecao de paciente zero
[ Panel Auto-Sim: Play Pause Stop ]       controles de auto-sim
[ slider velocidade 0.1s a 3.0s/dia ]

[ Grafico de Metricas ]                   evolucao temporal
```

### Eventos de teclado

- `Esc` (ui_cancel): fecha a aplicacao

---

## Arquitetura

### Camadas

```
+-------------------------------------------------------+
|                                                      |
|  scripts/                      (nucleo do projeto)   |
|    seird_model.gd               logica SEIRD         |
|    graph_generator.gd           topologias           |
|    simulation_view.gd           view + graph         |
|    main_simulation.gd           orquestrador         |
|    sim_config.gd                parametros           |
|    hud.gd / metrics_view.gd     UI                   |
|                                                      |
|  scripts/core_extensions/       (isoladas por feature)|
|    auto_simulation/                                  |
|      auto_simulation_controller.gd  Timer + pl/pausa |
|      control_panel.gd              UI do painel     |
|      control_panel.tscn                                |
|    manual_infection/                                  |
|      infection_selector.gd                            |
|      infection_selector.tscn                          |
|    graph_algorithms/                                  |
|      graph_registry.gd            registry nos       |
|      graph_control_panel.gd                            |
|      graph_control_panel.tscn                          |
|      bfs_runner.gd / bfs_visualizer.gd                |
|      dfs_runner.gd / dfs_visualizer.gd                |
|      dijkstra_runner.gd / dijkstra_visualizer.gd      |
|                                                      |
|  scripts/utils/                 (validacoes headless) |
|    validate_graph.gd                                 |
|    validate_seird_full.gd                            |
|    validate_autosim.gd                               |
|    validate_manual_infection.gd                      |
|    validate_registry.gd                              |
|    validate_bfs.gd                                   |
|    validate_dfs.gd                                   |
|    validate_dijkstra.gd                              |
+-------------------------------------------------------+
```

OBS: scripts core ficam em `scripts/` (e nao em `scripts/core/`) para preservar os
UIDs das cenas. Mais detalhes em [Notas finais](#decisoes-de-design).

### Principios

1. **Core nao depende de extensions**: o core expoe hooks publicos (`injetar_autosim`, `injetar_registry`, `set_initial_infected`); extensions consomem esses hooks.
2. **Rodar feature = remover pasta + reverter commits**: cada feature em diretorio proprio e branch propria.
3. **Sem complexidade sobressalente**: tudo escrito em GDScript padrao. Sem GDExtension, sem plugin, sem biblioteca nativa.
4. **Tipagem explicita**: todas as funcoes declaram parametros e retornos.
5. **Comentarios minimos apenas em trechos nao obvios**: codigo se explica sozinho.

Mais detalhes em `docs/ARCHITECTURE.md`.

---

## Algoritmos de grafos

Os tres algoritmos consomem o `GraphRegistry` (estado central do grafo visual).

### BFS - Propagacao em ondas

Quando o usuario clica "BFS a partir do paciente zero":

1. Pega paciente zero (primeiro E/I, ou primeiro agente)
2. Executa BFS classico (`bfs_runner.gd`)
3. Atribui cor por nivel (1a onda = amarelo, proxima = laranja, etc)
4. Naked eye: ver ondas concêntricas de propagacao saindo da origem

Complexidade: O(V + E)

### DFS - Trilha de contato

Executa DFS iterativo (sem stack overflow) a partir do paciente zero. Cada no
recebe cor ciano na ordem de descoberta. Permite reconstruir caminho entre
dois nos via arvore DFS (`caminho_para(destino)`).

Complexidade: O(V + E)

### Dijkstra - Pior cenario

Implementa Dijkstra classico com fila de prioridade (array ordenado para grafos
pequenos). Considera pesos por aresta (no projeto, maior parte peso 1). Calcula:

- distancia minima a todos os nos
- predecessor de cada no
- **pior caso**: caminho mais longo partindo da origem
- reconstrói caminho da origem ate destino via `reconstruir_caminho`

Complexidade: O((V + E) log V) com heap; O(V^2) com array simples (suficiente ate ~100 nos).

---

## Testes

Todos os testes rodam em **headless**: sem jogo, sem GUI, sem contexto.

### Rodar tudo de uma vez (bash)

```bash
cd "C:\Users\Leonardo\Documents\ProjetoGrafos\projeto_v_2"
for v in scripts/utils/validate_*.gd; do
  echo "=== $v ==="
  "C:\Program Files\Godot\Godot.exe" --headless --quit --script "$v" 2>&1 | grep -E "OK|FAIL|VALIDATE"
done
```

### Validators headless

| Validator | Cenarios |
|-----------|----------|
| `validate_graph.gd` | 4 layouts, conectividade, sem vertices isolados |
| `validate_seird_full.gd` | 30 steps com 30 nos, casos extremos (0 agentes, clamp fem, vaccinate invalido) |
| `validate_autosim.gd` | 7 cenarios (start, ticks, pause nao ticka, resume retoma, stop limpa) |
| `validate_manual_infection.gd` | 4 cenarios (lista pre-definida, fallback aleatorio, lista vazia, ids invalidos) |
| `validate_registry.gd` | 4 cenarios com nodes fake (registrar, get, cor temp, reset) |
| `validate_bfs.gd` | 4 cenarios (arvore, ciclo, desconexo, adj formato int) |
| `validate_dfs.gd` | 3 cenarios (arvore, caminho_para, ciclo) |
| `validate_dijkstra.gd` | 3 cenarios (arvore, pesos, reconstruir caminho) |

### Saida esperada por validator

Cada um imprime linhas `OK cenario_X` e termina com `VALIDATE_<FEATURE>_OK`.
Em caso de falha, imprime `FAIL ...` e sai com codigo 1.

### Validar cena principal

```bash
"C:\Program Files\Godot\Godot.exe" --headless --quit-after 120 2>&1 | grep -iE "error|warning" | grep -v "RID alloc\|ObjectDB\|file_uid\|Microsoft VS\|external text editor" | head -5
```

`EXIT 0` sem novos errors (os vazamentos de RID/ObjectDB sao normais no headless e nao causam problema).

---

## Git workflow

### Branches

| Branch | Conteudo |
|--------|----------|
| `review` (default) | Codigo de fato usado. Recebe merge de todas as fases. **NUNCA pushada sem autorizacao** |
| `feature/<nome>` | Branch efemera por feature, deletada apos merge |
| `bugfix/<nome>` | Branch efemera de correcoes |

### Commits por fase (branch `review`)

```
review
 +-- bb16c0/434aa44/c4e4cbb/b49d128    Fase 1 - bugfix core (4 commits)
 +-- f1c986f                            Fase 2 - auto-sim
 +-- 4549fc8                            Fase 3 - manual infection
 +-- 3e0101b                            Fase 5 - graph controls (registry + reset)
 +-- 9aa4957                            Fase 6 - BFS onda
 +-- 79f0e36                            Fase 7 - DFS trilha
 +-- 55bb231                            Fase 8 - Dijkstra pior cenario
 +-- a23688e                            docs - CHANGELOG/ARCHITECTURE/CHECKPOINT pos-execucao
 +-- 45ed41c                            docs - README oficial completo
 +-- 4e6a4c4                            docs - correcoes consistencia pos-revisao
 +-- 2fe84a3                            fix - 3 bugs de runtime da revisao recursiva
```

Lista completa em `git log --oneline review`.

### Reverter uma feature

```bash
git checkout review
git log --oneline --all -- scripts/core_extensions/graph_algorithms/dijkstra_runner.gd
# pegar o hash do commit da fase
git revert <hash> --no-edit
# apagar a pasta manualmente
rm -rf scripts/core_extensions/graph_algorithms/dijkstra_*.gd
# remover do main_simulation.gd os metodos _montar_dijkstra, _on_dijkstra_pressed e as constantes/variaveis
```

Mais detalhes em `docs/PLANO.md` (topico "Como Remover uma Feature") e `docs/ARCHITECTURE.md`.

---

## Roadmap completo

### Fases concluidas

| # | Fase | Status |
|---|------|--------|
| 1 | Correcao de 12+ bugs criticos no core | CONCLUIDA |
| 2 | Simulacao automatica + Play/Pause/Stop | CONCLUIDA |
| 3 | Manipulacao manual de infectados | CONCLUIDA |
| 5 | Graph registry + painel de reset | CONCLUIDA |
| 6 | BFS onda de propagacao | CONCLUIDA |
| 7 | DFS trilha de contato | CONCLUIDA |
| 8 | Dijkstra pior cenario | CONCLUIDA |

### Fases nao implementadas (fora do escopo desta entrega)

| # | Fase | Motivo |
|---|------|--------|
| 4 | Mode switcher dual (aba Modo Grafo) | Os algoritmos ja funcionam via botoes laterais sem troca de aba. Adicionar wouldnt quebrar nada mas eh complexidade extra desnecessaria |

---

## Notas finais

### Decisoes de design

1. **Core scripts nao foram movidos**: ficaram em `scripts/` (nao em `scripts/core/`) para preservar os UIDs das cenas. Mover causaria que as `.tscn` perdessem referencias. Decisao documentada em `docs/PLANO.md`.

2. **Scripts core tiveram modificacoes minimas**: apenas adicoes de interface publica (`set_initial_infected`, `injetar_autosim()`, etc). A logica SEIRD original dos 5 commits em `b195d4a` ficou intacta, so blindada contra casos extremos.

3. **Sem comentarios excessivos**: cada arquivo tem comentario de topo explicando o papel, e inline comments so onde a logica nao eh obvia (ex: "evita aresta duplicada" em `_garantir_conectividade`).

4. **Cores dos algoritmos != cores SEIRD**: BFS/DFS/Dijkstra usam cores proprias (amarelo/laranja/vermelho, ciano, verde) para nao confundir usuario.

5. **Origin nao eh usada**: projeto eh local-only. Branch `review` esta localmente varios commits a frente do `origin/review`.

### Onde procurar ajuda

- Para entender o codigo: `docs/ARCHITECTURE.md`
- Para entender o historico: `docs/CHANGELOG.md`
- Para entender o plano original: `docs/PLANO.md`
- Para rodar validacoes: secao [Testes](#testes) deste README
- Para reverter feature: secao "Reverter uma feature" deste README

### Licenca

Projeto academico. Sem licenca definida. Uso restrito ao escopo da disciplina.





# GODOT REFACTORING & STABILIZATION AGENT

## Role

You are a senior software engineer specialized in Godot, software quality, debugging, refactoring, and maintainable code.

Your goal is to improve the existing project while preserving its intended functionality and structure.

---

# Objectives

Prioritize the following:

1. Fix existing bugs.
2. Improve code readability and maintainability.
3. Reduce unnecessary complexity.
4. Remove verified dead code and redundancy.
5. Prevent regressions.
6. Preserve existing functionality.
7. Minimize code changes.

The project should become simpler, cleaner, and more reliable without changing its intended behavior.

---

# Core Rules

## Preserve Existing Behavior

Do not change gameplay, features, workflows, or project behavior unless explicitly requested or required to fix a verified issue.

If a system works correctly, avoid modifying it.

---

## Do Not Invent Requirements

Do not assume:

* Missing features
* Intended mechanics
* Future requirements
* Desired behaviors

If information is missing, report the uncertainty instead of making assumptions.

---

## Do Not Hallucinate Code

Only use methods, nodes, resources, signals, and systems that can be verified in the project.

Do not create code based on assumptions about the architecture.

---

## Avoid Overengineering

Prefer simple and practical solutions.

Avoid:

* Unnecessary abstractions
* Excessive design patterns
* Wrapper layers
* Generic systems that solve no current problem
* Large architectural rewrites

Write code that an experienced human developer would naturally write.

---

## Minimal Change Principle

Choose the smallest safe solution that solves the problem.

Prefer:

* Fewer file modifications
* Fewer code changes
* Lower risk
* Greater compatibility with existing code

---

# Analysis Process

Before making changes:

1. Understand the existing architecture.
2. Identify bugs, technical debt, redundancy, and dead code.
3. Analyze dependencies and possible side effects.
4. Determine the root cause of each issue.

Never apply fixes without understanding the problem.

---

# Refactoring Guidelines

Improve code by:

* Simplifying logic
* Reducing duplication
* Improving naming
* Improving readability
* Reducing complexity

Only refactor when there is a clear benefit.

---

# Dead Code & Redundancy

When it can be verified safely, remove:

* Unused code
* Unused files
* Unused resources
* Obsolete commented code
* Duplicate logic

If usage cannot be verified, keep it and report it as potentially unused.

Preserving functionality is more important than aggressive cleanup.

---

# Performance

Do not optimize based on assumptions.

Only make performance changes when there is evidence that they provide a measurable benefit.

---

# Testing

After every significant change:

* Verify existing functionality still works.
* Test affected systems.
* Check for regressions.
* Validate edge cases when relevant.

No task is complete until the changes have been validated.

---

# Completion Checklist

Before finishing:

* All requested issues addressed.
* Existing functionality preserved.
* No new features introduced.
* No unsupported assumptions made.
* No unnecessary complexity added.
* Dead code and redundancy reviewed.
* Changes validated through testing.

---

# Final Principle

Preserve behavior.

Fix real problems.

Simplify where possible.

Do not invent requirements.

Do not overengineer.

Make the smallest safe improvement that achieves the objective.
