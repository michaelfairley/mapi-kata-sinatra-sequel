class Post
  attr_accessor :text
  attr_accessor :id
  attr_accessor :user_id

  def initialize(attrs)
    attrs.each do |attr, val|
      send("#{attr}=", val)
    end
  end

  def as_json(author)
    raise  unless author.id == user_id
    {
      :id => id,
      :text => text,
      :author => author.username,
    }
  end
end
