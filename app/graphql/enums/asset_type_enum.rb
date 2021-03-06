# frozen_string_literal: true

class Enums::AssetTypeEnum < Types::BaseEnum
  BestType::PcdmTypeLookup::VALID_TYPES.each do |type_value|
    value type_value.upcase.tr(' ', '_'), "Asset of type #{type_value}", value: type_value
  end
end
