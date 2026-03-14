# frozen_string_literal: true

require 'legion/extensions/cognitive_synesthesia/client'

RSpec.describe Legion::Extensions::CognitiveSynesthesia::Client do
  let(:client) { described_class.new }

  it 'responds to all runner methods' do
    expect(client).to respond_to(:register_mapping)
    expect(client).to respond_to(:trigger)
    expect(client).to respond_to(:decay_mappings)
    expect(client).to respond_to(:cross_modal_richness)
    expect(client).to respond_to(:dominant_modality_pairs)
    expect(client).to respond_to(:event_history)
    expect(client).to respond_to(:modality_coverage)
    expect(client).to respond_to(:synesthesia_report)
  end

  it 'accepts an injected engine' do
    engine = Legion::Extensions::CognitiveSynesthesia::Helpers::SynesthesiaEngine.new
    c = described_class.new(engine: engine)
    c.register_mapping(source_modality: :auditory, target_modality: :visual,
                       trigger_pattern: {}, response_pattern: {})
    expect(engine.mappings.size).to eq(1)
  end

  it 'maintains state across calls' do
    client.register_mapping(source_modality: :auditory, target_modality: :visual,
                            trigger_pattern: { freq: :high }, response_pattern: { color: :red },
                            strength: 0.7)
    client.trigger(source_modality: :auditory, input: { note: :A4 })
    report = client.synesthesia_report
    expect(report[:mapping_count]).to eq(1)
    expect(report[:event_count]).to eq(1)
  end

  it 'runs a full cross-modal cycle' do
    client.register_mapping(source_modality: :semantic, target_modality: :visual,
                            trigger_pattern: { concept: :danger }, response_pattern: { hue: :red },
                            strength: 0.8)
    client.register_mapping(source_modality: :semantic, target_modality: :emotional,
                            trigger_pattern: { concept: :danger }, response_pattern: { tone: :fear },
                            strength: 0.7)

    events = client.trigger(source_modality: :semantic, input: { concept: :danger })
    expect(events[:triggered_count]).to eq(2)

    richness = client.cross_modal_richness
    expect(richness[:richness]).to be > 0.0

    coverage = client.modality_coverage
    expect(coverage[:covered_modalities]).to include(:semantic, :visual, :emotional)

    history = client.event_history(limit: 5)
    expect(history[:count]).to eq(2)
  end
end
