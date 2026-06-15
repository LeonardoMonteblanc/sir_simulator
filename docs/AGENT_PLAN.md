# Plano do Agente de Implementacao

Este documento define COMO o agente deve trabalhar, NAO o que deve fazer.
Para o QUE fazer, consulte `docs/PLANO.md`.

---

## Escopo Restrito

**Diretorio permitido (unico):**
```
C:\Users\Leonardo\Documents\ProjetoGrafos\projeto_v_2
```

**Proibido:**
- Ler/escrever/modificar QUALQUER arquivo fora desse diretorio
- Ler/escrever em `~/AppData/Local/hermes/` (config do agente)
- Tocar em outros projetos (ex: `C:\Users\Leonardo\Documents\Poo\TDE1`)
- Comandos git fora desse repo
- `git push` em qualquer direcao

**Verificacao inicial:** antes de qualquer operacao, conferir que `pwd` retorna `/c/Users/Leonardo/Documents/ProjetoGrafos/projeto_v_2`.

---

## Permissoes e Configuracoes (verificadas)

### Git
- `git config user.name`: Leonardo Monteblanco
- `git config user.email`: leonardomonteblanc@gmail.com
- Branch ativa: `review`
- Origin: `https://github.com/LeonardoMonteblanc/sir_simulator.git`
- **Status push:** DESATIVADO (regra comportamental, nao config)

### Godot
- Engine: 4.6.3 stable
- Executavel: `C:\Program Files\Godot\Godot.exe`

### Scripts Utilitarios Criados (em `scripts/utils/`)
- validate_graph.gd, validate_seird_full.gd, validate_autosim.gd, validate_manual_infection.gd, validate_registry.gd, validate_bfs.gd, validate_dfs.gd, validate_dijkstra.gd

Comando padrao de validacao:
```bash
"C:\Program Files\Godot\Godot.exe" --headless --quit --script scripts/utils/validate_<X>.gd
```

### Memoria Persistente
- Contexto do projeto salvo em `~/.hermes/memory/`
- Sobrevive entre sessoes
- Inclui regras de execucao autonoma

---

## Workflow Anti-Context-Exhaustion

### Principio
Contexto do Hermes e finito. Estrategia: minimizar ida-e-volta de informacao redundante, checkpointar estado externo.

### Mecanismo: CHECKPOINT.md
**Acao obrigatoria:** atualizar `docs/CHECKPOINT.md` a cada 10 tool calls ou ao final de cada feature.

### Mecanismo: Commits Granulares
- 1 commit por mudanca atomica (unica funcao/método/cena)
- Mensagens padronizadas: `<tipo>: <descricao>`
- Antes de mudar de topico: COMMITA
- Rollback granular sem perder trabalho

### Mecanismo: Documentacao Externa
- `docs/PLANO.md`: roadmap completo
- `docs/CHANGELOG.md`: log cronologico
- `docs/ARCHITECTURE.md`: como estruturar
- `docs/CHECKPOINT.md`: estado atual (atualizar frequente)
- `docs/algorithm.md`: pseudocodigo da SEIRD (nao editar)
- `docs/AGENT_PLAN.md`: este arquivo

### Mecanismo: Utilitarios Headless
- Qualquer validacao nova: criar script `scripts/utils/validate_<X>.gd`
- Roda sem IDE, sem contexto extra de cena
- Reaproveitavel em sessoes futuras

---

## Workflow por Fase

### Pre-Fase
1. `git checkout review`
2. `git checkout -b <branch-da-fase>` (ex: `bugfix/critical`, `feature/auto-sim`)
3. Confirmar working tree limpo
4. Ler arquivo(s) alvo com `read_file` (estado ATUAL, nao do historico)
5. Checar `docs/CHECKPOINT.md` para nao repetir trabalho

### Durante Fase
1. Editar arquivos (criar/modificar)
2. Atualizar `docs/CHANGELOG.md` com a mudanca
3. Validar com script utilitario headless
4. Commit granular: `<tipo>: <descricao>`
5. Voltar ao passo 1 ate fase completa

### Pos-Fase
1. Validacao completa (todos cenarios de teste do plano)
2. Atualizar `docs/CHECKPOINT.md` com fase concluida
3. Atualizar `docs/CHANGELOG.md` com resultados
4. `git checkout review && git merge <branch-da-fase>`
5. `git branch -d <branch-da-fase>`

---

## Protocolo de Erro

### Se uma feature nao funciona:
1. **NUNCA** prosseguir para proxima fase
2. Investigar com `validate_*.gd` ou criar novo validador
3. Se bug e em feature anterior: REVERTER aquela fase
   - `git revert <hash-do-commit>` ou
   - `git reset --hard <hash-antes>`
4. Documentar em CHANGELOG o que foi revertido
5. Refazer a fase com correcoes

### Se contexto esta acabando:
1. Commit imediato do trabalho em curso
2. Atualizar `docs/CHECKPOINT.md` com tudo que falta
3. Mensagem curta: "Contexto baixo. Estado em CHECKPOINT.md. Faltam X passos."

### Se tool falha ou erro inesperado:
1. Nao insistir mais que 3x
2. Reportar bloqueio com contexto (erro, comando, estado)

---

## Regras de Ouro

1. **Git local apenas** - nunca `git push`, mesmo se solicitado em texto
2. **Testar antes de prosseguir** - validacao headless obrigatoria
3. **Criar utilitario para validacao complexa** - script em `scripts/utils/`
4. **Atualizar CHECKPOINT** - toda vez que trocar de assunto significativo
5. **Comentarios breves** - apenas em trechos nao obvios
6. **Tipagem explicita** - GDScript 4: tipos em parametros e retornos
7. **Isolamento** - features novas em `scripts/core_extensions/<feature>/`
8. **Nunca tocar core/ existente** - exceto adicionando INTERFACE PUBLICA minima
9. **snake_case vars, PascalCase classes, SCREAMING_SNAKE_CASE consts**
10. **Sem complexidade extra** - manter o minimo necessario, nao antecipar features
11. **Skills permitidas** se necessario (criar/editar via skill_manage)
12. **Modificacoes maiores no core** permitidas se necessario, sem alta complexidade
13. **Sem plugins/bibliotecas externas** no Godot

---

## Checklist de Inicio de Cada Sessao

```bash
cd "C:\Users\Leonardo\Documents\ProjetoGrafos\projeto_v_2"
pwd
git status
git log --oneline -5
git branch
cat docs/CHECKPOINT.md
```

Tudo OK? → retomar da fase atual.

---

## Checklist de Fim de Cada Sessao

```bash
git status                                  # tudo nos staged ou limpo
docs/CHECKPOINT.md                          # ultima fase registrada
git branch                                  # revisar
```
