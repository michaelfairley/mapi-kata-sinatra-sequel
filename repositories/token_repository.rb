class TokenRepository
  module Mapper
    def self.to_db(token)
      {
        :value => token.value,
        :user_id => token.user_id
      }
    end

    def self.from_db(fields)
      return nil  if fields.nil?
      Token.new(
        :value => fields.fetch(:value),
        :user_id => fields.fetch(:user_id),
      )
    end
  end

  def initialize(db)
    @ds = db[:tokens]
  end

  def insert(token)
    @ds.insert(Mapper.to_db(token))
  end

  def find(value)
    Mapper.from_db(@ds.where(:value => value).first)
  end
end
