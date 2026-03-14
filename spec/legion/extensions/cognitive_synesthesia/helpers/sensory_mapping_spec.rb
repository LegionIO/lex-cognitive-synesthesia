# frozen_string_literal: true

RSpec.describe Legion::Extensions::CognitiveSynesthesia::Helpers::SensoryMapping do
  subject(:mapping) do
    described_class.new(
      source_modality:  :auditory,
      target_modality:  :visual,
      trigger_pattern:  { frequency: :high },
      response_pattern: { color: :bright_red },
      strength:         0.6
    )
  end

  describe '#initialize' do
    it 'assigns a UUID id' do
      expect(mapping.id).to match(/\A[0-9a-f-]{36}\z/)
    end

    it 'stores source_modality' do
      expect(mapping.source_modality).to eq(:auditory)
    end

    it 'stores target_modality' do
      expect(mapping.target_modality).to eq(:visual)
    end

    it 'stores trigger_pattern' do
      expect(mapping.trigger_pattern).to eq({ frequency: :high })
    end

    it 'stores response_pattern' do
      expect(mapping.response_pattern).to eq({ color: :bright_red })
    end

    it 'clamps strength to [0, 1]' do
      over  = described_class.new(source_modality: :visual, target_modality: :auditory,
                                  trigger_pattern: {}, response_pattern: {}, strength: 1.5)
      under = described_class.new(source_modality: :visual, target_modality: :auditory,
                                  trigger_pattern: {}, response_pattern: {}, strength: -0.5)
      expect(over.strength).to eq(1.0)
      expect(under.strength).to eq(0.0)
    end

    it 'initializes activation_count to 0' do
      expect(mapping.activation_count).to eq(0)
    end

    it 'sets created_at' do
      expect(mapping.created_at).to be_a(Time)
    end

    it 'last_activated_at is nil initially' do
      expect(mapping.last_activated_at).to be_nil
    end
  end

  describe '#activate!' do
    it 'increments activation_count' do
      expect { mapping.activate! }.to change(mapping, :activation_count).by(1)
    end

    it 'boosts strength by STRENGTH_BOOST' do
      before = mapping.strength
      mapping.activate!
      expect(mapping.strength).to be_within(0.001).of((before + 0.1).clamp(0.0, 1.0))
    end

    it 'clamps strength to 1.0' do
      strong = described_class.new(source_modality: :visual, target_modality: :auditory,
                                   trigger_pattern: {}, response_pattern: {}, strength: 0.95)
      strong.activate!
      expect(strong.strength).to eq(1.0)
    end

    it 'sets last_activated_at' do
      mapping.activate!
      expect(mapping.last_activated_at).to be_a(Time)
    end
  end

  describe '#decay!' do
    it 'reduces strength by STRENGTH_DECAY' do
      before = mapping.strength
      mapping.decay!
      expect(mapping.strength).to be_within(0.001).of((before - 0.02).clamp(0.0, 1.0))
    end

    it 'does not go below 0.0' do
      weak = described_class.new(source_modality: :visual, target_modality: :auditory,
                                 trigger_pattern: {}, response_pattern: {}, strength: 0.01)
      weak.decay!
      expect(weak.strength).to eq(0.0)
    end
  end

  describe '#active?' do
    it 'returns true when strength >= TRIGGER_THRESHOLD' do
      expect(mapping.active?).to be true
    end

    it 'returns false when strength < TRIGGER_THRESHOLD' do
      weak = described_class.new(source_modality: :visual, target_modality: :auditory,
                                 trigger_pattern: {}, response_pattern: {}, strength: 0.1)
      expect(weak.active?).to be false
    end
  end

  describe '#strength_label' do
    it 'returns :strong for strength 0.6' do
      expect(mapping.strength_label).to eq(:strong)
    end

    it 'returns :trace for low strength' do
      weak = described_class.new(source_modality: :visual, target_modality: :auditory,
                                 trigger_pattern: {}, response_pattern: {}, strength: 0.1)
      expect(weak.strength_label).to eq(:trace)
    end
  end

  describe '#to_h' do
    it 'includes all expected keys' do
      h = mapping.to_h
      expect(h).to include(:id, :source_modality, :target_modality, :trigger_pattern,
                            :response_pattern, :strength, :activation_count, :strength_label,
                            :active, :created_at, :last_activated_at)
    end

    it 'reflects activation state after activate!' do
      mapping.activate!
      h = mapping.to_h
      expect(h[:activation_count]).to eq(1)
      expect(h[:last_activated_at]).to be_a(Time)
    end
  end
end
