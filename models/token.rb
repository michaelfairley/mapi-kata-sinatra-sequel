class Token
  attr_accessor :value
  attr_accessor :user_id

  def initialize(attrs)
    attrs.each do |attr, val|
      send("#{attr}=", val)
    end
  end

  def self.new_for_user(user)
    new(
      :user_id => user.id,
      :value => generate_value
    )
  end

  def self.generate_value
    SecureRandom.uuid
  end

  def as_json
    {:token => value}
  end
end
