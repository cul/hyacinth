FactoryBot.define do
  factory :field_export_profile do
    name { 'descMetadata' }
    translation_logic do
      '{
        "element": "mods:mods",
        "content": [
          {
            "yield": "title"
          }
        ]
      }'
    end
  end
end