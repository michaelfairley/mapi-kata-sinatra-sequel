require "bundler/setup"

require "sinatra/base"
require "sinatra/reloader"
require "json"
require "sequel"

$LOAD_PATH.unshift File.dirname(__FILE__)

FILES = []
FILES << "models/user.rb"
FILES << "repositories/user_repository.rb"

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
  end

  before do
    content_type :json
  end

  helpers do
    def request_json
      JSON.parse(request.body.read)
    end
  end

  get "/users/:username" do
    JSON.dump(settings.user_repository.find(params[:username]).as_json)
  end

  post "/users" do
    user = User.new(request_json)

    settings.user_repository.insert(user)

    redirect "/users/#{user.username}"
  end
end
