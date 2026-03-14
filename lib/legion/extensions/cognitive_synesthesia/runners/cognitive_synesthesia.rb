# frozen_string_literal: true

module Legion
  module Extensions
    module CognitiveSynesthesia
      module Runners
        module CognitiveSynesthesia
          include Legion::Extensions::Helpers::Lex if Legion::Extensions.const_defined?(:Helpers) &&
                                                      Legion::Extensions::Helpers.const_defined?(:Lex)

          def register_mapping(source_modality:, target_modality:, trigger_pattern:,
                               response_pattern:, strength: Helpers::Constants::DEFAULT_STRENGTH,
                               engine: nil, **)
            target = engine || synesthesia_engine
            Legion::Logging.debug "[cognitive_synesthesia] runner register_mapping #{source_modality}->#{target_modality}"
            target.register_mapping(
              source_modality:  source_modality,
              target_modality:  target_modality,
              trigger_pattern:  trigger_pattern,
              response_pattern: response_pattern,
              strength:         strength
            )
          end

          def trigger(source_modality:, input:, engine: nil, **)
            target = engine || synesthesia_engine
            Legion::Logging.debug "[cognitive_synesthesia] runner trigger modality=#{source_modality}"
            target.trigger(source_modality: source_modality, input: input)
          end

          def decay_mappings(engine: nil, **)
            target = engine || synesthesia_engine
            Legion::Logging.debug '[cognitive_synesthesia] runner decay_mappings'
            target.decay_mappings!
          end

          def cross_modal_richness(engine: nil, **)
            target = engine || synesthesia_engine
            richness = target.cross_modal_richness
            label    = Helpers::Constants.label_for(Helpers::Constants::RICHNESS_LABELS, richness)
            Legion::Logging.debug "[cognitive_synesthesia] runner cross_modal_richness=#{richness.round(4)} label=#{label}"
            { success: true, richness: richness, richness_label: label }
          end

          def dominant_modality_pairs(limit: 5, engine: nil, **)
            target = engine || synesthesia_engine
            pairs  = target.dominant_modality_pairs(limit: limit)
            Legion::Logging.debug "[cognitive_synesthesia] runner dominant_modality_pairs limit=#{limit}"
            { success: true, pairs: pairs, count: pairs.size }
          end

          def event_history(limit: 20, engine: nil, **)
            target = engine || synesthesia_engine
            Legion::Logging.debug "[cognitive_synesthesia] runner event_history limit=#{limit}"
            target.event_history(limit: limit)
          end

          def modality_coverage(engine: nil, **)
            target = engine || synesthesia_engine
            Legion::Logging.debug '[cognitive_synesthesia] runner modality_coverage'
            { success: true }.merge(target.modality_coverage)
          end

          def synesthesia_report(engine: nil, **)
            target = engine || synesthesia_engine
            Legion::Logging.debug '[cognitive_synesthesia] runner synesthesia_report'
            { success: true }.merge(target.synesthesia_report)
          end

          private

          def synesthesia_engine
            @synesthesia_engine ||= Helpers::SynesthesiaEngine.new
          end
        end
      end
    end
  end
end
