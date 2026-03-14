# frozen_string_literal: true

require_relative 'lib/legion/extensions/cognitive_synesthesia/version'

Gem::Specification.new do |spec|
  spec.name          = 'lex-cognitive-synesthesia'
  spec.version       = Legion::Extensions::CognitiveSynesthesia::VERSION
  spec.authors       = ['Esity']
  spec.email         = ['matthewdiverson@gmail.com']

  spec.summary       = 'LEX Cognitive Synesthesia'
  spec.description   = 'Cross-modal synesthetic mapping for LegionIO agents — automatic ' \
                       'cross-domain associations that enrich understanding through sensory translation'
  spec.homepage      = 'https://github.com/LegionIO/lex-cognitive-synesthesia'
  spec.license       = 'MIT'
  spec.required_ruby_version = '>= 3.4'

  spec.metadata['homepage_uri']          = spec.homepage
  spec.metadata['source_code_uri']       = 'https://github.com/LegionIO/lex-cognitive-synesthesia'
  spec.metadata['documentation_uri']     = 'https://github.com/LegionIO/lex-cognitive-synesthesia'
  spec.metadata['changelog_uri']         = 'https://github.com/LegionIO/lex-cognitive-synesthesia'
  spec.metadata['bug_tracker_uri']       = 'https://github.com/LegionIO/lex-cognitive-synesthesia/issues'
  spec.metadata['rubygems_mfa_required'] = 'true'

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{\A(?:test|spec|features)/}) }
  end
  spec.require_paths = ['lib']
end
