module Db
  class Database
    class << self
      DB_PATH = File.expand_path File.dirname(__FILE__)
      DB_NAME = 'db.json' 

      attr_reader :users

      def load
        puts "Loadig #{DB_NAME} from #{DB_PATH}"
        db = File.open(DB_PATH.to_s + '/' + DB_NAME).read
        @users = self.json_to_users JSON.parse db
      end
      
      def find_user(username)
        users.each do |user|
          user[username]
        end
        return nil unless users.keys.include? username 
      end

      private

      def json_to_users(data)
        users = []
        data.each do |user|
          users.push Serializer.json_to_user user
        end
        return users
      end

      def user_to_json(data)
      end
    end
  end
end