class Mutations::UpdateUser < Mutations::BaseMutation
  argument :id, ID, required: true
  argument :first_name, String, required: false
  argument :last_name, String, required: false
  argument :email, String, required: false
  argument :current_password, String, required: false
  argument :password, String, required: false
  argument :password_confirmation, String, required: false
  argument :is_active, Boolean, required: false
  argument :is_admin, Boolean, required: false
  argument :permissions, [String], required: false

  field :user, Types::UserType, null: true

  def resolve(id:, **attributes)
    user = User.find_by!(uid: id)

    ability.authorize! :update, user

    permissions = attributes.delete(:permissions) # does this return nil if it doesnt exist?

    attributes.delete(:is_admin)  unless ability.can?(:manage, :all)
    attributes.delete(:is_active) unless ability.can?(:manage, user)

    attributes[:permissions_attributes] = permissions_attributes(user, permissions) if ability.can?(:manage, user) && !permissions.nil?

    # Update password if attempting to do so otherwise ignore
    success = changing_password?(attributes) ? user.update_with_password(attributes) : user.update_without_password(attributes)

    if success
      # Successful creation, return the created object with no errors
      {
        user: user
      }
    else
      raise GraphQL::ExecutionError.new(user.errors.full_messages.join('; '))
    end
  end

  private

    def changing_password?(attributes)
      [:current_password, :password, :password_confirmation].any? { |k| attributes.include?(k) && attributes[k].present? }
    end

    def permissions_attributes(user, permissions)
      return nil if permissions.nil?

      new_permissions = permissions.uniq

      permission_attributes = user.permissions.where(subject: nil, subject_id: nil).map do |perm|
        if new_permissions.include?(perm.action)
          new_permissions.delete(perm.action)
          { id: perm.id, action: perm.action }
        else
          { id: perm.id, _destroy: true }
        end
      end

      permission_attributes.concat new_permissions.map { |new_perm| { action: new_perm } }

      permission_attributes
    end
end