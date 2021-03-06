# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Retrieving Dynamic Field Category', type: :request do
  let(:dynamic_field_category) { FactoryBot.create(:dynamic_field_category) }

  before { sign_in_user }

  context 'when id is valid' do
    before { graphql query(dynamic_field_category.id) }

    it 'returns correct response' do
      expect(response.body).to be_json_eql(%(
            { "dynamicFieldCategory": { "displayLabel": "Descriptive Metadata", "children": [], "sortOrder": 3 } }
           )).at_path('data')
    end
  end

  context 'when id is invalid' do
    before { graphql query("1234") }

    it 'returns correct response' do
      expect(response.body).to be_json_eql(%(
          "Couldn't find DynamicFieldCategory with 'id'=1234"
        )).at_path('errors/0/message')
    end
  end

  def query(id)
    <<~GQL
    query {
      dynamicFieldCategory(id: "#{id}") {
        displayLabel
        children { id }
        sortOrder
      }
    }
    GQL
  end
end
