require 'rails_helper'

RSpec.describe Project, type: :model do

  context "with test objects" do
  
    before(:context) do
  
      # the following is based on lib/tasks/hyacinth/projects/test.rake
  
      # Load certain records that we'll be referencing
      @dot_item = DigitalObjectType.find_by(string_key: 'item')
      @dot_group = DigitalObjectType.find_by(string_key: 'group')
      @dot_asset = DigitalObjectType.find_by(string_key: 'asset')
  
      # Create Test PID Generator
      @test_pid_generator = PidGenerator.create!(id: 1966, namespace: 'testingTheProjectModel')
  
      # Create Test project
      @test_project = Project.create!(id: 1966, string_key: 'testingTheProjectModel',display_label: 'Test the Project Model',pid_generator: @test_pid_generator)
  
      # Create test DynamicFieldGroupCategory
      @test_dynamic_field_group_category = DynamicFieldGroupCategory.create!(id: 1966, display_label: 'Testing the Project Model')
  
      # Create test DynamicFieldGroup and DynamicField
      @test_dynamic_field_1 = DynamicField.new(id: 1966, string_key: 'testing_the_project_model_field_one', display_label: 'Testing the Project Model Test Field One', dynamic_field_type: DynamicField::Type::STRING)
      @test_dynamic_field_2 = DynamicField.new(id: 1967, string_key: 'testing_the_project_model_field_two', display_label: 'Testing the Project Model Test Field One', dynamic_field_type: DynamicField::Type::STRING)
      @test_dynamic_field_group_1 = DynamicFieldGroup.create!(id: 1966, string_key: 'testing_the_project_model_test_field_group_one', display_label: 'Testing the Project Model Test Field Group One', dynamic_field_group_category: @test_dynamic_field_group_category,
            dynamic_fields: [
                             @test_dynamic_field_1,
                             @test_dynamic_field_2                           
            ]
          )
  
      @test_dynamic_field_3 = DynamicField.new(id: 1968, string_key: 'testing_the_project_model_field_three', display_label: 'Testing the Project Model Test Field Three', dynamic_field_type: DynamicField::Type::STRING)
      @test_dynamic_field_4 = DynamicField.new(id: 1969, string_key: 'testing_the_project_model_field_four', display_label: 'Testing the Project Model Test Field Four', dynamic_field_type: DynamicField::Type::STRING)
      @test_dynamic_field_group_2 = DynamicFieldGroup.create!(id: 1967, string_key: 'testing_the_project_model_test_field_group_two', display_label: 'Testing the Project Model Test Field Group Two', dynamic_field_group_category: @test_dynamic_field_group_category,
            dynamic_fields: [
                             @test_dynamic_field_3,
                             @test_dynamic_field_4                           
            ]
          )
  
    end
  
    after(:context) do
  
      @test_dynamic_field_group_2.destroy
      @test_dynamic_field_3.destroy
      @test_dynamic_field_4.destroy
      @test_dynamic_field_group_1.destroy
      @test_dynamic_field_1.destroy
      @test_dynamic_field_2.destroy
      @test_dynamic_field_group_category.destroy    
      @test_project.destroy
      @test_pid_generator.destroy
  
    end

    context 'Project#enabled_dynamic_field_ids ' do
  
      it 'handles the simple case of just one enabled_dynamic_field' do
        
        # Clear current @test_project.enabled_dynamic_fields
        @test_project.update(enabled_dynamic_fields: [])
  
        # Then add one enabled_dynamic_field to @test_project
        @test_project.enabled_dynamic_fields << EnabledDynamicField.new(dynamic_field: @test_dynamic_field_1, digital_object_type: @dot_item)
        
        expect(@test_project.enabled_dynamic_field_ids).to contain_exactly(@test_dynamic_field_1.id)
  
      end
  
      it 'handles the case of two enabled_dynamic_fields containing DynamicFields' do
  
        # Clear current @test_project.enabled_dynamic_fields
        @test_project.update(enabled_dynamic_fields: [])
  
        # Then add some enabled_dynamic_fields to @test_project
        @test_project.enabled_dynamic_fields << EnabledDynamicField.new(dynamic_field: @test_dynamic_field_1, digital_object_type: @dot_item)
        @test_project.enabled_dynamic_fields << EnabledDynamicField.new(dynamic_field: @test_dynamic_field_2, digital_object_type: @dot_asset)
        
        expect(@test_project.enabled_dynamic_field_ids).to contain_exactly(@test_dynamic_field_1.id,@test_dynamic_field_2.id)
  
      end
  
      it 'handles the case of two enabled_dynamic_fields containing the same Dynamic_field, but with difference digital_object_type' do
    
        # Clear current @test_project.enabled_dynamic_fields
        @test_project.update(enabled_dynamic_fields: [])
  
        # Then add some enabled_dynamic_fields to @test_project
        @test_project.enabled_dynamic_fields << EnabledDynamicField.new(dynamic_field: @test_dynamic_field_1, digital_object_type: @dot_item)
        @test_project.enabled_dynamic_fields << EnabledDynamicField.new(dynamic_field: @test_dynamic_field_1, digital_object_type: @dot_asset)
        
        expect(@test_project.enabled_dynamic_field_ids).to contain_exactly(@test_dynamic_field_1.id)
  
      end
  
    end
  end
  
  context '#set_valid_primary_publish_target_pid callback' do
    
    let(:sample_project) {
        sample_project = Project.new(
          string_key: 'sample_project',
          display_label: 'Sample Project',
          pid_generator: PidGenerator.default_pid_generator
        )
        fedora_object = double(Concept).as_null_object
        allow(sample_project).to receive(:fedora_object).and_return(fedora_object)
        allow(sample_project).to receive(:"create_associated_fedora_object!")
        
        sample_project.enabled_publish_target_pids = ['abc:123', 'def:456']
        sample_project.primary_publish_target_pid = 'abc:123'
        sample_project
    }
    
    before do
      sample_project.save
    end
    
    after do
      sample_project.destroy
    end
    
    context 'sets primary_publish_target_pid field to nil when enabled_publish_target_pids is blank' do
      let(:sample_project_with_new_enabled_publish_target_pids) {
        sample_project.enabled_publish_target_pids = []
        sample_project
      }
      it do
        sample_project_with_new_enabled_publish_target_pids.save
        expect(sample_project_with_new_enabled_publish_target_pids.primary_publish_target_pid).to be_nil
      end
    end
    
    context 'sets the primary_publish_target_pid field to enabled_publish_target_pids.first when enabled_publish_target_pids is not blank and does not include primary_publish_target_pid' do
      let(:sample_project_with_new_enabled_publish_target_pids) {
        sample_project.enabled_publish_target_pids = ['zz:top', 'ac:dc']
        sample_project
      }
      it do
        sample_project_with_new_enabled_publish_target_pids.save
        expect(sample_project_with_new_enabled_publish_target_pids.primary_publish_target_pid).to eq('zz:top')
      end
    end
    
    context 'removes blank enabled_publish_target_pids on save' do
      let(:sample_project_with_new_enabled_publish_target_pids) {
        sample_project.enabled_publish_target_pids = ['', 'zz:top', '', 'ac:dc']
        sample_project
      }
      it do
        sample_project_with_new_enabled_publish_target_pids.save
        expect(sample_project_with_new_enabled_publish_target_pids.enabled_publish_target_pids).to eq(['zz:top', 'ac:dc'])
      end
    end
    
  end

end