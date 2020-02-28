# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DigitalObjectConcerns::AttributeAssignment do
  let(:digital_object_with_sample_data) { FactoryBot.build(:digital_object_test_subclass, :with_sample_data) }
  let(:digital_object_data) do
    {
      'dynamic_field_data' => {
        'note' => [
          {
            'value' => 'Great Note',
            'type' => 'So Great'
          }
        ]
      }
    }
  end
  context "#assign_attributes" do
    it "calls the expected sub-methods and changes some data" do
      expect(digital_object_with_sample_data).to receive(:assign_dynamic_field_data).with(digital_object_data, true).and_call_original
      expect(digital_object_with_sample_data).to receive(:assign_doi).with(digital_object_data).and_call_original
      expect(digital_object_with_sample_data).to receive(:assign_identifiers).with(digital_object_data).and_call_original
      expect(digital_object_with_sample_data).to receive(:assign_mint_doi).with(digital_object_data).and_call_original
      expect(digital_object_with_sample_data).to receive(:assign_optimistic_lock_token).with(digital_object_data).and_call_original
      expect(digital_object_with_sample_data).to receive(:assign_parent_uids).with(digital_object_data).and_call_original
      expect(digital_object_with_sample_data).to receive(:assign_pending_publish_entries).with(digital_object_data).and_call_original
      expect(digital_object_with_sample_data).to receive(:assign_resources).with(digital_object_data).and_call_original
      expect(digital_object_with_sample_data).to receive(:assign_state).with(digital_object_data).and_call_original
      expect(digital_object_with_sample_data).to receive(:assign_preserve).with(digital_object_data).and_call_original
      expect(digital_object_with_sample_data).to receive(:assign_projects).with(digital_object_data).and_call_original
      expect(digital_object_with_sample_data).to receive(:assign_rights).with(digital_object_data).and_call_original

      digital_object_with_sample_data.assign_attributes(digital_object_data, true)

      expect(digital_object_with_sample_data.dynamic_field_data['title']).to eq([{
        'non_sort_portion' => 'The',
        'sort_portion' => 'Tall Man and His Hat'
      }])

      expect(digital_object_with_sample_data.dynamic_field_data['note']).to eq([{
        'value' => 'Great Note',
        'type' => 'So Great'
      }])
    end
  end
end
