module Db
  class Serializer
    class << self
      def user_to_json(user)
        
      end

      def hash_to_user(data)
        klass = Auth::User
        klass = Auth::Admin if data['is_admin']

        klass.new(data['username'], data['password'])
      end
    end
  end
end