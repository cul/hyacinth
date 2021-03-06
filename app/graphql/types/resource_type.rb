# frozen_string_literal: true

module Types
  class ResourceType < Types::BaseObject
    description 'A resource'

    field :location, String, null: true
    field :checksum, String, null: true
    field :original_file_path, String, null: true
    field :original_filename, String, null: true
    field :media_type, String, null: true
    field :file_size, Integer, null: true
  end
end
