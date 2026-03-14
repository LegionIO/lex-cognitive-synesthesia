# frozen_string_literal: true

RSpec.describe Legion::Extensions::CognitiveSynesthesia::Helpers::SynesthesiaEngine do
  subject(:engine) { described_class.new }

  def register(source: :auditory, target: :visual, trigger: { freq: :high },
               response: { color: :red }, strength: 0.6)
    engine.register_mapping(
      source_modality:  source,
      target_modality:  target,
      trigger_pattern:  trigger,
      response_pattern: response,
      strength:         strength
    )
  end

  describe '#register_mapping' do
    it 'returns success with mapping_id' do
      result = register
      expect(result[:success]).to be true
      expect(result[:mapping_id]).to match(/\A[0-9a-f-]{36}\z/)
    end

    it 'stores the mapping' do
      register
      expect(engine.mappings.size).to eq(1)
    end

    it 'rejects invalid source_modality' do
      result = engine.register_mapping(source_modality: :unknown, target_modality: :visual,
                                       trigger_pattern: {}, response_pattern: {})
      expect(result[:success]).to be false
      expect(result[:error]).to eq(:invalid_modality)
      expect(result[:field]).to eq(:source_modality)
    end

    it 'rejects invalid target_modality' do
      result = engine.register_mapping(source_modality: :auditory, target_modality: :unknown,
                                       trigger_pattern: {}, response_pattern: {})
      expect(result[:success]).to be false
      expect(result[:error]).to eq(:invalid_modality)
      expect(result[:field]).to eq(:target_modality)
    end

    it 'accepts all valid modalities' do
      pairs = [%i[visual auditory], %i[tactile emotional], %i[semantic temporal],
               %i[spatial abstract], %i[abstract visual]]
      pairs.each do |src, tgt|
        result = engine.register_mapping(source_modality: src, target_modality: tgt,
                                         trigger_pattern: {}, response_pattern: {})
        expect(result[:success]).to be true
      end
    end

    it 'prunes when exceeding MAX_MAPPINGS' do
      201.times { register }
      expect(engine.mappings.size).to eq(200)
    end
  end

  describe '#trigger' do
    it 'returns success with empty events when no active mappings' do
      result = engine.trigger(source_modality: :auditory, input: { note: :C4 })
      expect(result[:success]).to be true
      expect(result[:events]).to be_empty
      expect(result[:triggered_count]).to eq(0)
    end

    it 'fires events for matching active mappings' do
      register(source: :auditory, target: :visual, strength: 0.6)
      result = engine.trigger(source_modality: :auditory, input: { note: :C4 })
      expect(result[:triggered_count]).to eq(1)
      expect(result[:events].first[:mapping_id]).to match(/\A[0-9a-f-]{36}\z/)
    end

    it 'does not fire events for different source modality' do
      register(source: :visual, target: :auditory, strength: 0.6)
      result = engine.trigger(source_modality: :tactile, input: { pressure: :high })
      expect(result[:triggered_count]).to eq(0)
    end

    it 'does not fire events for below-threshold mappings' do
      register(source: :auditory, target: :visual, strength: 0.1)
      result = engine.trigger(source_modality: :auditory, input: { note: :C4 })
      expect(result[:triggered_count]).to eq(0)
    end

    it 'strengthens the mapping on each trigger' do
      register(source: :auditory, target: :visual, strength: 0.6)
      before = engine.mappings.values.first.strength
      engine.trigger(source_modality: :auditory, input: {})
      expect(engine.mappings.values.first.strength).to be > before
    end

    it 'fires from multiple active mappings for the same modality' do
      register(source: :auditory, target: :visual, strength: 0.6)
      register(source: :auditory, target: :emotional, strength: 0.7)
      result = engine.trigger(source_modality: :auditory, input: { note: :D4 })
      expect(result[:triggered_count]).to eq(2)
    end

    it 'stores events in @events' do
      register(source: :auditory, target: :visual, strength: 0.6)
      engine.trigger(source_modality: :auditory, input: {})
      expect(engine.events.size).to eq(1)
    end

    it 'caps events at MAX_EVENTS' do
      register(source: :auditory, target: :visual, strength: 1.0)
      501.times { engine.trigger(source_modality: :auditory, input: {}) }
      expect(engine.events.size).to eq(500)
    end

    it 'event has involuntary: true by default' do
      register(source: :auditory, target: :visual, strength: 0.6)
      engine.trigger(source_modality: :auditory, input: {})
      expect(engine.events.first.involuntary).to be true
    end

    it 'event target_output contains modality and response_pattern' do
      register(source: :auditory, target: :visual, strength: 0.6,
               response: { color: :blue })
      engine.trigger(source_modality: :auditory, input: { note: :E4 })
      output = engine.events.first.target_output
      expect(output[:modality]).to eq(:visual)
      expect(output[:response_pattern]).to eq({ color: :blue })
    end
  end

  describe '#decay_mappings!' do
    it 'returns success' do
      result = engine.decay_mappings!
      expect(result[:success]).to be true
    end

    it 'decays all mapping strengths' do
      register(strength: 0.6)
      before = engine.mappings.values.first.strength
      engine.decay_mappings!
      expect(engine.mappings.values.first.strength).to be < before
    end

    it 'removes mappings that decay to 0' do
      register(strength: 0.01)
      engine.decay_mappings!
      expect(engine.mappings).to be_empty
    end

    it 'reports removed and remaining counts' do
      2.times { register }
      result = engine.decay_mappings!
      expect(result).to have_key(:mappings_removed)
      expect(result).to have_key(:mappings_remaining)
    end
  end

  describe '#cross_modal_richness' do
    it 'returns 0.0 with no mappings' do
      expect(engine.cross_modal_richness).to eq(0.0)
    end

    it 'returns a value between 0 and 1' do
      register(source: :auditory, target: :visual, strength: 0.6)
      register(source: :visual, target: :emotional, strength: 0.6)
      expect(engine.cross_modal_richness).to be_between(0.0, 1.0)
    end

    it 'increases as more unique pairs are added' do
      register(source: :auditory, target: :visual, strength: 0.6)
      richness_before = engine.cross_modal_richness
      register(source: :tactile, target: :emotional, strength: 0.6)
      richness_after = engine.cross_modal_richness
      expect(richness_after).to be >= richness_before
    end
  end

  describe '#dominant_modality_pairs' do
    it 'returns empty when no mappings' do
      expect(engine.dominant_modality_pairs).to be_empty
    end

    it 'returns pairs sorted by activation count' do
      register(source: :auditory, target: :visual, strength: 0.6)
      3.times { engine.trigger(source_modality: :auditory, input: {}) }
      register(source: :tactile, target: :emotional, strength: 0.6)
      engine.trigger(source_modality: :tactile, input: {})

      pairs = engine.dominant_modality_pairs
      expect(pairs.first[:pair]).to eq('auditory->visual')
    end

    it 'respects the limit' do
      5.times do |i|
        mods = Legion::Extensions::CognitiveSynesthesia::Helpers::Constants::MODALITIES
        src  = mods[i]
        tgt  = mods[i + 1]
        register(source: src, target: tgt, strength: 0.6)
      end
      pairs = engine.dominant_modality_pairs(limit: 3)
      expect(pairs.size).to be <= 3
    end
  end

  describe '#event_history' do
    it 'returns empty when no events' do
      result = engine.event_history
      expect(result[:success]).to be true
      expect(result[:events]).to be_empty
      expect(result[:count]).to eq(0)
    end

    it 'returns recent events up to limit' do
      register(source: :auditory, target: :visual, strength: 0.6)
      5.times { engine.trigger(source_modality: :auditory, input: {}) }
      result = engine.event_history(limit: 3)
      expect(result[:count]).to eq(3)
    end
  end

  describe '#modality_coverage' do
    it 'returns 0 covered with no active mappings' do
      result = engine.modality_coverage
      expect(result[:coverage_count]).to eq(0)
      expect(result[:total_modalities]).to eq(8)
    end

    it 'returns covered modalities from active mappings' do
      register(source: :auditory, target: :visual, strength: 0.6)
      result = engine.modality_coverage
      expect(result[:covered_modalities]).to include(:auditory, :visual)
      expect(result[:coverage_count]).to eq(2)
    end

    it 'does not double-count modalities' do
      register(source: :auditory, target: :visual, strength: 0.6)
      register(source: :auditory, target: :emotional, strength: 0.6)
      result = engine.modality_coverage
      expect(result[:covered_modalities].count(:auditory)).to eq(1)
    end
  end

  describe '#synesthesia_report' do
    it 'returns a comprehensive hash' do
      result = engine.synesthesia_report
      expect(result).to include(:mapping_count, :active_mapping_count, :event_count,
                                :cross_modal_richness, :richness_label,
                                :dominant_modality_pairs, :modality_coverage)
    end

    it 'reflects registered mappings' do
      register
      result = engine.synesthesia_report
      expect(result[:mapping_count]).to eq(1)
    end

    it 'includes a richness_label' do
      expect(engine.synesthesia_report[:richness_label]).to be_a(Symbol)
    end
  end
end
