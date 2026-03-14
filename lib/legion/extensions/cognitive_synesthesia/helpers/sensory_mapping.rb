# frozen_string_literal: true

require 'securerandom'

module Legion
  module Extensions
    module CognitiveSynesthesia
      module Helpers
        class SensoryMapping
          include Constants

          attr_reader :id, :source_modality, :target_modality,
                      :trigger_pattern, :response_pattern,
                      :strength, :activation_count, :created_at, :last_activated_at

          def initialize(source_modality:, target_modality:, trigger_pattern:, response_pattern:,
                         strength: DEFAULT_STRENGTH)
            @id               = SecureRandom.uuid
            @source_modality  = source_modality
            @target_modality  = target_modality
            @trigger_pattern  = trigger_pattern
            @response_pattern = response_pattern
            @strength         = strength.clamp(0.0, 1.0)
            @activation_count = 0
            @created_at       = Time.now.utc
            @last_activated_at = nil
          end

          def activate!
            @activation_count += 1
            @last_activated_at = Time.now.utc
            @strength = (@strength + STRENGTH_BOOST).clamp(0.0, 1.0).round(10)
          end

          def decay!
            @strength = (@strength - STRENGTH_DECAY).clamp(0.0, 1.0).round(10)
          end

          def active?
            @strength >= TRIGGER_THRESHOLD
          end

          def strength_label
            Constants.label_for(STRENGTH_LABELS, @strength)
          end

          def to_h
            {
              id:                @id,
              source_modality:   @source_modality,
              target_modality:   @target_modality,
              trigger_pattern:   @trigger_pattern,
              response_pattern:  @response_pattern,
              strength:          @strength,
              activation_count:  @activation_count,
              strength_label:    strength_label,
              active:            active?,
              created_at:        @created_at,
              last_activated_at: @last_activated_at
            }
          end
        end
      end
    end
  end
end
