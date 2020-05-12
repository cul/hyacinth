# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DigitalObject::Asset, type: :model do
  describe "primary resource validations" do
    let(:asset) { FactoryBot.build(:asset) }
    it "fails if there is no resource or resource_import entry for the primary resource" do
      asset.save
      expect(asset.errors.keys).to include(:"resources[#{asset.primary_resource_name}]", :asset_type)
    end
  end
  describe "type validations" do
    let(:asset) { FactoryBot.build(:asset, :with_master_resource) }
    it "works for all valid values" do
      failed = BestType::PcdmTypeLookup::VALID_TYPES.detect do |type|
        asset.asset_type = type
        !asset.valid?
      end
      expect(failed).to be_nil
    end
    it "fails for invalid values" do
      failed = BestType::PcdmTypeLookup::VALID_TYPES.detect do |type|
        asset.asset_type = type.reverse
        !asset.valid?
      end
      expect(failed).to be BestType::PcdmTypeLookup::VALID_TYPES.first
    end
  end
  describe "restriction validations" do
    let(:asset) { FactoryBot.build(:asset, :with_master_resource) }
    before { asset.asset_type = BestType::PcdmTypeLookup::VALID_TYPES.first }
    it "validates boolean values for restrictions" do
      asset.restrictions['restricted_onsite'] = true
      expect(asset.valid?).to be true
    end
    it "invalidates non-boolean values for restrictions" do
      asset.restrictions['restricted_onsite'] = 'true'
      expect(asset.valid?).to be false
    end
  end
end
