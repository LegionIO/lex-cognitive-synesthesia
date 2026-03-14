# lex-cognitive-synesthesia

A LegionIO cognitive architecture extension that models cross-modal cognitive associations inspired by synesthesia. Sensory mappings link one cognitive modality to another, firing automatically when the source modality is stimulated.

## What It Does

Registers **sensory mappings** between eight cognitive modalities:

`visual`, `auditory`, `tactile`, `emotional`, `semantic`, `temporal`, `spatial`, `abstract`

When a source modality is triggered, all active mappings for it fire — generating `SynestheticEvent` records that carry the target response. Mappings strengthen with repeated activation and fade through decay, modeling the learned and habituated nature of associative responses.

## Usage

```ruby
require 'lex-cognitive-synesthesia'

client = Legion::Extensions::CognitiveSynesthesia::Client.new

# Register a mapping: emotional input evokes spatial response
client.register_mapping(
  source_modality:  :emotional,
  target_modality:  :spatial,
  trigger_pattern:  'high_arousal',
  response_pattern: 'open_wide_space'
)
# => { success: true, mapping_id: "uuid...", source_modality: :emotional, target_modality: :spatial }

# Register another mapping for the same source
client.register_mapping(
  source_modality:  :emotional,
  target_modality:  :visual,
  trigger_pattern:  'high_arousal',
  response_pattern: 'bright_warm_colors'
)

# Trigger all active mappings for emotional input
result = client.trigger(source_modality: :emotional, input: { valence: 0.8, arousal: 0.9 })
# => { success: true, triggered_count: 2, events: [ { intensity: 0.6, target_output: { modality: :spatial, ... } }, ... ] }

# Check cross-modal richness (breadth of coverage)
client.cross_modal_richness
# => { success: true, richness: 0.036, richness_label: :amodal }

# Which modality pairs are most activated?
client.dominant_modality_pairs(limit: 3)
# => { success: true, pairs: [{ pair: "emotional->spatial", activation_count: 1 }, ...], count: 2 }

# What modalities are covered by active mappings?
client.modality_coverage
# => { success: true, covered_modalities: [:emotional, :spatial, :visual], coverage_count: 3, total_modalities: 8 }

# Decay all mappings (removes those that fall to 0)
client.decay_mappings
# => { success: true, mappings_removed: 0, mappings_remaining: 2 }

# Recent event history
client.event_history(limit: 10)
# => { success: true, events: [...], count: 2 }

# Full report
client.synesthesia_report
# => { success: true, mapping_count: 2, active_mapping_count: 2, event_count: 2, cross_modal_richness: 0.036, ... }
```

## Development

```bash
bundle install
bundle exec rspec
bundle exec rubocop
```

## License

MIT
