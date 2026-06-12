# SEIRD Poultry Epidemiological Simulator

A Godot 4 simulation framework for modeling infectious disease outbreaks in poultry flocks using a modified SEIRD (Susceptible-Exposed-Infectious-Recovered-Dead) compartmental model.

## Architecture

### Layered Design

```
┌─────────────────────────────────────────┐
│       UI Layer (Scenes/GDScript)         │
│  ConfigScreen → MainSimulation → Relatio │
└─────────────┬───────────────────────────┘
              │
┌─────────────┴───────────────────────────┐
│      Simulation View Layer               │
│  SimulationView, MetricsView, HUD       │
└─────────────┬───────────────────────────┘
              │
┌─────────────┴───────────────────────────┐
│     Model Layer (seird_model.gd)         │
│  - State transitions (S→E→I→R/D)         │
│  - Infection probability (hazard model)  │
│  - Economic calculations                │
└─────────────┬───────────────────────────┘
              │
┌─────────────┴───────────────────────────┐
│    Network Layer (graph_generator.gd)    │
│  - Graph topology generation             │
│  - Contact adjacency matrix              │
└─────────────────────────────────────────┘
```

## Running the Simulation

### Step 1: Configure
1. Run `configScreen.tscn` (or from main scene)
2. Select:
   - Number of birds (10-1000)
   - Disease (Newcastle, HPAI H5N1, Marek, Bronquite)
   - Vaccination coverage (%)
   - Flock layout (free_range, single_pole, two_poles)
   - Economic parameters (egg price, bird value)
3. Click "Iniciar Simulação"

### Step 2: Simulate
1. SimulationView displays the contact network as a graph
2. Node colors indicate state: Green (S), Yellow (E), Red (I), Blue (R), Gray (D)
3. HUD on right shows current metrics (day, counts, egg production, losses)
4. MetricsView shows SEIRD curves over time
5. Click "▶ Próximo dia" to advance one day
6. Optional interventions:
   - 💉 Vacinar: Apply 50% vaccination to susceptible birds
   - 🔒 Isolar doentes: Remove infectious birds from the network
7. Simulation ends automatically when no E or I remain

### Step 3: View Report
1. Final report displays:
   - Total deaths and mortality rate
   - Eggs lost (count + dozens)
   - Total economic loss (R$)
   - Timeline: patient zero day, peak day, last death
   - SEIRD curves for visualization

## Example Scenario

**Setup**: 100 birds, HPAI H5N1 (β=0.70, δ=0.95), free-range layout, 20% vaccination, R$0.70/egg, R$30/bird.

**Outcome** (typical):
- Day 1: Infection appears in one bird
- Day 3-5: Rapid spread (high β)
- Day 4-6: Peak 40-60 infected
- Day 10-15: Many deaths (δ=0.95)
- Day 15-20: Outbreak resolved (no E/I remaining)
- **Result**: 80-95 deaths, 2000+ eggs lost, R$3000-4000 economic loss

## GIF Capture (Optional)

To record a simulation GIF:
1. Use Godot's Export feature or a screen recording tool
2. Export at 30 FPS for smooth playback
3. Highlight the SimulationView graph and MetricsView for visibility

## Files

- **scripts/seird_model.gd** — Core epidemiological model
- **scripts/graph_generator.gd** — Network topology generation
- **scripts/simulation_view.gd** — Visualization of the network
- **scripts/metrics_view.gd** — SEIRD curves over time
- **scripts/hud.gd** — Real-time status display
- **scripts/config_screen.gd** — Simulation configuration
- **scripts/relatorio.gd** — Final report screen
- **docs/algorithm.md** — Detailed algorithm documentation
- **tests/test_suite.gd** — Automated test suite

## Running Tests

1. Open `tests/test_suite.tscn` in the Godot editor
2. Click "Play Scene" (F5 or ▶)
3. Output appears in the Debug panel
4. Results show test count, pass/fail status, and error details

**Example output**:
```
=== SEIRD Test Suite ===

✓ Test 1.1: Init 50 agents
✓ Test 1.2: One agent E (patient zero)
...
✓ Test 11.4: Valid prejudice value
Integration test completed: 15 steps, 8 deaths, R$ 240.00 loss

=== Test Results ===
Passed: 34
Failed: 0
Total: 34

✓ All tests passed!
```
