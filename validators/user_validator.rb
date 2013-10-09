class UserValidator
  def initialize(user_repository)
    @user_repository = user_repository
  end

  def validate_new(params)
    if @user_repository.contains_user_with_username?(params["username"])
      {
        :username => [
          "is taken"
        ]
      }
    else
      nil
    end
  end
end
