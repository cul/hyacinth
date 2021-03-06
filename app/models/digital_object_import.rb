# frozen_string_literal: true

class DigitalObjectImport < ApplicationRecord
  enum status: {
    pending: 0,
    queued: 1,
    in_progress: 2,
    success: 3,
    cancelled: 4,
    creation_failure: 5,
    update_failure: 6,
    persist_failure: 7,
    publish_failure: 8
  }

  serialize :import_errors, Array

  belongs_to :batch_import
  has_many :import_prerequisites, dependent: :destroy

  validates :status, :digital_object_data, presence: true
end
