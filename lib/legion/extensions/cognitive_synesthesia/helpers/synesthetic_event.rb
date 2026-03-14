# frozen_string_literal: true

require 'securerandom'

module Legion
  module Extensions
    module CognitiveSynesthesia
      module Helpers
        class SynestheticEvent
          include Constants

          attr_reader :id, :mapping_id, :source_input, :target_output,
                      :intensity, :involuntary, :triggered_at

          def initialize(mapping_id:, source_input:, target_output:, intensity:, involuntary: true)
            @id            = SecureRandom.uuid
            @mapping_id    = mapping_id
            @source_input  = source_input
            @target_output = target_output
            @intensity     = intensity.clamp(0.0, 1.0)
            @involuntary   = involuntary
            @triggered_at  = Time.now.utc
          end

          def intensity_label
            Constants.label_for(INTENSITY_LABELS, @intensity)
          end

          def to_h
            {
              id:            @id,
              mapping_id:    @mapping_id,
              source_input:  @source_input,
              target_output: @target_output,
              intensity:     @intensity,
              intensity_label: intensity_label,
              involuntary:   @involuntary,
              triggered_at:  @triggered_at
            }
          end
        end
      end
    end
  end
end
