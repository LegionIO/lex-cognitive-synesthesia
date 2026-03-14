# frozen_string_literal: true

require 'legion/extensions/cognitive_synesthesia/client'

RSpec.describe Legion::Extensions::CognitiveSynesthesia::Runners::CognitiveSynesthesia do
  let(:client) { Legion::Extensions::CognitiveSynesthesia::Client.new }

  def register_mapping(source: :auditory, target: :visual, trigger: { freq: :high },
                       response: { color: :red }, strength: 0.6)
    client.register_mapping(
      source_modality:  source,
      target_modality:  target,
      trigger_pattern:  trigger,
      response_pattern: response,
      strength:         strength
    )
  end

  describe '#register_mapping' do
    it 'returns success with mapping_id' do
      result = register_mapping
      expect(result[:success]).to be true
      expect(result[:mapping_id]).to match(/\A[0-9a-f-]{36}\z/)
    end

    it 'includes source and target modalities in result' do
      result = register_mapping(source: :tactile, target: :emotional)
      expect(result[:source_modality]).to eq(:tactile)
      expect(result[:target_modality]).to eq(:emotional)
    end

    it 'rejects invalid source_modality' do
      result = client.register_mapping(source_modality: :unknown, target_modality: :visual,
                                       trigger_pattern: {}, response_pattern: {})
      expect(result[:success]).to be false
      expect(result[:error]).to eq(:invalid_modality)
    end

    it 'accepts injected engine kwarg' do
      engine = Legion::Extensions::CognitiveSynesthesia::Helpers::SynesthesiaEngine.new
      result = client.register_mapping(source_modality: :auditory, target_modality: :visual,
                                       trigger_pattern: {}, response_pattern: {}, engine: engine)
      expect(result[:success]).to be true
      expect(engine.mappings.size).to eq(1)
    end
  end

  describe '#trigger' do
    it 'returns success with empty events when no mappings' do
      result = client.trigger(source_modality: :auditory, input: { note: :C4 })
      expect(result[:success]).to be true
      expect(result[:triggered_count]).to eq(0)
    end

    it 'fires events when active mapping exists' do
      register_mapping(source: :auditory, target: :visual, strength: 0.6)
      result = client.trigger(source_modality: :auditory, input: { note: :A4 })
      expect(result[:triggered_count]).to eq(1)
    end

    it 'returns event hashes' do
      register_mapping(source: :auditory, target: :visual, strength: 0.6)
      result = client.trigger(source_modality: :auditory, input: { note: :A4 })
      expect(result[:events].first).to include(:id, :mapping_id, :intensity, :involuntary)
    end

    it 'uses injected engine' do
      engine = Legion::Extensions::CognitiveSynesthesia::Helpers::SynesthesiaEngine.new
      engine.register_mapping(source_modality: :tactile, target_modality: :emotional,
                               trigger_pattern: {}, response_pattern: {}, strength: 0.7)
      result = client.trigger(source_modality: :tactile, input: { pressure: :soft }, engine: engine)
      expect(result[:triggered_count]).to eq(1)
    end
  end

  describe '#decay_mappings' do
    it 'returns success' do
      result = client.decay_mappings
      expect(result[:success]).to be true
    end

    it 'reports removed count' do
      result = client.decay_mappings
      expect(result).to have_key(:mappings_removed)
      expect(result).to have_key(:mappings_remaining)
    end

    it 'decays mappings over multiple calls' do
      register_mapping(strength: 0.4)
      20.times { client.decay_mappings }
      result = client.decay_mappings
      expect(result[:mappings_remaining]).to eq(0)
    end
  end

  describe '#cross_modal_richness' do
    it 'returns success with richness 0.0 initially' do
      result = client.cross_modal_richness
      expect(result[:success]).to be true
      expect(result[:richness]).to eq(0.0)
    end

    it 'returns richness > 0 after adding active mappings' do
      register_mapping(source: :auditory, target: :visual, strength: 0.6)
      result = client.cross_modal_richness
      expect(result[:richness]).to be > 0.0
    end

    it 'includes richness_label' do
      result = client.cross_modal_richness
      expect(result[:richness_label]).to be_a(Symbol)
    end
  end

  describe '#dominant_modality_pairs' do
    it 'returns success with empty pairs initially' do
      result = client.dominant_modality_pairs
      expect(result[:success]).to be true
      expect(result[:pairs]).to be_empty
    end

    it 'returns pairs after triggers' do
      register_mapping(source: :auditory, target: :visual, strength: 0.6)
      3.times { client.trigger(source_modality: :auditory, input: {}) }
      result = client.dominant_modality_pairs
      expect(result[:pairs].first[:pair]).to eq('auditory->visual')
    end

    it 'respects limit' do
      result = client.dominant_modality_pairs(limit: 2)
      expect(result[:count]).to be <= 2
    end
  end

  describe '#event_history' do
    it 'returns success with empty events initially' do
      result = client.event_history
      expect(result[:success]).to be true
      expect(result[:events]).to be_empty
    end

    it 'returns events after triggering' do
      register_mapping(source: :auditory, target: :visual, strength: 0.6)
      client.trigger(source_modality: :auditory, input: {})
      result = client.event_history
      expect(result[:count]).to eq(1)
    end

    it 'respects limit' do
      register_mapping(source: :auditory, target: :visual, strength: 0.8)
      5.times { client.trigger(source_modality: :auditory, input: {}) }
      result = client.event_history(limit: 2)
      expect(result[:count]).to eq(2)
    end
  end

  describe '#modality_coverage' do
    it 'returns success with 0 coverage initially' do
      result = client.modality_coverage
      expect(result[:success]).to be true
      expect(result[:coverage_count]).to eq(0)
    end

    it 'reflects active mappings' do
      register_mapping(source: :auditory, target: :visual, strength: 0.6)
      result = client.modality_coverage
      expect(result[:covered_modalities]).to include(:auditory, :visual)
    end
  end

  describe '#synesthesia_report' do
    it 'returns success with full report hash' do
      result = client.synesthesia_report
      expect(result[:success]).to be true
      expect(result).to include(:mapping_count, :active_mapping_count, :event_count,
                                :cross_modal_richness, :richness_label)
    end

    it 'reflects registered mappings' do
      register_mapping
      result = client.synesthesia_report
      expect(result[:mapping_count]).to eq(1)
    end

    it 'reflects triggered events' do
      register_mapping(source: :auditory, target: :visual, strength: 0.6)
      client.trigger(source_modality: :auditory, input: { note: :G4 })
      result = client.synesthesia_report
      expect(result[:event_count]).to eq(1)
    end
  end
end
