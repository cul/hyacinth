require 'rails_helper'

RSpec.describe DynamicField, type: :model do
  describe '#new' do
    context 'when parameters are correct' do
      subject { FactoryBot.create(:dynamic_field) }

      it { is_expected.to be_a DynamicField }

      its(:string_key) { is_expected.to eql 'term' }
      its(:display_label) { is_expected.to eql 'Value' }
      its(:field_type) { is_expected.to eql DynamicField::Type::CONTROLLED_TERM }
      its(:sort_order) { is_expected.to be 7 }
      its(:filter_label) { is_expected.to eql 'Name' }
      its(:is_facetable) { is_expected.to eql true }
      its(:controlled_vocabulary) { is_expected.to eql 'name_role' }
      its(:select_options) { is_expected.to be_nil }
      its(:is_keyword_searchable) { is_expected.to be false }
      its(:is_title_searchable) { is_expected.to be false }
      its(:is_identifier_searchable) { is_expected.to be false }
      its(:dynamic_field_group) { is_expected.to be_a DynamicFieldGroup }
    end

    context 'when missing string_key' do
      let(:dynamic_field) { FactoryBot.build(:dynamic_field, string_key: nil) }

      it 'does not save' do
        expect(dynamic_field.save).to be false
      end

      it 'returns correct error' do
        dynamic_field.save
        expect(dynamic_field.errors.full_messages).to include 'String key can\'t be blank'
      end
    end

    context 'when missing field_type' do
      let(:dynamic_field) { FactoryBot.build(:dynamic_field, field_type: nil) }

      it 'does not save' do
        expect(dynamic_field.save).to be false
      end

      it 'returns correct error' do
        dynamic_field.save
        expect(dynamic_field.errors.full_messages).to include 'Field type can\'t be blank'
      end
    end

    context 'when field_type invalid' do
      let(:dynamic_field) { FactoryBot.build(:dynamic_field, field_type: 'not-valid') }

      it 'does not save' do
        expect(dynamic_field.save).to be false
      end

      it 'returns correct error' do
        dynamic_field.save
        expect(dynamic_field.errors.full_messages).to include 'Field type is not among the list of allowed values'
      end
    end

    context 'when missing dynamic_field_group' do
      let(:dynamic_field) { FactoryBot.build(:dynamic_field, dynamic_field_group: nil) }

      it 'does not save' do
        expect(dynamic_field.save).to be false
      end

      it 'returns correct error' do
        dynamic_field.save
        expect(dynamic_field.errors.full_messages).to include 'Dynamic field group is required'
      end
    end

    context 'when missing created_by' do
      let(:dynamic_field) { FactoryBot.build(:dynamic_field, created_by: nil) }

      it 'does not save' do
        expect(dynamic_field.save).to be false
      end

      it 'returns correct error' do
        dynamic_field.save
        expect(dynamic_field.errors.full_messages).to include 'Created by is required'
      end
    end

    context 'when missing updated_by' do
      let(:dynamic_field) { FactoryBot.build(:dynamic_field, updated_by: nil) }

      it 'does not save' do
        expect(dynamic_field.save).to be false
      end

      it 'returns correct error' do
        dynamic_field.save
        expect(dynamic_field.errors.full_messages).to include 'Updated by is required'
      end
    end

    context 'when creating select dynamic field' do
      let(:dynamic_field) { FactoryBot.build(:dynamic_field, field_type: DynamicField::Type::SELECT) }

      it 'requires select_options' do
        expect(dynamic_field.save).to be false
        expect(dynamic_field.errors.full_messages).to include 'Select options can\'t be blank'
      end
    end

    context 'when creating controlled term dynamic field' do
      let(:dynamic_field) { FactoryBot.build(:dynamic_field, controlled_vocabulary: nil) }

      it 'requires controlled_vocabulary' do
        expect(dynamic_field.save).to be false
        expect(dynamic_field.errors.full_messages).to include 'Controlled vocabulary can\'t be blank'
      end
    end

    context 'when missing sort_order' do
      let(:dynamic_field) { FactoryBot.build(:dynamic_field, sort_order: nil) }
      let(:parent) { dynamic_field.dynamic_field_group }

      context 'and has no sibling' do
        before { dynamic_field.save }

        it 'sets sort_order to 0' do
          expect(dynamic_field.sort_order).to be 0
        end
      end

      context 'and has sibling' do
        before do
          FactoryBot.create(:dynamic_field, string_key: 'primary', dynamic_field_group: parent, sort_order: 14)
          FactoryBot.create(:dynamic_field_group, :child, parent: parent, sort_order: 5)
          parent.reload
          dynamic_field.save
        end

        it 'sets sort_order to one more than the highest sort order' do
          expect(dynamic_field.sort_order).to be 15
        end
      end
    end

    context 'when creating a field with the same name as a sibling' do
      let(:parent) { FactoryBot.create(:dynamic_field_group) }

      context 'and the sibling is a DynamicField' do
        let(:dynamic_field) { FactoryBot.build(:dynamic_field, dynamic_field_group: parent) }

        before do
          FactoryBot.create(:dynamic_field, dynamic_field_group: parent)
          parent.reload
        end

        it 'does not save' do
          expect(dynamic_field.save).to be false
        end

        it 'returns correct error' do
          dynamic_field.save
          expect(dynamic_field.errors.full_messages).to include 'String key is already in use by a sibling field or field group'
        end
      end

      context 'and the sibling is a DynamicFieldGroup' do
        let(:dynamic_field) { FactoryBot.build(:dynamic_field, string_key: 'role', dynamic_field_group: parent) }

        before do
          FactoryBot.create(:dynamic_field_group, :child, parent: parent)
          parent.reload
        end

        it 'does not save' do
          expect(dynamic_field.save).to be false
        end

        it 'returns correct error' do
          dynamic_field.save
          expect(dynamic_field.errors.full_messages).to include 'String key is already in use by a sibling field or field group'
        end
      end
    end
  end

  describe '#siblings' do
    subject { FactoryBot.create(:dynamic_field) }

    it 'should not include current object' do
      subject.reload
      expect(subject.siblings).to match_array []
    end
  end
end
