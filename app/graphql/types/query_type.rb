# frozen_string_literal: true

module Types
  class QueryType < Types::BaseObject
    # Add root-level fields here.
    # They will be entry points for queries on your schema.

    field :authenticated_user, AuthenticatedUserType, null: true do
      description 'Logged-in user'
    end

    field :users, [UserType], null: true do
      description 'List of all users'
    end

    field :user, UserType, null: true do
      description "Find a user by ID"
      argument :id, ID, required: true
    end

    field :project, ProjectType, null: true do
      argument :string_key, ID, required: true
    end

    field :projects, [ProjectType], null: true do
      argument :is_primary, Boolean, required: false
      description "List of all projects"
    end

    field :digital_objects, [DigitalObjectInterface], null: true do
      description "List and searches all digital objects"
    end

    field :digital_object, DigitalObjectInterface, null: true do
      argument :id, ID, required: true
    end

    field :child_structure, ChildStructureType, null: true do
      description "Return dereferenced child digital objects"
      argument :id, ID, required: true
    end

    field :permission_actions, PermissionActionsType, null: true do
      description 'Information about available project permission actions.'
    end

    field :vocabulary, VocabularyType, null: true do
      argument :string_key, ID, required: true
    end

    field :vocabularies, VocabularyType.results_type, null: true, extensions: [Types::Extensions::Paginate] do
      description "List of all vocabularies"
    end

    def digital_objects
      # This is a temporary implementation, this should actually querying solr
      # and considering object read permissions.
      DigitalObjectRecord.all
    end

    def digital_object(id:)
      digital_object = ::DigitalObject::Base.find(id)
      ability.authorize!(:read, digital_object)
      digital_object
    end

    def vocabulary(string_key:)
      vocabulary = Vocabulary.find_by!(string_key: string_key)
      ability.authorize!(:read, vocabulary)
      vocabulary
    end

    def vocabularies(_arguments)
      ability.authorize!(:read, Vocabulary)
      Vocabulary.accessible_by(ability).order(:label)
    end

    # This is a temporary implementation
    def child_structure(id:)
      digital_object = ::DigitalObject::Base.find(id)
      ability.authorize!(:read, digital_object)
      {
        parent: digital_object,
        type: digital_object.structured_children['type'],
        structure: digital_object.structured_children['structure'].map! { |cid| ::DigitalObject::Base.find(cid) }
      }

    field :dynamic_field_categories, [DynamicFieldCategoryType], null: true do
      description "List of all dynamic field categories"
    end

    def dynamic_field_categories
      ability.authorize!(:read, DynamicFieldCategory)
      DynamicFieldCategory.order(:sort_order)
    end

    field :dynamic_field_category, DynamicFieldCategoryType, null: true do
      argument :id, ID, required: true
    end

    def dynamic_field_category(id:)
      dynamic_field_category = DynamicFieldCategory.find(id)
      ability.authorize!(:read, dynamic_field_category)
      dynamic_field_category
    end

    field :dynamic_field_group, DynamicFieldGroupType, null: true do
      argument :id, ID, required: true
    end

    def dynamic_field_group(id:)
      dynamic_field_group = DynamicFieldGroup.find(id)
      ability.authorize!(:read, dynamic_field_group)
      dynamic_field_group
    end

    field :dynamic_field, DynamicFieldType, null: true do
      argument :id, ID, required: true
    end

    def dynamic_field(id:)
      dynamic_field = DynamicField.find(id)
      ability.authorize!(:read, dynamic_field)
      dynamic_field
    end

    def project(string_key:)
      project = Project.find_by!(string_key: string_key)
      ability.authorize!(:read, project)
      project
    end

    def projects(is_primary: nil)
      ability.authorize!(:read, Project)
      if is_primary.nil?
        Project.accessible_by(ability)
      else
        Project.where(is_primary: is_primary).accessible_by(ability)
      end
    end

    def user(id:)
      user = User.find_by!(uid: id)
      ability.authorize!(:read, user)
      user
    end

    def users
      ability.authorize!(:index, User)
      User.accessible_by(ability).order(:sort_name)
    end

    def permission_actions
      {
        project_actions: Permission::PROJECT_ACTIONS,
        primary_project_actions: Permission::PRIMARY_PROJECT_ACTIONS,
        aggregator_project_actions: Permission::AGGREGATOR_PROJECT_ACTIONS
      }
    end

    def authenticated_user
      context[:current_user]
    end
  end
end
