# frozen_string_literal: true

module Legion
  module Extensions
    module CognitiveSynesthesia
      module Helpers
        class SynesthesiaEngine
          include Constants

          attr_reader :mappings, :events

          def initialize
            @mappings = {}
            @events   = []
          end

          def register_mapping(source_modality:, target_modality:, trigger_pattern:,
                               response_pattern:, strength: DEFAULT_STRENGTH, **)
            return invalid_modality_error(:source_modality) unless MODALITIES.include?(source_modality)
            return invalid_modality_error(:target_modality) unless MODALITIES.include?(target_modality)

            mapping = SensoryMapping.new(
              source_modality:  source_modality,
              target_modality:  target_modality,
              trigger_pattern:  trigger_pattern,
              response_pattern: response_pattern,
              strength:         strength
            )

            @mappings[mapping.id] = mapping
            prune_mappings! if @mappings.size > MAX_MAPPINGS

            Legion::Logging.debug "[cognitive_synesthesia] mapping registered id=#{mapping.id[0..7]} " \
                                  "#{source_modality}->#{target_modality} strength=#{strength.round(2)}"

            { success: true, mapping_id: mapping.id, source_modality: source_modality,
              target_modality: target_modality }
          end

          def trigger(source_modality:, input:, **)
            active = active_mappings_for(source_modality)
            return { success: true, events: [], triggered_count: 0 } if active.empty?

            triggered_events = active.map do |mapping|
              fire_event(mapping, input)
            end

            { success: true, events: triggered_events.map(&:to_h), triggered_count: triggered_events.size }
          end

          def decay_mappings!(**)
            @mappings.each_value(&:decay!)
            removed = prune_weak_mappings!

            Legion::Logging.debug "[cognitive_synesthesia] decay_mappings! removed=#{removed} remaining=#{@mappings.size}"
            { success: true, mappings_removed: removed, mappings_remaining: @mappings.size }
          end

          def cross_modal_richness(**)
            return 0.0 if @mappings.empty?

            pairs = active_mapping_pairs
            total_possible = (MODALITIES.size * (MODALITIES.size - 1)).to_f
            return 0.0 if total_possible.zero?

            (pairs.size.to_f / total_possible).clamp(0.0, 1.0).round(10)
          end

          def dominant_modality_pairs(limit: 5, **)
            pair_counts = Hash.new(0)
            @mappings.each_value do |m|
              next unless m.active?

              pair_counts["#{m.source_modality}->#{m.target_modality}"] += m.activation_count
            end

            sorted = pair_counts.sort_by { |_, count| -count }.first(limit)
            sorted.map { |pair, count| { pair: pair, activation_count: count } }
          end

          def event_history(limit: 20, **)
            recent = @events.last(limit)
            { success: true, events: recent.map(&:to_h), count: recent.size }
          end

          def modality_coverage(**)
            covered = Set.new
            @mappings.each_value do |m|
              next unless m.active?

              covered << m.source_modality
              covered << m.target_modality
            end
            {
              covered_modalities: covered.to_a.sort,
              coverage_count:     covered.size,
              total_modalities:   MODALITIES.size
            }
          end

          def synesthesia_report(**)
            richness = cross_modal_richness
            {
              mapping_count:           @mappings.size,
              active_mapping_count:    @mappings.values.count(&:active?),
              event_count:             @events.size,
              cross_modal_richness:    richness,
              richness_label:          Constants.label_for(RICHNESS_LABELS, richness),
              dominant_modality_pairs: dominant_modality_pairs,
              modality_coverage:       modality_coverage
            }
          end

          private

          def invalid_modality_error(field)
            { success: false, error: :invalid_modality, field: field, valid_modalities: MODALITIES }
          end

          def active_mappings_for(source_modality)
            @mappings.values.select { |m| m.source_modality == source_modality && m.active? }
          end

          def fire_event(mapping, input)
            mapping.activate!
            intensity = mapping.strength.clamp(0.0, 1.0)
            event = SynestheticEvent.new(
              mapping_id:    mapping.id,
              source_input:  input,
              target_output: build_target_output(mapping, input),
              intensity:     intensity
            )
            @events << event
            @events.shift while @events.size > MAX_EVENTS

            Legion::Logging.debug "[cognitive_synesthesia] event fired id=#{event.id[0..7]} " \
                                  "mapping=#{mapping.id[0..7]} intensity=#{intensity.round(2)}"
            event
          end

          def build_target_output(mapping, input)
            {
              modality:         mapping.target_modality,
              response_pattern: mapping.response_pattern,
              source_input:     input,
              source_modality:  mapping.source_modality
            }
          end

          def active_mapping_pairs
            @mappings.values.select(&:active?).map do |m|
              [m.source_modality, m.target_modality]
            end.uniq
          end

          def prune_mappings!
            overflow = @mappings.size - MAX_MAPPINGS
            return if overflow <= 0

            ids_to_prune = @mappings.min_by(overflow) { |_, m| m.strength }.map(&:first)
            ids_to_prune.each { |id| @mappings.delete(id) }
          end

          def prune_weak_mappings!
            before = @mappings.size
            @mappings.reject! { |_, m| m.strength <= 0.0 }
            before - @mappings.size
          end
        end
      end
    end
  end
end
