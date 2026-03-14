# frozen_string_literal: true

require 'legion/extensions/cognitive_synesthesia/helpers/constants'
require 'legion/extensions/cognitive_synesthesia/helpers/sensory_mapping'
require 'legion/extensions/cognitive_synesthesia/helpers/synesthetic_event'
require 'legion/extensions/cognitive_synesthesia/helpers/synesthesia_engine'
require 'legion/extensions/cognitive_synesthesia/runners/cognitive_synesthesia'

module Legion
  module Extensions
    module CognitiveSynesthesia
      class Client
        include Runners::CognitiveSynesthesia

        def initialize(engine: nil, **)
          @synesthesia_engine = engine || Helpers::SynesthesiaEngine.new
        end

        private

        attr_reader :synesthesia_engine
      end
    end
  end
end
