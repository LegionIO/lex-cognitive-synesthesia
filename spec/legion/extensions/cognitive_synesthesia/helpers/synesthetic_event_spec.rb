# frozen_string_literal: true

RSpec.describe Legion::Extensions::CognitiveSynesthesia::Helpers::SynestheticEvent do
  subject(:event) do
    described_class.new(
      mapping_id:    'abc-123',
      source_input:  { note: :C4 },
      target_output: { color: :red },
      intensity:     0.75
    )
  end

  describe '#initialize' do
    it 'assigns a UUID id' do
      expect(event.id).to match(/\A[0-9a-f-]{36}\z/)
    end

    it 'stores mapping_id' do
      expect(event.mapping_id).to eq('abc-123')
    end

    it 'stores source_input' do
      expect(event.source_input).to eq({ note: :C4 })
    end

    it 'stores target_output' do
      expect(event.target_output).to eq({ color: :red })
    end

    it 'clamps intensity to [0, 1]' do
      over  = described_class.new(mapping_id: 'x', source_input: {}, target_output: {}, intensity: 2.0)
      under = described_class.new(mapping_id: 'x', source_input: {}, target_output: {}, intensity: -1.0)
      expect(over.intensity).to eq(1.0)
      expect(under.intensity).to eq(0.0)
    end

    it 'defaults involuntary to true' do
      expect(event.involuntary).to be true
    end

    it 'accepts involuntary: false' do
      voluntary = described_class.new(mapping_id: 'x', source_input: {}, target_output: {},
                                      intensity: 0.5, involuntary: false)
      expect(voluntary.involuntary).to be false
    end

    it 'sets triggered_at' do
      expect(event.triggered_at).to be_a(Time)
    end
  end

  describe '#intensity_label' do
    it 'returns :intense for intensity 0.75' do
      expect(event.intensity_label).to eq(:intense)
    end

    it 'returns :subliminal for very low intensity' do
      soft = described_class.new(mapping_id: 'x', source_input: {}, target_output: {}, intensity: 0.05)
      expect(soft.intensity_label).to eq(:subliminal)
    end

    it 'returns :overwhelming for intensity 0.9' do
      loud = described_class.new(mapping_id: 'x', source_input: {}, target_output: {}, intensity: 0.9)
      expect(loud.intensity_label).to eq(:overwhelming)
    end
  end

  describe '#to_h' do
    it 'includes all expected keys' do
      h = event.to_h
      expect(h).to include(:id, :mapping_id, :source_input, :target_output,
                           :intensity, :intensity_label, :involuntary, :triggered_at)
    end

    it 'reflects correct intensity' do
      expect(event.to_h[:intensity]).to eq(0.75)
    end

    it 'reflects involuntary flag' do
      expect(event.to_h[:involuntary]).to be true
    end
  end
end
