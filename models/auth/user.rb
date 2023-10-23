module Auth
  class User
    attr_reader :username, :password, :is_admin

    def initialize(username, password)
      @username = username
      @password = password
      @is_admin = false
    end

    def change_password(old_password, new_password)
      return nil unless old_password == @password

      @password = new_password if self.is_password_valid new_password 
    end

    def is_login(password)
      password == @password
    end

    def self.is_password_valid(password)
      # TODO: Validation
      return true
    end

    def self.login(username, password)
      current_user = nil
      puts "GOT #{username} #{password}"
      Db::Database.users.each do |user|
        current_user = user if username == user.username
      end
      
      return nil unless current_user
      return current_user if current_user.is_login password
    end

    def to_s
      @username
    end
  end
end
