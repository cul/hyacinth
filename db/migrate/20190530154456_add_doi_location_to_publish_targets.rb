class AddDoiLocationToPublishTargets < ActiveRecord::Migration[5.2]
  def change
    add_column :publish_targets, :is_allowed_doi_target, :boolean, null: false, default: false
    add_column :publish_targets, :doi_priority, :integer, null: false, default: 0
  end
end
