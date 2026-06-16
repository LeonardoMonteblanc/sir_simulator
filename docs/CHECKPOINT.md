# CHECKPOINT DO AGENTE

Atualizar este arquivo ao final de CADA tool call significativo ou a cada
~10 tool calls. Se contexto esgotar, proximo turno pode ler este arquivo
para retomar sem perda de contexto.

---

## Estado Atual (Pos-Execucao Completa)

### Branch: `review`
### Ultimo commit merge: `2fe84a3` (fix revisao recursiva)

Working tree: limpo

### Commits locais (18 novos, branch review):
```
2fe84a3 fix: 3 bugs de runtime descobertos em revisao recursiva
4e6a4c4 docs: correcoes de consistencia pos-revisao recursiva
45ed41c docs: README oficial completo, CHANGELOG pos-execucao, ARCHITECTURE e CHECKPOINT atualizados
a23688e docs: atualiza CHANGELOG, ARCHITECTURE e CHECKPOINT pos-execucao completa
55bb231 feat(dijkstra): runner com pesos + visualizador + botao
79f0e36 feat(dfs): runner iterativo + visualizador + botao + caminho_para
9aa4957 feat(bfs): runner puro + visualizador + botao na cena
3e0101b feat(graph-controls): registry de nos + painel reset (base para algoritmos)
4549fc8 feat(manual_infection): UI para escolher pacientes zero + set_initial_infected no model
f1c986f feat(auto-sim): controller Timer play/pause/stop + panel UI + injecao opcional na view
b49d128 fix(simulation_view): is_instance_valid, renderizar_estado_atual restaura conexoes
c4e4cbb fix(main_simulation): corrige caminho de node, sincroniza params, ativa metrics_view, is_instance_valid + has_signal/has_method guards
434aa44 fix(seird_model): valida num_females, robustez em _get_infection_prob, vaccinate seguro contra fracao invalida
bbd16c0 fix(graph_generator): remove debug prints, valida num_nodes<=0, evita arestas duplicadas em _garantir_conectividade
1bb4f1d docs: checkpoint pre-fase-1
228f019 docs: plano completo, changelog e arquitetura base
```

### Diretorio de Trabalho: Apenas e Somente Apenas

**RAIZ:** `C:\Users\Leonardo\Documents\ProjetoGrafos\projeto_v_2`

**Proibido modificar:**
- Qualquer coisa FORA de `C:\Users\Leonardo\Documents\ProjetoGrafos\projeto_v_2`
- `~/AppData/Local/hermes/` (perfil/memoria/skills)
- `C:\Users\Leonardo\Documents\Poo\TDE1` (outro projeto)
- Quaisquer configs globais do sistema

---

## Validacao

### Cenarios completos:
```bash
cd "C:\Users\Leonardo\Documents\ProjetoGrafos\projeto_v_2"

# Todos os 8 validators headless
for v in scripts/utils/validate_*.gd; do
  echo "=== $v ==="
  "C:\Program Files\Godot\Godot.exe" --headless --quit --script "$v" 2>&1 | grep -E "OK|FAIL|VALIDATE"
done

# Valida cena principal
"C:\Program Files\Godot\Godot.exe" --headless --quit-after 120 2>&1 | grep -iE "error|warning" | grep -v "Microsoft VS\|external text editor\|RID alloc\|ObjectDB\|file_uid" | head -5
```

Saida esperada: todos `VALIDATE_*_OK` + cena sem errors novos alem de RID/ObjectDB leaks (que existem em todos os games e nao sao causados por nos).

---

## Como Retomar de Onde Parei

1. Ler `docs/PLANO.md` para entender o escopo
2. Ler `docs/CHANGELOG.md` para saber o que foi feito
3. Ler `docs/ARCHITECTURE.md` para estrutura completa
4. Rodar todos os validators para garantir estado funcional
5. Criar branch `feature/<nova-coisa>` para proxima adicao

---

## Estrategia Anti-Contexto-Limitado (em uso)

1. **Checkpoint frequente**: este arquivo
2. **Commits granulares**: cada mudanca atomica = 1 commit
3. **Branches efemeras**: cada feature em sua branch, merge em `review` no fim
4. **Documentacao externa**: PLANO/CHANGELOG/ARCHITECTURE/CHECKPOINT/AGENT_PLAN fora do contexto
5. **Validacoes headless**: scripts em `scripts/utils/` regeneram informacao sem contexto extra
