# Move Data

The battle engine reads moves from `data/moves.json`. The files in
`data/moves_by_generation/` are the same move records split by generation so new
official moves can be reviewed or replaced in smaller chunks.

The current database contains 970 records:

- 937 structured move records from PokeAPI.
- 33 G-Max move records supplemented from Pokemon Database.

This keeps PokeAPI's separate physical/special Z-Move records and includes the
Shadow/Max move records exposed by PokeAPI. G-Max moves use `category:
"Variable"` and `power: 0` because their damage category and power depend on the
base move in the official games.

Each move uses this shape:

```json
{
  "id": "tail_whip",
  "name": "Tail Whip",
  "type": "Normal",
  "category": "Status",
  "power": 0,
  "accuracy": 100,
  "pp": 30,
  "priority": 0,
  "target": "enemy",
  "generation": "gen_i",
  "effects": [
    {"type": "modify_stat", "target": "enemy", "stat": "defense", "stages": -1, "chance": 100}
  ],
  "effect_text": "Official source text or notes.",
  "sources": ["pokeapi", "pokemondb"]
}
```

Effects are stored as generic data, not move-by-move code. The current engine
already handles these generic effect types in battle:

- `modify_stat`
- `drain` with `timing: "end_turn"`

The database may also contain these generic effect descriptors for future engine
support:

- `apply_status`
- `critical_modifier`
- `flinch`
- `heal`
- `multi_hit`
- `multi_turn`
- `one_hit_ko`
- `recoil`
- `special`

`special` is used when the official effect is real but too unique to safely
reduce to an existing generic effect. The original effect is kept in
`effect_text` and in the `special.text` field.

The Pokemon collection move editor lists the moves available to a Pokemon from
its species learnset in `data/pokemon_species.json`. To make a new move usable
later, add the move record here in `data/moves.json`, then add that move's
display name to the species learnset level where it should become available.
The save normalizer will keep old Pokemon compatible and the editor will refill
PP for the replaced move automatically.
