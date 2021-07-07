# frozen_string_literal: true

require 'rails_helper'

describe Hyacinth::Adapters::ExternalIdentifierAdapter::Datacite::RestApi::V2::Data do
  let(:data) { described_class.new }
  let(:good_payload_draft_no_metadata) do
    { type: 'dois',
      attributes: {
        prefix: '10.33555'
      } }
  end
  let(:good_data) do
    { type: 'dois',
      attributes: {
        titles: [{ title: 'The Good Title' }],
        creators: [{ name: "Doe, Jane" }],
        url: 'https://www.columbia.edu',
        publisher: 'Self',
        publicationYear: 2002,
        types: { resourceTypeGeneral: 'Text' },
        schemaVersion: 'http://datacite.org/schema/kernel-4',
        prefix: '10.33555'
      } }
  end
  let(:good_params) do
    {
      title: 'The Good Title',
      doi_url: 'https://www.columbia.edu',
      creators: ['Doe, Jane'],
      doi_prefix: '10.33555',
      publisher: 'Self',
      publication_year: 2002,
      resource_type: 'Text'
    }
  end
  let(:good_params_publication_date_missing) do
    {
      title: 'The Good Title',
      doi_url: 'https://www.columbia.edu',
      creators: ['Doe, Jane'],
      doi_prefix: '10.33555',
      publisher: 'Self',
      resource_type: 'Text'
    }
  end

  describe '#required_attributes_present?' do
    it " returns true for good data passed in" do
      expect(data.required_attributes_present?(good_params)).to be(true)
    end
    it " returns false for bad data passed in" do
      expect(data.required_attributes_present?(good_params_publication_date_missing)).to be(false)
    end
  end

  describe '#reset' do
    # first, set the payload as precondition and verify pre-condition
    it " test precondition: payload set" do
      data.required_metadata(good_params)
      expect(data.data_hash).to eql(good_data)
    end
    it " after call to #reset, data is empty hash" do
      data.reset
      expect(data.data_hash).to eql({})
    end
  end

  describe '#required_metadata' do
    it " sets the data correctly if passed correct params" do
      data.required_metadata(good_params)
      expect(data.data_hash).to eql(good_data)
    end
  end

  describe '#add_event' do
    let(:good_data_with_event) do
      { type: 'dois',
        attributes: {
          titles: [{ title: 'The Good Title' }],
          creators: [{ name: "Doe, Jane" }],
          url: 'https://www.columbia.edu',
          publisher: 'Self',
          publicationYear: 2002,
          types: { resourceTypeGeneral: 'Text' },
          schemaVersion: 'http://datacite.org/schema/kernel-4',
          prefix: '10.33555',
          event: 'publish'
        } }
    end
    it " set the event correctly" do
      data.required_metadata(good_params)
      data.add_event(:findable)
      expect(data.data_hash).to eql(good_data_with_event)
    end
  end

  describe '#build_mint' do
    # add more examples here
    it " works correctly DOI state is draft and metadata is unspecified" do
      data.build_mint('10.33555', :draft)
      expect(data.data_hash).to eql(good_payload_draft_no_metadata)
    end
  end
end
