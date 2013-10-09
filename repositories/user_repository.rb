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
        :password => fields.fetch(:password),
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
    @ds.insert(Mapper.to_db(user))
  end

  def contains_user_with_username?(username)
    @ds.where(:username => username).count > 0
  end
end
