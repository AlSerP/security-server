module Db
  class Database
    class << self
      DB_PATH = File.expand_path File.dirname(__FILE__)
      DB_NAME = 'db.json' 

      attr_reader :users

      def load
        # logger.info "LOADING #{DB_NAME} from #{DB_PATH}"
        # puts "Loadig #{DB_NAME} from #{DB_PATH}"
        db = File.open(db_file).read
        @users = self.json_to_users JSON.parse db
        if @users.empty?
          fixtures!
        end
      end

      def find_user(username)
        users.each do |user|
          return user if user.username == username
        end

        nil
      end

      def create_user(data)
        user = Db::Serializer.hash_to_user data
        @users << user

        save
        user
      end

      def save
        data = []
        users.each { |user| data.push user.to_hash }
        File.write(db_file, data.to_json)
        # with File.open
        # data.to_json
      end

      private

      def fixtures!
        Db::Database.create_user(
          {
            'username' =>  'admin',
            'password' => '1234',
            'is_admin' => 'admin'
          }
        )
        Db::Database.create_user(
          {
            'username' => 'user',
            'password' => '1234'
          }
        )
      end

      def db_file
        "#{DB_PATH}/#{DB_NAME}"
      end

      def json_to_users(data)
        users = []
        data.each do |user|
          users.push Serializer.hash_to_user user
        end

        users
      end
    end
  end
end
