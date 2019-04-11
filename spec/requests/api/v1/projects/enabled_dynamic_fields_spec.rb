require 'rails_helper'

RSpec.describe 'Enabled Dynamic Fields Requests', type: :request do
  let(:project) { FactoryBot.create(:project) }

  describe 'GET /api/v1/projects/:string_key/enabled_dynamic_fields/:digital_object_type' do
    before do
      enabled_dynamic_field = FactoryBot.create(:enabled_dynamic_field, project: project)
      new_dynamic_field = FactoryBot.create(
        :dynamic_field,
        string_key: 'name',
        dynamic_field_group: enabled_dynamic_field.dynamic_field.dynamic_field_group
      )
      FactoryBot.create(:enabled_dynamic_field, project: project, dynamic_field: new_dynamic_field)
    end

    include_examples 'requires user to have correct permissions' do
      let(:request) do
        get "/api/v1/projects/#{project.string_key}/enabled_dynamic_fields/item"
      end
    end

    context 'when logged in user has correct permissions' do
      before { sign_in_project_contributor to: :read_objects, project: project }

      context 'when querying for all item enabled dynamic fields' do
        before do
          get "/api/v1/projects/#{project.string_key}/enabled_dynamic_fields/item"
        end

        it 'returns 200' do
          expect(response.status).to be 200
        end

        it 'returns all expected results' do
          expect(response.body).to be_json_eql(%(
            {
              "enabled_dynamic_fields": [
                {
                  "default_value": null,
                  "dynamic_field_id": 1,
                  "hidden": false,
                  "locked": false,
                  "owner_only": false,
                  "required": true
                },
                {
                  "default_value": null,
                  "dynamic_field_id": 2,
                  "hidden": false,
                  "locked": false,
                  "owner_only": false,
                  "required": true
                }
              ]
            }
          ))
        end
      end
    end
  end

  describe 'PATCH /api/v1/projects/:string_key/enabled_dynamic_fields/:digital_object_type' do
    let(:enabled_dynamic_field) { FactoryBot.create(:enabled_dynamic_field, project: project) }

    include_examples 'requires user to have correct permissions' do
      let(:request) do
        patch "/api/v1/projects/#{project.string_key}/enabled_dynamic_fields/item", params: { enabled_dynamic_fields: [] }
      end
    end

    context 'when logged in user can only read objects within project' do
      include_examples 'does not have access'

      before do
        sign_in_project_contributor to: :read_objects, project: project
        patch "/api/v1/projects/#{project.string_key}/enabled_dynamic_fields/item", params: { enabled_dynamic_fields: [] }
      end
    end

    context 'when logged in user is project manager' do
      before { sign_in_project_contributor to: :manage, project: project }

      context 'when updating an enabled dynamic field' do
        before do
          patch "/api/v1/projects/#{project.string_key}/enabled_dynamic_fields/item", params: {
            enabled_dynamic_fields: [{ id: enabled_dynamic_field.id, locked: true, owner_only: true }]
          }
        end

        it 'returns 200' do
          expect(response.status).to be 200
        end

        it 'correctly updates record' do
          enabled_dynamic_field.reload
          expect(enabled_dynamic_field.locked).to be true
          expect(enabled_dynamic_field.owner_only).to be true
          expect(enabled_dynamic_field.digital_object_type).to eq 'item'
        end
      end

      context 'when trying to change digital_object_type' do
        before do
          patch "/api/v1/projects/#{project.string_key}/enabled_dynamic_fields/item", params: {
            enabled_dynamic_fields: [{ id: enabled_dynamic_field.id, digital_object_type: 'asset' }]
          }
        end

        it 'returns 200' do
          expect(response.status).to be 200
        end

        it 'does not change digital_object_type' do
          enabled_dynamic_field.reload
          expect(enabled_dynamic_field.digital_object_type).to eq 'item'
        end
      end

      context 'when updating multiple enabled_dynamic_fields' do
        let(:new_dynamic_field) do
          FactoryBot.create(
            :dynamic_field,
            string_key: 'name',
            dynamic_field_group: enabled_dynamic_field.dynamic_field.dynamic_field_group
          )
        end

        let(:enabled_dynamic_field_2) do
          FactoryBot.create(:enabled_dynamic_field, project: project, dynamic_field: new_dynamic_field)
        end

        before do
          enabled_dynamic_field_2
          patch "/api/v1/projects/#{project.string_key}/enabled_dynamic_fields/item", params: {
            enabled_dynamic_fields: [
              { id: enabled_dynamic_field.id, owner_only: true },
              { id: enabled_dynamic_field_2.id, required: false }
            ]
          }
        end

        it 'returns 200' do
          expect(response.status).to be 200
        end

        it 'update first dynamic field' do
          enabled_dynamic_field.reload
          expect(enabled_dynamic_field.required).to be true
          expect(enabled_dynamic_field.owner_only).to be true
        end

        it 'updates second dynamic field' do
          enabled_dynamic_field_2.reload
          expect(enabled_dynamic_field_2.required).to be false
          expect(enabled_dynamic_field_2.owner_only).to be false
        end
      end

      context 'when adding field_set' do
        let(:field_set) { FactoryBot.create(:field_set, project: project) }

        before do
          patch "/api/v1/projects/#{project.string_key}/enabled_dynamic_fields/item", params: {
            enabled_dynamic_fields: [{ id: enabled_dynamic_field.id, field_set_ids: [field_set.id] }]
          }
        end

        it 'returns 200' do
          expect(response.status).to be 200
        end

        it 'correctly updates record' do
          enabled_dynamic_field.reload
          expect(enabled_dynamic_field.field_sets).to match_array [field_set]
        end
      end
    end
  end
end
