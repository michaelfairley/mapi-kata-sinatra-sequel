class User
  attr_accessor :username
  attr_accessor :real_name
  attr_reader :password
  attr_accessor :id

  def initialize(attrs)
    attrs.each do |attr, val|
      send("#{attr}=", val)
    end
  end

  def password=(raw_password)
    @password = BCrypt::Password.create(raw_password, :cost => 4)
  end

  def password_hash=(hash)
    @password = BCrypt::Password.new(hash)
  end

  def as_json(followers, following)
    {
      :username => username,
      :real_name => real_name,
      :followers => followers.map(&:username),
      :following => following.map(&:username),
    }
  end
end
