# frozen_string_literal: true

require 'rails_helper'

describe Hyacinth::Adapters::ExternalIdentifierAdapter::Datacite::RestApi::V2::Api do
  let(:api) { described_class.new('https://api.test.datacite.org', 'FriendlyUser', 'FriendlyPassword') }
  let(:metadata) do
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
  let(:mocked_headers) do
    { 'Accept' => '*/*', 'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
      'Authorization' => 'Basic RnJpZW5kbHlVc2VyOkZyaWVuZGx5UGFzc3dvcmQ=',
      'Content-Type' => 'application/vnd.api+json', 'User-Agent' => 'Ruby' }
  end
  describe '#post_dois' do
    it " sends a POST request" do
      data = Hyacinth::Adapters::ExternalIdentifierAdapter::Datacite::RestApi::V2::Data.new
      data.data_hash = metadata
      stub_request(:post, "https://api.test.datacite.org/dois").with(
        body: data.generate_json_payload,
        headers: mocked_headers
      ).to_return(status: 200, body: "", headers: {})
      api.post_dois(data)
    end
  end
  describe '#put_dois' do
    it " sends a PUT request" do
      data = Hyacinth::Adapters::ExternalIdentifierAdapter::Datacite::RestApi::V2::Data.new
      data.data_hash = metadata
      stub_request(:put, "https://api.test.datacite.org/dois/10.33555/2Y0J-BC24").with(
        body: data.generate_json_payload,
        headers: mocked_headers
      ).to_return(status: 200, body: "", headers: {})
      api.put_dois('10.33555/2Y0J-BC24', data)
    end
  end
end
