# frozen_string_literal: true

RSpec.describe Legion::Extensions::CognitiveSynesthesia::Helpers::Constants do
  describe 'constants' do
    it 'defines MAX_MAPPINGS' do
      expect(described_class::MAX_MAPPINGS).to eq(200)
    end

    it 'defines MAX_EVENTS' do
      expect(described_class::MAX_EVENTS).to eq(500)
    end

    it 'defines DEFAULT_STRENGTH' do
      expect(described_class::DEFAULT_STRENGTH).to eq(0.5)
    end

    it 'defines STRENGTH_BOOST' do
      expect(described_class::STRENGTH_BOOST).to eq(0.1)
    end

    it 'defines STRENGTH_DECAY' do
      expect(described_class::STRENGTH_DECAY).to eq(0.02)
    end

    it 'defines TRIGGER_THRESHOLD' do
      expect(described_class::TRIGGER_THRESHOLD).to eq(0.3)
    end

    it 'defines 8 modalities' do
      expect(described_class::MODALITIES.size).to eq(8)
    end

    it 'includes all expected modalities' do
      expect(described_class::MODALITIES).to include(:visual, :auditory, :tactile, :emotional,
                                                     :semantic, :temporal, :spatial, :abstract)
    end

    it 'defines STRENGTH_LABELS with range keys' do
      expect(described_class::STRENGTH_LABELS).to be_a(Hash)
      expect(described_class::STRENGTH_LABELS.values).to include(:dominant, :strong, :moderate, :faint, :trace)
    end

    it 'defines RICHNESS_LABELS with range keys' do
      expect(described_class::RICHNESS_LABELS).to be_a(Hash)
      expect(described_class::RICHNESS_LABELS.values).to include(:synesthetic, :vivid, :partial, :sparse, :amodal)
    end

    it 'defines INTENSITY_LABELS with range keys' do
      expect(described_class::INTENSITY_LABELS).to be_a(Hash)
      expect(described_class::INTENSITY_LABELS.values).to include(:overwhelming, :intense, :moderate, :subtle, :subliminal)
    end
  end

  describe '.label_for' do
    it 'returns dominant for value 0.9' do
      expect(described_class.label_for(described_class::STRENGTH_LABELS, 0.9)).to eq(:dominant)
    end

    it 'returns strong for value 0.7' do
      expect(described_class.label_for(described_class::STRENGTH_LABELS, 0.7)).to eq(:strong)
    end

    it 'returns moderate for value 0.5' do
      expect(described_class.label_for(described_class::STRENGTH_LABELS, 0.5)).to eq(:moderate)
    end

    it 'returns faint for value 0.3' do
      expect(described_class.label_for(described_class::STRENGTH_LABELS, 0.3)).to eq(:faint)
    end

    it 'returns trace for value 0.1' do
      expect(described_class.label_for(described_class::STRENGTH_LABELS, 0.1)).to eq(:trace)
    end

    it 'returns unknown for nil' do
      expect(described_class.label_for(described_class::STRENGTH_LABELS, nil)).to eq(:unknown)
    end

    it 'works with RICHNESS_LABELS' do
      expect(described_class.label_for(described_class::RICHNESS_LABELS, 0.9)).to eq(:synesthetic)
      expect(described_class.label_for(described_class::RICHNESS_LABELS, 0.1)).to eq(:amodal)
    end

    it 'works with INTENSITY_LABELS' do
      expect(described_class.label_for(described_class::INTENSITY_LABELS, 0.9)).to eq(:overwhelming)
      expect(described_class.label_for(described_class::INTENSITY_LABELS, 0.1)).to eq(:subliminal)
    end
  end
end
