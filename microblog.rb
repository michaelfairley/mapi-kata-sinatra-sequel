require "bundler/setup"

require "sinatra/base"
require "sinatra/reloader"
require "json"
require "sequel"
require "bcrypt"

$LOAD_PATH.unshift File.dirname(__FILE__)

FILES = []
FILES << "models/user.rb"
FILES << "repositories/user_repository.rb"
FILES << "validators/user_validator.rb"
FILES << "models/token.rb"
FILES << "repositories/token_repository.rb"

FILES.each do |file|
  load File.join(File.dirname(__FILE__), file)
end

class Microblog < Sinatra::Base
  configure :development do
    register Sinatra::Reloader
    FILES.each do |file|
      also_reload File.join(File.dirname(__FILE__), file)
    end
  end

  configure do
    db = Sequel.connect('postgres://localhost/microblog_api_kata')
    set :user_repository, UserRepository.new(db)
    set :user_validator, UserValidator.new(settings.user_repository)
    set :token_repository, TokenRepository.new(db)
  end

  before do
    content_type :json
  end

  helpers do
    def request_json
      @request_json ||= JSON.parse(request.body.read)
    end

    def validation_error_response(validation_errors)
      [422, JSON.dump(:errors => validation_errors)]
    end
  end

  get "/users/:username" do
    JSON.dump(settings.user_repository.find(params[:username]).as_json)
  end

  post "/users" do
    validation_errors = settings.user_validator.validate_new(request_json)

    if validation_errors.empty?
      user = User.new(request_json)

      settings.user_repository.insert(user)

      redirect "/users/#{user.username}"
    else
      validation_error_response validation_errors
    end
  end

  post "/tokens" do
    user = settings.user_repository.find(request_json["username"])

    token = Token.new_for_user(user)
    settings.token_repository.insert(token)

    JSON.dump(token.as_json)
  end
end
