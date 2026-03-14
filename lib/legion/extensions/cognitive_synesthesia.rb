# frozen_string_literal: true

require 'legion/extensions/cognitive_synesthesia/version'
require 'legion/extensions/cognitive_synesthesia/helpers/constants'
require 'legion/extensions/cognitive_synesthesia/helpers/sensory_mapping'
require 'legion/extensions/cognitive_synesthesia/helpers/synesthetic_event'
require 'legion/extensions/cognitive_synesthesia/helpers/synesthesia_engine'
require 'legion/extensions/cognitive_synesthesia/runners/cognitive_synesthesia'

module Legion
  module Extensions
    module CognitiveSynesthesia
      extend Legion::Extensions::Core if Legion::Extensions.const_defined? :Core
    end
  end
end
