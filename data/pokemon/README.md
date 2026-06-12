# Pokemon Data

Pokemon species are loaded through `pokemon_index.json`, which points each
species id to its generation file:

- `gen1/pokemon.json`
- `gen2/pokemon.json`
- `gen3/pokemon.json`
- `gen4/pokemon.json`
- `gen5/pokemon.json`
- `gen6/pokemon.json`
- `gen7/pokemon.json`
- `gen8/pokemon.json`

`../pokemon_species.json` is kept as a unified compatibility file for older
code paths and tools.

To add or adjust a move later, edit `../moves.json`, then add the move display
name to the species learnset in the correct `gen*/pokemon.json` file. Regenerate
the unified compatibility file afterward so saves, the collection move editor,
battle PP setup, and the HTML test stay in sync.

Evolution data is mirrored in `../evolutions/evolutions.json`; ability metadata
lives in `../abilities/abilities.json`; Pokedex descriptions live in
`../pokedex/pokedex.json`.
