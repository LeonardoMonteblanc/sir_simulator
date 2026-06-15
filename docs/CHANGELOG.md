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

## Fase 1 - Correcao de Bugs Criticos
**Branch:** `bugfix/critical`
**Status:** PENDENTE

### Commits Planejados (granulares):
1. `fix: remove debug prints em graph_generator.gd`
2. `fix: valida array vazio em seird_model.gd (infectados iniciais)`
3. `fix: valida num_females <= num_agents em seird_model.gd`
4. `fix: sincroniza parametros_globais em main_simulation.gd`
5. `fix: descomenta integracao metrics_view`
6. `fix: valida is_instance_valid em limpar_simulacao`
7. `fix: valida outbreak_over antes de chamar em simulation_view`
8. `fix: trata num_nodes <= 0 em graph_generator`
9. `fix: previne aresta duplicada em _garantir_conectividade`
10. `fix: valida weight em _get_infection_prob`

### Testes:
- [ ] Sintaxe OK
- [ ] Cenarios problemas (num_agents=0, etc) nao crasham
- [ ] Console limpo
