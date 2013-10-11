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
    @password = BCrypt::Password.create(raw_password)
  end

  def password_hash=(hash)
    @password = BCrypt::Password.new(hash)
  end

  def as_json
    {
      :username => username,
      :real_name => real_name,
    }
  end
end
