# SEIRD Epidemiological Model — Algorithm Documentation

## Step() Function Pseudocode

```
function step():
  // 1. Identify infectious agents (I or D with active transmission)
  infectious_ids ← agents with state I or (D with dias_estado ≤ post_mortem_days)
  
  // 2. Transmit to susceptible neighbors
  for agent in agents:
	if agent.state == S:
	  prob ← _get_infection_prob(agent, infectious_ids)
	  if random() < prob:
		_expose_agent(agent)
		if first_infection_day == -1:
		  first_infection_day ← current_day
  
  // 3. Update disease progression
  current_infected ← 0
  for agent in agents:
	_update_disease_progress(agent)
	if agent.state == I:
	  current_infected += 1
  
  // 4. Track outbreak peak
  if current_infected > peak_infected_count:
	peak_infected_count ← current_infected
	peak_infected_day ← current_day
  
  // 5. Calculate economic impact
  expected_production ← sum of daily_egg_production for all females
  actual_production ← expected_production minus losses from I/D agents
  eggs_lost_today ← expected_production - actual_production
  total_eggs_lost += eggs_lost_today
  total_loss ← (total_eggs_lost × egg_price) + (total_deaths × bird_price)
  
  // 6. Advance day and emit signal
  current_day += 1
  emit(step_completed, {state_counts, economic_data})
```

## Hazard Model — Infection Probability

The infection probability follows an **independent hazard model** over contacts:

$$p = 1 - \prod_{i} (1 - \beta \cdot w_i)$$

Where:
- $\beta$ = transmission coefficient per contact
- $w_i$ = edge weight (contact frequency/intensity) for neighbor $i$
- Product iterates over all infectious neighbors in the contact network

**Derivation**: Each contact is independent. For neighbor $i$, the probability of transmission is $\beta \cdot w_i$. The probability of NOT transmitting to neighbor $i$ is $1 - \beta \cdot w_i$. The probability of NOT transmitting to ANY neighbor is the product. Thus, the probability of transmitting to AT LEAST one neighbor is the complement.

## Disease Presets

| Disease | β (Beta) | Latency (days) | Infectious (days) | Lethality (δ) | Post-mortem |
|---------|----------|----------------|-------------------|---------------|-------------|
| Newcastle | 0.40 | 2-6 | 5-14 | 70% | 2 |
| HPAI H5N1 | 0.70 | 1-3 | 2-5 | 95% | 4 |
| Marek | 0.20 | 14-21 | 20-60 | 75% | 0 |
| Bronquite | 0.60 | 1-3 | 5-10 | 15% | 0 |

## State Transitions

```
S (Susceptible)
  └─ (infection occurs) → E (Exposed)
	   └─ (latency period) → I (Infectious)
			├─ (delta probability) → D (Dead)
			└─ (1-delta probability) → R (Recovered)
```

## Key Variables

- `adjacencia`: Dictionary mapping agent ID to list of neighbors with weights
- `agentes`: Array of agent objects with state, timer, and production data
- `dia`: Current simulation day (0-indexed)
- `ovos_perdidos_hoje`: Eggs lost today (from I and D agents)
- `ovos_perdidos_total`: Cumulative eggs lost
- `qtd_mortos`: Total number of deaths
- `prejuizo`: Total economic loss (R$)
