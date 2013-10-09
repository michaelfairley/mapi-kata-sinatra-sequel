class User
  attr_accessor :username
  attr_accessor :password
  attr_accessor :real_name

  def initialize(attrs)
    attrs.each do |attr, val|
      send("#{attr}=", val)
    end
  end

  def as_json
    {
      :username => username,
      :real_name => real_name,
    }
  end
end
