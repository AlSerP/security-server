module Auth
  class User
    attr_reader :name, :password, :is_admin

    def initialize(name, password)
      @name = name
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

    def self.login(login, password)
      current_user = nil
      Auth::USERS.each do |user|
        current_user = user if login == user.name
      end
      
      return nil unless current_user
      return current_user if current_user.is_login password
    end

    def to_s
      @login
    end
  end
end
