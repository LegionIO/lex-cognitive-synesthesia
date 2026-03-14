# frozen_string_literal: true

module Legion
  module Extensions
    module CognitiveSynesthesia
      module Helpers
        module Constants
          MAX_MAPPINGS     = 200
          MAX_EVENTS       = 500
          DEFAULT_STRENGTH = 0.5
          STRENGTH_BOOST   = 0.1
          STRENGTH_DECAY   = 0.02
          TRIGGER_THRESHOLD = 0.3

          MODALITIES = %i[visual auditory tactile emotional semantic temporal spatial abstract].freeze

          STRENGTH_LABELS = {
            (0.8..)     => :dominant,
            (0.6...0.8) => :strong,
            (0.4...0.6) => :moderate,
            (0.2...0.4) => :faint,
            (..0.2)     => :trace
          }.freeze

          RICHNESS_LABELS = {
            (0.8..)     => :synesthetic,
            (0.6...0.8) => :vivid,
            (0.4...0.6) => :partial,
            (0.2...0.4) => :sparse,
            (..0.2)     => :amodal
          }.freeze

          INTENSITY_LABELS = {
            (0.8..)     => :overwhelming,
            (0.6...0.8) => :intense,
            (0.4...0.6) => :moderate,
            (0.2...0.4) => :subtle,
            (..0.2)     => :subliminal
          }.freeze

          def self.label_for(labels_hash, value)
            labels_hash.find { |range, _| range.cover?(value) }&.last || :unknown
          end
        end
      end
    end
  end
end
