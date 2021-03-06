# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FieldExportProfile, type: :model do
  describe '#new' do
    context 'when parameters are correct' do
      subject { FactoryBot.create(:field_export_profile) }

      it { is_expected.to be_a FieldExportProfile }

      its(:name) { is_expected.to eql 'descMetadata' }
      its(:translation_logic) do
        is_expected.to be_json_eql %({
          "element": "mods:mods",
          "content": [
            { "yield": "name" }
          ]
        })
      end
    end

    context 'when missing name' do
      let(:field_export_profile) { FactoryBot.build(:field_export_profile, name: nil) }

      it 'does not save' do
        expect(field_export_profile.save).to be false
      end

      it 'returns correct errors' do
        field_export_profile.save
        expect(field_export_profile.errors.full_messages).to include 'Name can\'t be blank'
      end
    end

    context 'when missing translation_logic' do
      let(:field_export_profile) { FactoryBot.build(:field_export_profile, translation_logic: nil) }

      it 'does not save' do
        expect(field_export_profile.save).to be false
      end

      it 'returns correct error' do
        field_export_profile.save
        expect(field_export_profile.errors.full_messages).to include 'Translation logic can\'t be blank'
      end
    end

    context 'when translation_logic is invalid' do
      let(:field_export_profile) { FactoryBot.build(:field_export_profile, translation_logic: 'randomstring') }

      it 'does not save' do
        expect(field_export_profile.save).to be false
      end

      it 'returns correct error' do
        field_export_profile.save
        expect(field_export_profile.errors.full_messages).to include 'Translation logic does not validate as JSON'
      end
    end
  end
end
