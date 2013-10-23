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
FILES << "models/post.rb"
FILES << "repositories/post_repository.rb"

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
    set :post_repository, PostRepository.new(db)
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

    def user_from_token
      if request.env['HTTP_AUTHENTICATION']
        token_value = request.env['HTTP_AUTHENTICATION'][/Token (.*)/, 1]
        token = settings.token_repository.find(token_value)
        if token
          settings.user_repository.find_by_id(token.user_id)
        else
          nil
        end
      else
        nil
      end
    end
  end

  get "/users/:username" do
    user = settings.user_repository.find(params[:username])

    followers = settings.user_repository.find_followers(user)
    following = settings.user_repository.find_followees(user)

    JSON.dump(user.as_json(followers, following))
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
    if user.nil? || user.password != request_json["password"]
      halt 401
    end

    token = Token.new_for_user(user)
    settings.token_repository.insert(token)

    JSON.dump(token.as_json)
  end

  post "/users/:username/posts" do
    user = user_from_token

    if user.nil?
      halt 401
    end

    if user.username != params[:username]
      halt 403
    end

    post = Post.new(
      :text => request_json["text"],
      :user_id => user.id
    )

    settings.post_repository.insert(post)

    redirect "/posts/#{post.id}"
  end

  get "/posts/:id" do
    post = settings.post_repository.find(params[:id])
    halt 404  if post.nil?

    author = settings.user_repository.find_by_id(post.user_id)
    raise  if author.nil?

    JSON.dump(post.as_json(author))
  end

  delete "/posts/:id" do
    post = settings.post_repository.find(params[:id])
    halt 404  if post.nil?

    halt 401  if user_from_token.nil?
    if post.user_id != user_from_token.id
      halt 403
    end

    settings.post_repository.delete(post)

    204
  end

  get "/users/:username/posts" do
    user = settings.user_repository.find(params[:username])

    halt 404  if user.nil?

    posts = settings.post_repository.find_page_for_user(user, params[:after])

    posts_as_json = posts.map{ |p| p.as_json(user) }

    JSON.dump(:posts => posts_as_json, :next => to("/users/#{user.username}/posts?after=#{posts.last.id}"))
  end

  put "/users/:username/:following/:other" do
    user = user_from_token
    halt 401  if user.nil?
    if params[:username] != user.username
      halt 403
    end

    followee = settings.user_repository.find(params[:other])

    settings.user_repository.follow!(user, followee)

    201
  end
end
