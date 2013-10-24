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
    @following_ds = db[:followings]
  end

  def find(username)
    Mapper.from_db(@ds.where(:username => username).first)
  end

  def find_by_id(id)
    Mapper.from_db(@ds.where(:id => id).first)
  end

  def insert(user)
    id = @ds.insert(Mapper.to_db(user))
    user.id = id
  end

  def contains_user_with_username?(username)
    @ds.where(:username => username).count > 0
  end

  def find_followers(user)
    @ds.join(:followings, :follower_id => :id).
      where(:followee_id => user.id).
      all.
      map{ |u| Mapper.from_db(u) }
  end

  def find_followees(user)
    @ds.join(:followings, :followee_id => :id).
      where(:follower_id => user.id).
      all.
      map{ |u| Mapper.from_db(u) }
  end

  def follow!(follower, followee)
    @following_ds.insert(
      :follower_id => follower.id,
      :followee_id => followee.id,
    )
  rescue Sequel::UniqueConstraintViolation
  end

  def unfollow!(follower, followee)
    @following_ds.where(
      :follower_id => follower.id,
      :followee_id => followee.id,
    ).delete
  end
end
