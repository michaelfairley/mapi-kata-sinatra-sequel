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

  def find_page_for_user(user, after=nil)
    cursor = after.nil? ? @ds : @ds.where{ id < after }

    post_tuples = cursor.where(:user_id => user.id).limit(50).reverse_order(:id).all
    post_tuples.map{ |p| Mapper.from_db(p) }
  end

  def delete(post)
    @ds.where(:id => post.id).delete
  end
end
