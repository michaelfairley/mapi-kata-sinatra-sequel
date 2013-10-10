class UserValidator
  def initialize(user_repository)
    @user_repository = user_repository
  end

  def validate_new(params)
    errors = {}

    if @user_repository.contains_user_with_username?(params["username"])
      errors[:username] ||= []
      errors[:username] << "is taken"
    end
    if params["password"].size < 8
      errors[:password] ||= []
      errors[:password] << "is too short"
    end

    errors
  end
end
