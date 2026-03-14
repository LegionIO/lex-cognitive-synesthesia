# lex-cognitive-synesthesia

**Level 3 Leaf Documentation**
- **Parent**: `/Users/miverso2/rubymine/legion/extensions-agentic/CLAUDE.md`
- **Gem**: `lex-cognitive-synesthesia`
- **Version**: 0.1.0
- **Namespace**: `Legion::Extensions::CognitiveSynesthesia`

## Purpose

Models cross-modal cognitive associations inspired by synesthesia — the neurological phenomenon where stimulation of one sense involuntarily triggers another. Sensory mappings link a source modality to a target modality via trigger and response patterns. When a source modality is activated, all active mappings for it fire, producing `SynestheticEvent` records. Mappings strengthen with use and decay over time. This models how cognitive input in one domain (e.g., emotional) automatically invokes representations in another (e.g., spatial or visual).

## Gem Info

- **Gemspec**: `lex-cognitive-synesthesia.gemspec`
- **Require**: `lex-cognitive-synesthesia`
- **Ruby**: >= 3.4
- **License**: MIT
- **Homepage**: https://github.com/LegionIO/lex-cognitive-synesthesia

## File Structure

```
lib/legion/extensions/cognitive_synesthesia/
  version.rb
  helpers/
    constants.rb           # Modalities, strength/richness/intensity label tables, thresholds
    sensory_mapping.rb     # SensoryMapping class — one cross-modal association
    synesthetic_event.rb   # SynestheticEvent class — one fired cross-modal experience
    synesthesia_engine.rb  # SynesthesiaEngine — manages mappings and event log
  runners/
    cognitive_synesthesia.rb  # Runner module — public API
  client.rb
```

## Key Constants

| Constant | Value | Meaning |
|---|---|---|
| `MAX_MAPPINGS` | 200 | Hard cap; weakest mappings pruned when exceeded |
| `MAX_EVENTS` | 500 | Event log ring size |
| `DEFAULT_STRENGTH` | 0.5 | Starting strength for new mappings |
| `STRENGTH_BOOST` | 0.1 | Strength increase per `activate!` call |
| `STRENGTH_DECAY` | 0.02 | Strength decrease per `decay!` call |
| `TRIGGER_THRESHOLD` | 0.3 | Minimum strength for a mapping to fire |

`MODALITIES`: `[:visual, :auditory, :tactile, :emotional, :semantic, :temporal, :spatial, :abstract]`

Strength labels: `0.8+` = `:dominant`, `0.6..0.8` = `:strong`, `0.4..0.6` = `:moderate`, `0.2..0.4` = `:faint`, `<0.2` = `:trace`

Richness labels (for `cross_modal_richness`): `0.8+` = `:synesthetic`, `0.6..0.8` = `:vivid`, `0.4..0.6` = `:partial`, `0.2..0.4` = `:sparse`, `<0.2` = `:amodal`

Intensity labels (for events): `0.8+` = `:overwhelming`, `0.6..0.8` = `:intense`, `0.4..0.6` = `:moderate`, `0.2..0.4` = `:subtle`, `<0.2` = `:subliminal`

## Key Classes

### `Helpers::SensoryMapping`

One cross-modal association with source/target modalities and pattern descriptors.

- `activate!` — increments `activation_count`, boosts strength by `STRENGTH_BOOST`
- `decay!` — reduces strength by `STRENGTH_DECAY`
- `active?` — strength >= `TRIGGER_THRESHOLD`
- `strength_label` — one of the `STRENGTH_LABELS` values
- Fields: `id` (UUID), `source_modality`, `target_modality`, `trigger_pattern` (caller-defined), `response_pattern` (caller-defined), `strength`, `activation_count`, `created_at`, `last_activated_at`

### `Helpers::SynestheticEvent`

A single fired cross-modal experience.

- `intensity_label` — one of the `INTENSITY_LABELS` values
- `involuntary` — always true (default); reflects the automatic nature of synesthetic responses
- `target_output` — hash with `{ modality:, response_pattern:, source_input:, source_modality: }`
- Fields: `id` (UUID), `mapping_id`, `source_input`, `target_output`, `intensity`, `triggered_at`

### `Helpers::SynesthesiaEngine`

Registry and event processor for all mappings and events.

- `register_mapping(source_modality:, target_modality:, trigger_pattern:, response_pattern:, strength:)` — validates modalities; prunes weakest mappings if over `MAX_MAPPINGS`
- `trigger(source_modality:, input:)` — finds all active mappings for source, fires each with `fire_event`, returns event list
- `decay_mappings!` — decays all mappings; removes those with strength <= 0.0
- `cross_modal_richness` — active unique pairs / `(8 * 7)` possible pairs; range `[0.0, 1.0]`
- `dominant_modality_pairs(limit:)` — top pairs by cumulative activation count
- `event_history(limit:)` — most recent events from ring buffer
- `modality_coverage` — set of modalities appearing in active mappings

## Runners

Module: `Legion::Extensions::CognitiveSynesthesia::Runners::CognitiveSynesthesia`

| Runner | Key Args | Returns |
|---|---|---|
| `register_mapping` | `source_modality:`, `target_modality:`, `trigger_pattern:`, `response_pattern:`, `strength:` | `{ success:, mapping_id:, source_modality:, target_modality: }` or `{ success: false, error: :invalid_modality }` |
| `trigger` | `source_modality:`, `input:` | `{ success:, events:, triggered_count: }` |
| `decay_mappings` | — | `{ success:, mappings_removed:, mappings_remaining: }` |
| `cross_modal_richness` | — | `{ success:, richness:, richness_label: }` |
| `dominant_modality_pairs` | `limit:` | `{ success:, pairs:, count: }` |
| `event_history` | `limit:` | `{ success:, events:, count: }` |
| `modality_coverage` | — | `{ success:, covered_modalities:, coverage_count:, total_modalities: }` |
| `synesthesia_report` | — | aggregate report with richness, active count, dominant pairs, coverage |

All runners accept optional `engine:` keyword for test injection.

## Integration Points

- No actors defined; `decay_mappings` should be called periodically (e.g., from `lex-tick`)
- `trigger_pattern` and `response_pattern` are caller-defined — can be strings, symbols, or hashes
- Can represent cross-extension stimulus linkages: e.g., emotional triggers spatial patterns, or temporal triggers semantic associations
- `cross_modal_richness` measures the breadth of cross-modal connections — a proxy for cognitive integration
- All state is in-memory per `SynesthesiaEngine` instance

## Development Notes

- Both `trigger_pattern` and `response_pattern` are stored opaquely; the engine does not parse them
- `fire_event` uses the mapping's current strength (after `activate!`) as event intensity
- `prune_mappings!` evicts weakest by strength; `prune_weak_mappings!` removes strength-zero mappings after decay
- The event log is a ring buffer: `@events.shift while @events.size > MAX_EVENTS`
- `cross_modal_richness` counts unique source->target pairs (directional), not bidirectional
