require 'rails_helper'

describe Hyacinth::Adapters::PreservationAdapter::Fedora3 do
  let(:connection) { Rubydora::Repository.new({}, connection_api) }
  let(:connection_api) do
    a = instance_double("Rubydora::Fc3Service")
    allow(a).to receive(:repository_profile)
    a
  end
  let(:resource) { instance_double("RestClient::Resource") }
  let(:subresource) { instance_double("RestClient::Resource") }
  let(:object_pid) { "test:1" }
  let(:location_uri) { "fedora3://" + object_pid }
  let(:pid_generator) { instance_double(PidGenerator) }
  let(:adapter_args) { { url: 'foo', password: 'foo', user: 'foo', pid_generator: pid_generator } }
  let(:adapter) do
    a = described_class.new(adapter_args)
    a.instance_variable_set("@connection", connection)
    a
  end
  let(:request) do
    a = instance_double("RestClient::Request")
    allow(a).to receive(:args).and_return({})
    a
  end
  let(:dc_xml_src) { file_fixture("fedora3/update-dc.xml").read }

  before do
    allow(connection).to receive(:client).and_return(resource)
    allow(request).to receive(:redirection_history).and_return []
    allow(connection).to receive(:datastream_dissemination).with(dsid: 'DC', pid: object_pid).and_return(dc_xml_src)
  end

  describe "#location_uri_to_fedora3_pid" do
    subject { adapter.location_uri_to_fedora3_pid(location_uri) }
    it { is_expected.to eql(object_pid) }
  end

  describe "#exists?" do
    let(:object_url) { "/objects/#{object_pid}/object.xml" }
    let(:response_headers) { {} }
    context "an object exists" do
      let(:net_http_response) do
        a = instance_double("Net::HTTPOK")
        allow(a).to receive(:code).and_return 200
        allow(a).to receive(:to_hash).and_return response_headers
        a
      end
      let(:response) { RestClient::Response.create("OK", net_http_response, request) }

      before do
        allow(resource).to receive(:[]).with(object_url).and_return(subresource)
        expect(connection_api).to receive(:object_url).with(object_pid, format: 'xml').and_return(object_url)
        expect(subresource).to receive(:head).and_return(response)
        expect(net_http_response).to receive(:code).and_return(200)
      end

      it { expect(adapter.exists?(location_uri)).to be true }
    end

    context "an object does not exist" do
      let(:net_http_response) do
        a = instance_double("Net::HTTPNotFound")
        allow(a).to receive(:code).and_return 404
        allow(a).to receive(:to_hash).and_return response_headers
        a
      end
      let(:response) { RestClient::Response.create("Not Found", net_http_response, request) }
      let(:exception_with_response) { RestClient::ExceptionWithResponse.new(response) }

      before do
        allow(resource).to receive(:[]).with(object_url).and_return(subresource)
        expect(connection_api).to receive(:object_url).with(object_pid, format: 'xml').and_return(object_url)
        expect(subresource).to receive(:head).and_raise(exception_with_response)
      end

      it { expect(adapter.exists?(location_uri)).to be false }
    end

    context "the repository raises a runtime error" do
      let(:net_http_response) do
        a = instance_double("Net::HTTPServerError")
        allow(a).to receive(:code).and_return 500
        allow(a).to receive(:to_hash).and_return response_headers
        a
      end
      let(:response) { RestClient::Response.create("A runtime error", net_http_response, request) }
      let(:exception_with_response) { RestClient::RequestFailed.new(response) }

      before do
        allow(resource).to receive(:[]).with(object_url).and_return(subresource)
        expect(connection_api).to receive(:object_url).with(object_pid, format: 'xml').and_return(object_url)
        expect(subresource).to receive(:head).and_raise(exception_with_response)
        expect(net_http_response).to receive(:code).and_return(500)
      end

      it "passes along the error" do
        expect { adapter.exists?(location_uri) }.to raise_exception(RestClient::RequestFailed)
      end
    end
  end
  describe "#generate_new_location_uri" do
    subject { adapter.generate_new_location_uri }
    before do
      allow(pid_generator).to receive(:next_pid).and_return(*([1, 2, 3].map { |x| "test:#{x}" }))
      allow(adapter).to receive(:exists?).and_return(true, true, false)
    end
    it "returns the first new location URI" do
      is_expected.to eql("fedora3://test:3")
    end
  end
  describe "#persist_impl" do
    let(:rubydora_object) { Rubydora::DigitalObject.new(object_pid, connection) }
    let(:hyacinth_object) { DigitalObject::Item.new }
    let(:profile_xml) { file_fixture("fedora3/new-object.xml").read }
    let(:datastreams_xml) { file_fixture("fedora3/new-datastreams.xml").read }
    before do
      expect(connection).to receive(:find_or_initialize).with(object_pid).and_return(rubydora_object)
      expect(connection).to receive(:object_profile).with(object_pid, nil).and_return(profile_xml)
      expect(connection).to receive(:datastreams).with(pid: object_pid, profiles: "true").and_return(datastreams_xml)
      dsids.each do |dsid|
        expect(connection).to receive(:datastream_profile).with(object_pid, dsid, nil, nil).and_return({})
      end
      expect(rubydora_object).to receive(:save).and_return(nil)
      allow(rubydora_object).to receive(:relationship).and_return([]) # all new values!
    end
    context "core data" do
      let(:dsids) { [described_class::HYACINTH_CORE_DATASTREAM_NAME, 'structMetadata'] }

      # test rels-ext elsewhere
      before { allow(connection).to receive(:add_relationship) }

      it "persists core data to Fedora3" do
        adapter.persist_impl("fedora3://#{object_pid}", hyacinth_object)
        actual_json = JSON.parse(rubydora_object.datastreams[described_class::HYACINTH_CORE_DATASTREAM_NAME].content)
        expect(actual_json).to have_key("uid")
      end
    end
    context "field exports" do
      let(:dsids) { ['descMetadata', 'structMetadata'] }
      let(:digital_object_title) { "Assigned Label" }
      before do
        FactoryBot.create(:export_rule) # creates descMetadata
        expect(connection).to receive(:datastream_profile).with(object_pid, described_class::HYACINTH_CORE_DATASTREAM_NAME, nil, nil).and_return({})
        # test rels-ext elsewhere
        allow(connection).to receive(:add_relationship)
      end
      it "persists templated field exports to datastreams" do
        hyacinth_object.dynamic_field_data['name'] = [{ 'role' => "Farmer" }]
        adapter.persist_impl("fedora3://#{object_pid}", hyacinth_object)
        actual_xml = rubydora_object.datastreams["descMetadata"].content
        actual_xml.sub!(/^<\?.+\?>/, '') # remove PI
        actual_xml.gsub!('mods:', '') # remove ns
        actual_xml.gsub!(/\s/, '') # remove whitespace
        expect(actual_xml).to eql("<mods><name>Farmer</name></mods>")
      end
      it "makes a core object property assignments" do
        hyacinth_object.dynamic_field_data['title'] = [{ 'title_sort_portion' => digital_object_title }]
        adapter.persist_impl("fedora3://#{object_pid}", hyacinth_object)
        expect(rubydora_object.label).to eql(digital_object_title)
        expect(rubydora_object.state).to eql('A')
      end
      it "assigns a state property to inactive if withdrawn" do
        hyacinth_object.state = Hyacinth::DigitalObject::State::WITHDRAWN
        adapter.persist_impl("fedora3://#{object_pid}", hyacinth_object)
        expect(rubydora_object.state).to eql('I')
      end
    end
    context "basic rels-ext properties" do
      let(:dsids) { ['structMetadata'] }
      let(:digital_object_title) { "Assigned Label" }
      let(:model_property) do
        {
          predicate: "info:fedora/fedora-system:def/model#hasModel",
          object: "info:fedora/ldpd:ContentAggregator",
          pid: object_pid
        }
      end
      let(:rdftype_property) do
        {
          predicate: "http://www.w3.org/1999/02/22-rdf-syntax-ns#type",
          object: "http://purl.oclc.org/NET/CUL/Aggregator",
          pid: object_pid
        }
      end
      let(:restriction_property) do
        {
          predicate: "http://www.loc.gov/premis/rdf/v1#hasRestriction",
          object: "onsite restriction",
          pid: object_pid,
          isLiteral: true
        }
      end
      before do
        expect(connection).to receive(:datastream_profile).with(object_pid, described_class::HYACINTH_CORE_DATASTREAM_NAME, nil, nil).and_return({})
        expect(connection).to receive(:add_relationship).with(model_property)
        expect(connection).to receive(:add_relationship).with(rdftype_property)
        expect(connection).to receive(:add_relationship).with(restriction_property)
      end
      it "persists model properties" do
        hyacinth_object.dynamic_field_data['restrictions'] = { 'restricted_onsite' => true }
        adapter.persist_impl("fedora3://#{object_pid}", hyacinth_object)
      end
    end
    context "DC properties" do
      # do not need to fetch profiles for DC and RELS-EXT
      let(:dsids) { ['structMetadata'] }
      before do
        expect(connection).to receive(:datastream_profile).with(object_pid, described_class::HYACINTH_CORE_DATASTREAM_NAME, nil, nil).and_return({})
        allow(connection).to receive(:add_relationship) # tested elsewhere
      end
      it "persists model properties" do
        hyacinth_object.identifiers << 'keep'
        adapter.persist_impl("fedora3://#{object_pid}", hyacinth_object)
        # because .save is stubbed, the datastream should still be dirty
        expect(rubydora_object.datastreams['DC'].changed?).to be(true)
        expect(rubydora_object.datastreams['DC'].content).to include("<dc:identifier>keep</dc:identifier>")
        expect(rubydora_object.datastreams['DC'].content).not_to include("<dc:identifier>remove</dc:identifier>")
      end
    end
    context "Struct properties" do
      # do not need to fetch profiles for DC and RELS-EXT
      let(:dsids) { ['structMetadata'] }
      let(:child_object_title) { "Assigned Label" }
      let(:child_uid) { 'asdf' }
      let(:child_hyacinth_object) do
        obj = DigitalObject::Item.new
        obj.dynamic_field_data['title'] = [{ 'title_sort_portion' => child_object_title }]
        obj.instance_variable_set(:@uid, child_uid)
        obj
      end

      before do
        hyacinth_object.structured_children['structure'] << child_uid
        expect(connection).to receive(:datastream_profile).with(object_pid, described_class::HYACINTH_CORE_DATASTREAM_NAME, nil, nil).and_return({})
        allow(connection).to receive(:add_relationship) # tested elsewhere
        expect(::DigitalObject::Base).to receive(:find).with(child_uid).and_return(child_hyacinth_object)
      end

      it "persists model properties" do
        hyacinth_object.identifiers << 'keep'
        adapter.persist_impl("fedora3://#{object_pid}", hyacinth_object)
        # because .save is stubbed, the datastream should still be dirty
        expect(rubydora_object.datastreams['structMetadata'].changed?).to be(true)
        expect(rubydora_object.datastreams['structMetadata'].content).to include("<mets:div LABEL=\"#{child_object_title}\" ORDER=\"1\" CONTENTIDS=\"#{child_uid}\"/>")
      end
    end
  end
end