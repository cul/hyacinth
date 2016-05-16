module DigitalObject::Data
  extend ActiveSupport::Concern

  def create_or_validate_pid_from_data(persisted_pid, digital_object_data)
    return unless digital_object_data['pid'].present?
    # PID
    if persisted_pid.nil?
      # This object has no pid and therefore must be new. Link it to the fedora object with the given pid.
      begin
        @fedora_object = ActiveFedora::Base.find(digital_object_data['pid'])
        init_from_digital_object_record_and_fedora_object(@db_record, @fedora_object)
      rescue ActiveFedora::ObjectNotFoundError
        raise Hyacinth::Exceptions::AssociatedFedoraObjectNotFoundError, "Tried to link existing Fedora object to new Hyacinth DigitalObject, but could not find Fedora object with pid #{digital_object_data['pid']}"
      end
    else
      if persisted_pid != digital_object_data['pid']
        raise "Cannot set a different pid for a DigitalObject with an existing pid.  (Tried to replace pid #{persisted_pid} with #{digital_object_data['pid']}.)"
      end
    end
  end

  def parent_digital_objects_from_data(digital_object_data)
    return unless digital_object_data['parent_digital_objects']

    digital_object_data['parent_digital_objects'].each do |parent_digital_object_find_criteria|
      if parent_digital_object_find_criteria['pid'].present?
        digital_object = DigitalObject::Base.find_by_pid(parent_digital_object_find_criteria['pid'])
      elsif parent_digital_object_find_criteria['identifier'].present?
        digital_object = digital_object_for_identifier(parent_digital_object_find_criteria['identifier'], Hyacinth::Exceptions::ParentDigitalObjectNotFoundError)
      else
        raise 'Invalid parent_digital_object find criteria: ' + parent_digital_object_find_criteria.inspect
      end

      yield digital_object if block_given?
    end
  end

  def publish_targets_from_data(digital_object_data)
    return unless digital_object_data['publish_targets']

    digital_object_data['publish_targets'].each do |publish_target_find_criteria|
      publish_target = PublishTarget.find_by(publish_target_find_criteria) # i.e. {string_key: 'target1'} or {pid: 'abc:123'}
      if publish_target.nil?
        raise Hyacinth::Exceptions::PublishTargetNotFoundError, "Could not find Publish Target: #{publish_target_find_criteria.inspect}"
      else
        yield publish_target if block_given?
      end
    end
  end

  def ordered_child_digital_objects_from_data(digital_object_data)
    return unless digital_object_data['ordered_child_digital_objects']

    digital_object_data['ordered_child_digital_objects'].each do |child_digital_object_find_criteria|
      if child_digital_object_find_criteria['pid'].present?
        digital_object = DigitalObject::Base.find_by_pid(child_digital_object_find_criteria['pid'])
      elsif child_digital_object_find_criteria['identifier'].present?
        digital_object = digital_object_for_identifier(child_digital_object_find_criteria['identifier'])
      else
        raise 'Invalid child object find criteria: ' + child_digital_object_find_criteria.inspect
      end

      yield digital_object if block_given?
    end
  end

  def digital_object_for_identifier(criteria, exception_class = Hyacinth::Exceptions::DigitalObjectNotFoundError)
    digital_object_results = DigitalObject::Base.find_all_by_identifier(criteria)

    raise exception_class, "Could not find DigitalObject with find criteria: #{criteria.inspect}" if digital_object_results.length == 0
    raise "While linking object to parent objects, expected one DigitalObject, but found #{digital_object_results.length} DigitalObjects" \
          "with identifier: #{child_digital_object_find_criteria['identifier']}.  You'll need to use a pid instead." if digital_object_results.length > 1
    digital_object_results.first
  end

  def project_from_data(digital_object_data)
    return unless digital_object_data['project']
    project_find_criteria = digital_object_data['project'] # i.e. {string_key: 'proj'} or {pid: 'abc:123'}
    project = Project.find_by(project_find_criteria)
    raise Hyacinth::Exceptions::ProjectNotFoundError, "Could not find Project: #{project_find_criteria.inspect}" if project.nil?
    project
  end

  def set_dynamic_fields_from_data(digital_object_data, merge = false)
    return unless digital_object_data[DigitalObject::DynamicField::DATA_KEY].present?
    # The merge_dynamic_fields setting determines whether or existing dynamic_field_data is merged or overwritten
    merge ||= digital_object_data['merge_dynamic_fields'].to_s =~ /true/i
    # Dynamic Field Data setter from DigitalObject::DynamicField
    update_dynamic_field_data(digital_object_data[DigitalObject::DynamicField::DATA_KEY], merge)
  end
end
