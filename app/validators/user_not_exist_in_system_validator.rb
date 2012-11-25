class UserNotExistInSystemValidator < ActiveModel::EachValidator
  def validate_each(object, attribute, value)
    unless User.is_valid_name?(value)
      object.errors[:login] << options[:message]
    end
  end
end
