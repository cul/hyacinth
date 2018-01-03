require 'rails_helper'

describe DigitalObject::XmlDatastreamRendering do
  let(:test_class) do
    Class.new do
      include DigitalObject::XmlDatastreamRendering
      attr_reader :project
    end
  end

  let(:digital_object) { test_class.new }
  let(:dynamic_field_data) {
    JSON.parse(fixture('models/concerns/digital_object/test_dynamic_field_data.json').read)
  }

  describe '#render_xml_translation_with_data' do
    let(:doc) { Nokogiri::XML::Document.new }
    let(:name) { double(xml_translation: name_translation_logic) }
    let(:name_role) { double(xml_translation: role_translation_logic) }
    let(:xml_translation_map) do
      { 'name' => name, 'name_role' => name_role }
    end

    let(:base_xml_translation) do
      JSON('
        {
          "element": "mods:mods",
          "content": [
            {
              "yield": "name"
            }
          ]
        }
      ')
    end

    let(:name_translation_logic) do
      '[
        {
          "render_if": {
            "present": ["name_term.value"]
          },
          "element": "mods:name",
          "attrs": {
            "type": "{{name_term.name_type}}",
            "ID": "{{name_term.uni}}",
            "usage": {
              "ternary": ["name_usage_primary", "primary", ""]
            },
            "valueURI": "{{name_term.uri}}",
            "authority": "{{name_term.authority}}"
          },
          "content": [
            {
              "element": "mods:namePart",
              "content": "{{name_term.value}}"
            },
            {
              "yield": "name_role"
            }
          ]
        }
      ]'
    end

    let(:role_translation_logic) do
      '[
        {
          "render_if": {
            "present": [
                "name_role_term.value"
            ]
          },
          "element": "mods:role",
          "content": [
            {
              "element": "mods:roleTerm",
              "attrs": {
                  "type": "text",
                  "valueURI": "{{name_role_term.uri}}",
                  "authority": "{{name_role_term.authority}}"
              },
              "content": "{{name_role_term.value}}"
            }
          ]
        }
      ]'
    end



    context 'when nesting elements' do
      let(:expected_mods) do
        '<?xml version="1.0"?>
        <mods:mods>
          <mods:name ID="jds1329" valueURI="http://id.loc.gov/authorities/names/n50016589">
            <mods:namePart>Salinger, J. D.</mods:namePart>
            <mods:role>
              <mods:roleTerm type="text" valueURI="http://id.loc.gov/roles/123">Author</mods:roleTerm>
            </mods:role>
          </mods:name>
          <mods:name valueURI="http://id.loc.gov/authorities/names/n79006779">
            <mods:namePart>Lincoln, Abraham</mods:namePart>
            <mods:role>
              <mods:roleTerm type="text" valueURI="http://id.loc.gov/roles/456">Illustrator</mods:roleTerm>
            </mods:role>
            <mods:role>
              <mods:roleTerm type="text" valueURI="http://id.loc.gov/roles/789">Editor</mods:roleTerm>
            </mods:role>
         </mods:name>
        </mods:mods>'
      end

      it 'generates correct xml' do
        # doc = Nokogiri::XML::Document.new
        digital_object.render_xml_translation_with_data(doc, doc, base_xml_translation, dynamic_field_data, xml_translation_map)
        expect(doc).to be_equivalent_to expected_mods
      end
    end

    context 'when render_if has multiple conditions' do
      let(:role_translation_logic) do # Should only render role for authors
        '[
          {
            "render_if": {
              "present": [
                  "name_role_term.value"
              ],
              "equal": {
                "name_role_term.value": "Author"
              }
            },
            "element": "mods:role",
            "content": [
              {
                "element": "mods:roleTerm",
                "attrs": {
                    "type": "text",
                    "valueURI": "{{name_role_term.uri}}",
                    "authority": "{{name_role_term.authority}}"
                },
                "content": "{{name_role_term.value}}"
              }
            ]
          }
        ]'
      end

      let(:expected_mods) do
        '<?xml version="1.0"?>
        <mods:mods>
          <mods:name ID="jds1329" valueURI="http://id.loc.gov/authorities/names/n50016589">
            <mods:namePart>Salinger, J. D.</mods:namePart>
            <mods:role>
              <mods:roleTerm type="text" valueURI="http://id.loc.gov/roles/123">Author</mods:roleTerm>
            </mods:role>
          </mods:name>
          <mods:name valueURI="http://id.loc.gov/authorities/names/n79006779">
            <mods:namePart>Lincoln, Abraham</mods:namePart>
         </mods:name>
        </mods:mods>'
      end

      it 'generates corrext xml' do
        digital_object.render_xml_translation_with_data(doc, doc, base_xml_translation, dynamic_field_data, xml_translation_map)
        expect(doc).to be_equivalent_to expected_mods
      end
    end

    context 'when two fields are joined' do
      let(:name_translation_logic) do
        '[
          {
            "render_if": {
              "present": ["name_term.value"]
            },
            "element": "mods:name",
            "attrs": {
              "type": "{{name_term.name_type}}",
              "ID": "{{name_term.uni}}",
              "usage": {
                "ternary": ["name_usage_primary", "primary", ""]
              },
              "valueURI": "{{name_term.uri}}",
              "authority": "{{name_term.authority}}"
            },
            "content": [
              {
                "element": "mods:namePart",
                "content": [{
                  "join": {
                    "delimiter": " - ",
                    "pieces": ["{{name_term.value}}", "{{name_term.uni}}"]
                  }
                }]
              }
            ]
          }
        ]'
      end

      let(:expected_mods) do
        '<?xml version="1.0"?>
        <mods:mods>
          <mods:name ID="jds1329" valueURI="http://id.loc.gov/authorities/names/n50016589">
            <mods:namePart>Salinger, J. D. - jds1329</mods:namePart>
          </mods:name>
          <mods:name valueURI="http://id.loc.gov/authorities/names/n79006779">
            <mods:namePart>Lincoln, Abraham</mods:namePart>
         </mods:name>
        </mods:mods>'
      end

      it 'generates correct xml' do
        digital_object.render_xml_translation_with_data(doc, doc, base_xml_translation, dynamic_field_data, xml_translation_map)
        expect(doc).to be_equivalent_to expected_mods
      end
    end

    context "when joining in attribute values" do
      let(:name_translation_logic) do
        '[
          {
            "render_if": {
              "present": ["name_term.value"]
            },
            "element": "mods:name",
            "attrs": {
              "type": "{{name_term.name_type}}",
              "ID": {
                "join": {
                  "delimiter": " ",
                  "pieces": ["{{name_term.uni}}", "{{name_term.value}}"]
                }
              },
              "valueURI": "{{name_term.uri}}",
              "authority": "{{name_term.authority}}"
            },
            "content": [
              {
                "element": "mods:namePart",
                "content": "{{name_term.value}}"
              }
            ]
          }
        ]'
      end

      let(:expected_mods) do
        '<?xml version="1.0"?>
        <mods:mods>
          <mods:name ID="jds1329 Salinger, J. D." valueURI="http://id.loc.gov/authorities/names/n50016589">
            <mods:namePart>Salinger, J. D.</mods:namePart>
          </mods:name>
          <mods:name ID="Lincoln, Abraham" valueURI="http://id.loc.gov/authorities/names/n79006779">
            <mods:namePart>Lincoln, Abraham</mods:namePart>
         </mods:name>
        </mods:mods>'
      end

      it 'generates corrext xml' do
        digital_object.render_xml_translation_with_data(doc, doc, base_xml_translation, dynamic_field_data, xml_translation_map)
        expect(doc).to be_equivalent_to expected_mods
      end
    end
  end

  describe '#value_with_substitutions' do
    let(:name_df_data) { dynamic_field_data["name"][0] }

    it "replaces value when its the only thing in the string" do
      expect(digital_object.value_with_substitutions("{{name_term.value}}", name_df_data)).to eql "Salinger, J. D."
    end

    it "replaces correct value when there are multiple references" do
      expect(digital_object.value_with_substitutions("{{name_term.value}}{{name_term.uni}}", name_df_data)).to eql "Salinger, J. D.jds1329"
    end

    it "replaces corrext value when reference is surrounded by characters" do
      expect(digital_object.value_with_substitutions("Author name is {{name_term.value}}.", name_df_data)).to eql "Author name is Salinger, J. D.."
    end
  end

  describe "#value_for_field_name" do
    let(:name_df_data) { dynamic_field_data["name"][0] }
    let(:title_df_data) { dynamic_field_data["title"][0] }

    before do
      allow(digital_object).to receive(:project).and_return(double(display_label: "Test Project"))
    end

    it "looks up value when it starts with a $" do
      expect(digital_object.value_for_field_name("$project.display_label", name_df_data)).to eql "Test Project"
    end

    it "returns data unavailable when referenced value doesn't have a matching variable" do
      expect(digital_object.value_for_field_name("$project.expiration_date", name_df_data)).to eql "Data unavailable"
    end

    it "returns correct value when fields are nested" do
      expect(digital_object.value_for_field_name("name_term.uni", name_df_data)).to eql "jds1329"
    end

    it "returns correct value when not nested" do
      expect(digital_object.value_for_field_name("title_sort_portion", title_df_data)).to eql "Catcher in the Rye"
    end

    it "returns empty string if field does not exist" do
      expect(digital_object.value_for_field_name("name_term.last_name", name_df_data)).to eql ""
    end
  end

  describe "#render_output_of_ternary" do
    let(:name_df_data) { dynamic_field_data["name"][0] }

    it 'returns "true" value if field present' do
      arr = ["name_term.value", "True", "False"]
      expect(digital_object.render_output_of_ternary(arr, name_df_data)).to eql "True"
    end

    it 'returns "false" value if field present' do
      arr = ["name_term.first_name", "True", "False"]
      expect(digital_object.render_output_of_ternary(arr, name_df_data)).to eql "False"
    end

    it "renders field value if field present" do
      arr = ["name_term.value", "name_term.value", "False"]
      expect(digital_object.render_output_of_ternary(arr, name_df_data)).to eql "name_term.value"
    end
  end
end