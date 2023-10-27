module Db
  class Database
    class << self
      DB_PATH = File.expand_path File.dirname(__FILE__)
      # DB_NAME = 'db.json'
      DB_LOCK = 'db_lock.json'

      attr_reader :users

      def load
        # logger.info "LOADING #{DB_NAME} from #{DB_PATH}"
        # puts "Loadig #{DB_NAME} from #{DB_PATH}"
        loc_db = File.open(db_lock_file).read
        @users = []

        puts "LOC IS #{loc_db.empty?}"
        unless loc_db.empty?
          puts 'LOC_DB not nill'
          db = Db::Cipher.read(loc_db)

          @users = self.json_to_users JSON.parse db
          if @users.empty?
            fixtures!
          end
        else
          puts 'LOC_DB nill'
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
        # File.write(db_file, data.to_json)

        data_lock = Db::Cipher.encrypt(data.to_json)
        File.write(db_lock_file, data_lock)
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

      def db_lock_file
        "#{DB_PATH}/#{DB_LOCK}"
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
