# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Updating Item Rights', type: :request, solr: true do
  before { Hyacinth::DynamicFieldsLoader.load_rights_fields!(load_vocabularies: true) }

  let(:authorized_project) { FactoryBot.create(:project, :allow_asset_rights) }
  let(:authorized_item) { FactoryBot.create(:item, primary_project: authorized_project) }
  let(:authorized_asset) { FactoryBot.create(:asset, :with_master_resource, parent: authorized_item) }

  include_examples 'requires user to have correct permissions for graphql request' do
    let(:variables) { { input: { id: authorized_item.uid, rights: {} } } }
    let(:request) { graphql query, variables }
  end

  context "when logged in user has appropriate permissions" do
    before do
      # Have to create terms so they rehydrate + dehydrate properly
      Term.create(
        pref_label: 'In Copyright',
        uri: 'https://example.com/term/in_copyright',
        term_type: 'EXTERNAL',
        vocabulary: Vocabulary.find_by(string_key: 'rights_statement')
      )
      Term.create(
        pref_label: "Random, Person",
        term_type: "EXTERNAL",
        uri: "https://example.com/term/random,person",
        vocabulary: Vocabulary.find_by(string_key: 'name')
      )
      Term.create(
        pref_label: "United States",
        term_type: "EXTERNAL",
        uri: "https://example.com/term/united_states",
        vocabulary: Vocabulary.find_by(string_key: 'geonames')
      )
      Term.create(
        pref_label: "Great Location",
        term_type: "EXTERNAL",
        uri: "https://example.com/great_location",
        vocabulary: Vocabulary.find_by(string_key: 'location')
      )
    end

    context 'when updating item rights' do
      let(:variables) do
        {
          input: {
            id: authorized_item.uid,
            rights: {
              descriptive_metadata: [{
                type_of_content: "motion_picture",
                country_of_origin: {
                  pref_label: "United States",
                  term_type: "EXTERNAL",
                  authority: nil,
                  alt_labels: [],
                  uri: "https://example.com/term/united_states"
                },
                film_distributed_to_public: 'yes',
                film_distributed_commercially: 'yes'
              }],
              copyright_status: [{
                copyright_statement: {
                  pref_label: "In Copyright",
                  term_type: "EXTERNAL",
                  authority: nil,
                  alt_labels: [],
                  uri: "https://example.com/term/in_copyright"
                },
                note: "No Copyright Notes",
                copyright_registered: 'yes',
                copyright_renewed: 'yes',
                copyright_date_of_renewal: "2001-01-01",
                copyright_expiration_date: "2001-01-01",
                cul_copyright_assessment_date: "2001-01-01"
              }],
              copyright_ownership: [{
                name: {
                  pref_label: "Random, Person",
                  term_type: "EXTERNAL",
                  authority: nil,
                  alt_labels: [],
                  uri: "https://example.com/term/random,person"
                },
                heirs: "No Heirs",
                contact_information: "No Contact Information"
              }],
              columbia_university_is_copyright_holder: [{
                date_of_transfer: "2001-01-01",
                date_of_expiration: "2001-01-01",
                transfer_documentation: "None",
                other_transfer_evidence: "None",
                transfer_documentation_note: "No Notes"
              }],
              licensed_to_columbia_university: [{
                date_of_license: "2002-01-01",
                termination_date_of_license: "2002-02-02",
                credits: "No credits",
                acknowledgements: "No acknowledgements",
                license_documentation_location: "Unknown"
              }],
              contractual_limitations_restrictions_and_permissions: [{
                option_a: true,
                option_b: true,
                option_c: true,
                option_d: true,
                option_e: true,
                option_av_a: true,
                option_av_b: true,
                option_av_c: true,
                option_av_d: true,
                option_av_e: true,
                option_av_f: true,
                option_av_g: true,
                reproduction_and_distribution_prohibited_until: "2010-01-01",
                photographic_or_film_credit: "No Credits",
                excerpt_limited_to: "23 minutes",
                other: "None",
                permissions_granted_as_part_of_the_use_license: [{ value: "Reproduction" }]
              }],
              underlying_rights: [{
                note: "No underlying rights",
                talent_rights: "SAG AFTRA",
                columbia_music_license: "Master recording license",
                composition: "none",
                recording: "none",
                other_underlying_rights: [{ value: "VARA rights" }],
                other: "no other"
              }]
            }
          }
        }
      end

      let(:expected_rights) do
        variables[:input][:rights].deep_stringify_keys
      end

      before do
        sign_in_project_contributor to: [:read_objects, :assess_rights], project: authorized_project
        graphql query, variables
      end

      it "return a single item with the expected rights fields" do
        expect(response.body).to be_json_eql("\"motion_picture\"").at_path('data/updateRights/digitalObject/rights/descriptive_metadata/0/type_of_content')
      end

      it 'sets rights fields' do
        expect(DigitalObject::Base.find(authorized_item.uid).rights).to include expected_rights
      end
    end

    context 'when updating asset rights' do
      let(:variables) do
        {
          input: {
            id: authorized_asset.uid,
            rights: {
              copyright_status_override: [{
                copyright_statement: {
                  pref_label: "In Copyright",
                  term_type: "EXTERNAL",
                  authority: nil,
                  alt_labels: [],
                  uri: "https://example.com/term/in_copyright"
                },
                note: "No Copyright Notes",
                copyright_registered: 'yes',
                copyright_renewed: 'yes',
                copyright_date_of_renewal: "2001-01-01",
                copyright_expiration_date: "2001-01-01",
                cul_copyright_assessment_date: "2001-01-01"
              }],
              restriction_on_access: [{
                value: "Public Access",
                embargo_release_date: "2001-01-01",
                location: [{
                  term: {
                    pref_label: "Great Location",
                    term_type: "EXTERNAL",
                    uri: "https://example.com/great_location",
                    authority: nil,
                    alt_labels: []
                  }
                }],
                affiliation: [
                  { value: "something" }
                ],
                note: "restriction note"
              }]
            }
          }
        }
      end

      let(:expected_rights) do
        variables[:input][:rights].deep_stringify_keys
      end

      let(:expected_response) do
        {
          'pref_label' => "In Copyright",
          'uri' => "https://example.com/term/in_copyright",
          'term_type' => "external",
          'alt_labels' => [],
          'authority' => nil
        }
      end

      before do
        sign_in_project_contributor to: [:read_objects, :assess_rights], project: authorized_project
        graphql query, variables
      end

      it "return a asset with the expected rights fields" do
        response_data = JSON.parse(response.body)
        copyright_statement = response_data['data']['updateRights']['digitalObject']['rights']['copyright_status_override'][0]['copyright_statement']
        expect(copyright_statement).to include expected_response
      end

      it 'sets rights fields' do
        expect(DigitalObject::Base.find(authorized_asset.uid).rights).to include expected_rights
      end
    end
  end

  def query
    <<~GQL
      mutation ($input: UpdateRightsInput!) {
        updateRights(input: $input) {
          digitalObject {
            id
            rights
          }
        }
      }
    GQL
  end
end
