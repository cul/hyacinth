# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DigitalObjectConcerns::PublishBehavior, solr: true do
  let(:publishing_user) { FactoryBot.create(:user) }
  let(:project) { FactoryBot.create(:project) }
  let(:publish_target_1) do
    FactoryBot.create(:publish_target, project: project, string_key: 'pub1', display_label: 'Pub 1')
  end
  let(:publish_target_2) do
    FactoryBot.create(:publish_target, project: project, string_key: 'pub2', display_label: 'Pub 2')
  end

  let(:digital_object_without_publish_entries) { FactoryBot.create(:digital_object_test_subclass) }
  let(:digital_object_with_publish_entries) do
    obj = FactoryBot.create(:digital_object_test_subclass)
    obj.send(
      :publish_entries=,
      publish_target_1.string_key => Hyacinth::PublishEntry.new(
        published_at: Time.current, published_by: publishing_user
      ),
      publish_target_2.string_key => Hyacinth::PublishEntry.new(
        published_at: Time.current, published_by: publishing_user
      )
    )
    obj
  end

  context "#unpublish_from_all" do
    before do
      # Need to disable deep_copy for this test because it doesn't work when one or more methods
      # are stubbed by rspec, leading to a 'Singleton can't be dumped' error.
      allow(digital_object_with_publish_entries).to receive(:deep_copy)
    end

    it "calls unpublish_from for all current publish_entries" do
      digital_object_with_publish_entries.publish_entries.keys.each do |publish_entry_key|
        expect(digital_object_with_publish_entries).to receive(:unpublish_from)
          .with(PublishTarget.find_by(string_key: publish_entry_key), any_args).ordered.and_call_original
      end
      digital_object_with_publish_entries.unpublish_from_all
    end

    it "doesn't call publish internally when an object has no publish entries" do
      expect(digital_object_without_publish_entries).not_to receive(:publish)
      digital_object_without_publish_entries.unpublish_from_all
    end
  end
end