# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Retrieving Digital Object', type: :request, solr: true do
  let(:authorized_object) do
    FactoryBot.create(:item, :with_rights, :with_descriptive_metadata, :with_other_projects)
  end
  let(:authorized_project) { authorized_object.projects.first }
  let(:authorized_publish_target) { authorized_project.publish_targets.first }

  include_examples 'requires user to have correct permissions for graphql request' do
    let(:request) { graphql query(authorized_object.uid) }
  end

  context 'logged in' do
    before do
      sign_in_project_contributor to: :read_objects, project: authorized_project
      graphql query(authorized_object.uid)
    end

    it "return a single digital object with expected fields" do
      expect(response.body).to be_json_eql(%(
        {
          "id": "#{authorized_object.uid}",
          "title": "The Best Item Ever",
          "numberOfChildren": 0,
          "createdAt": "#{authorized_object.created_at.iso8601}",
          "createdBy": null,
          "digitalObjectType": "ITEM",
          "doi": #{authorized_object.doi.nil? ? 'null' : '"#{authorized_object.doi}"'},
          "descriptiveMetadata": {
            "title": [
              {
                "non_sort_portion": "The",
                "sort_portion": "Best Item Ever"
              }
            ]
          },
          "firstPreservedAt": null,
          "firstPublishedAt": null,
          "identifiers": [
          ],
          "optimisticLockToken": "#{authorized_object.optimistic_lock_token}",
          "parents": [],
          "preservedAt": null,
          "primaryProject": {
            "displayLabel": "Great Project",
            "projectUrl": "https://example.com/great_project",
            "stringKey": "great_project",
            "hasAssetRights": false
          },
          "otherProjects" : [
            {
              "displayLabel": "Other Project A",
              "projectUrl": "https://example.com/other_project_a",
              "stringKey": "other_project_a"
            },
            {
              "displayLabel": "Other Project B",
              "projectUrl": "https://example.com/other_project_b",
              "stringKey": "other_project_b"
            }
          ],
          "publishEntries": [],
          "rights": {
            "descriptive_metadata": [
              {
                "type_of_content": "literary"
              }
            ]
          },
          "resources" : [],
          "state": "ACTIVE",
          "updatedAt": "#{authorized_object.updated_at.iso8601}",
          "updatedBy": null
        }
      )).at_path('data/digitalObject')
    end
    context 'with utf8 descriptive metadata values' do
      let(:authorized_object) do
        FactoryBot.create(:item, :with_rights, :with_utf8_descriptive_metadata, :with_other_projects)
      end
      let(:json_data) { JSON.parse(response.body) }
      let(:actual_value) { json_data&.dig('data', 'digitalObject', 'descriptiveMetadata', 'title', 0, 'sort_portion') }
      # expected value ends in Cora\u00e7\u00e3o (67, 111, 114, 97, 231, 227, 111)
      let(:expected_value) { [80, 97, 114, 97, 32, 77, 97, 99, 104, 117, 99, 97, 114, 32, 77, 101, 117, 32, 67, 111, 114, 97, 231, 227, 111] }
      it "preserves utf-8 data" do
        expect(actual_value&.unpack('U*')).to eql(expected_value)
      end
    end
  end

  context "missing title field" do
    before do
      sign_in_project_contributor to: :read_objects, project: authorized_project
      authorized_object.descriptive_metadata.delete('title')
      authorized_object.save
      graphql query(authorized_object.uid)
    end

    it "return a placeholder no-title value" do
      expect(response.body).to be_json_eql(%(
        "[No Title]"
      )).at_path('data/digitalObject/title')
    end
  end

  context "resources response" do
    let(:authorized_object) { FactoryBot.create(:asset, :with_master_resource) }
    let(:authorized_project) { authorized_object.projects.first }
    before do
      sign_in_project_contributor to: :read_objects, project: authorized_project
      graphql query(authorized_object.uid)
    end
    let(:expected_location) { Rails.root.join('spec', 'fixtures', 'files', 'test.txt').to_s }

    it "returns the expected resources response" do
      expect(response.body).to be_json_eql(%(
        [
          {
            "id": "master",
            "displayLabel": "Master",
            "resource": {
              "checksum": "sha256:717f2c6ffbd649cd57ecc41ac6130c3b6210f1473303bcd9101a9014551bffb2",
              "fileSize": 23,
              "location": "tracked-disk://#{expected_location}",
              "mediaType": "text/plain",
              "originalFilePath": "#{expected_location}",
              "originalFilename": "test.txt"
            }
          },
          {
            "id": "service",
            "displayLabel": "Service",
            "resource": null
          },
          {
            "id": "access",
            "displayLabel": "Access",
            "resource": null
          },
          {
            "id": "poster",
            "displayLabel": "Poster",
            "resource": null
          },
          {
            "id": "fulltext",
            "displayLabel": "Fulltext",
            "resource": null
          }
        ]
      )).at_path('data/digitalObject/resources')
    end
  end

  def query(id)
    <<~GQL
      query {
        digitalObject(id: "#{id}") {
          id
          title
          numberOfChildren
          descriptiveMetadata
          doi
          state
          digitalObjectType
          identifiers
          primaryProject {
            stringKey
            displayLabel
            projectUrl
            hasAssetRights
          }
          otherProjects {
            stringKey
            displayLabel
            projectUrl
          }
          createdAt
          createdBy {
            id
            firstName
            lastName
          }
          updatedAt
          updatedBy {
            id
            firstName
            lastName
          }
          firstPublishedAt
          firstPreservedAt
          preservedAt
          parents {
            id
          }
          publishEntries {
            citationLocation
            publishedAt
            publishedBy {
              id
            }
          }
          optimisticLockToken
          rights
          resources {
            id
            displayLabel
            resource {
              location
              checksum
              originalFilePath
              originalFilename
              mediaType
              fileSize
            }
          }
        }
      }
    GQL
  end
end
