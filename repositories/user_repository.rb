class UserRepository
  module Mapper
    def self.to_db(user)
      {
        :username => user.username,
        :realname => user.real_name,
        :password => user.password,
      }
    end

    def self.from_db(fields)
      return nil  if fields.nil?
      User.new(
        :username => fields.fetch(:username),
        :real_name => fields.fetch(:realname),
        :password_hash => fields.fetch(:password),
        :id => fields.fetch(:id),
      )
    end
  end

  def initialize(db)
    @ds = db[:users]
  end

  def find(username)
    Mapper.from_db(@ds.where(:username => username).first)
  end

  def insert(user)
    id = @ds.insert(Mapper.to_db(user))
    user.id = id
  end

  def contains_user_with_username?(username)
    @ds.where(:username => username).count > 0
  end
end
