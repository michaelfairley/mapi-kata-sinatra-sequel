class PostRepository
  module Mapper
    def self.to_db(post)
      {
        :text => post.text,
        :user_id => post.user_id
      }
    end

    def self.from_db(fields)
      return nil  if fields.nil?
      Post.new(
        :id => fields.fetch(:id),
        :text => fields.fetch(:text),
        :user_id => fields.fetch(:user_id),
      )
    end
  end

  def initialize(db)
    @ds = db[:posts]
  end

  def insert(post)
    id = @ds.insert(Mapper.to_db(post))
    post.id = id
  end

  def find(id)
    Mapper.from_db(@ds.where(:id => id).first)
  end
end
