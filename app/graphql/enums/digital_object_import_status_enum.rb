# frozen_string_literal: true

class Enums::DigitalObjectImportStatusEnum < Types::BaseEnum
  DigitalObjectImport.statuses.each do |value_string, _value_number|
    value value_string.upcase.tr(' ', '_'), "Digital object import status of #{value_string}", value: value_string
  end
end
