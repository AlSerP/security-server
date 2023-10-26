module Auth
  class User
    attr_reader :username, :password

    def initialize(username, password, is_blocked=false, is_validating=false)
      @username = username
      @password = password

      @is_blocked = is_blocked
      @is_validating = is_validating

      @is_admin = false
    end

    def admin?
      @is_admin
    end

    def blocked?
      @is_blocked
    end

    def validating?
      @is_validating
    end

    def save
      return nil unless Db::Database.find_user username

      Db::Database.save
    end

    def change_password(old_password, new_password)
      return nil unless old_password == @password

      @password = new_password if self.class.is_password_valid new_password
      save
    end

    def login?(password)
      password == @password
    end

    def self.is_password_valid(password)
      # TODO: Validation
      return true
    end

    def self.login(username, password)
      current_user = nil
      
      Db::Database.users.each do |user|
        current_user = user if username == user.username
      end

      return nil unless current_user
      return current_user if current_user.login? password
    end

    def to_hash
      {
        "username" => @username,
        "password" => @password,
        "is_admin" => admin?,
        "is_blocked" => blocked?,
        "is_validating" => validating?
      }
    end

    def to_json
      to_hash.to_json
    end

    def to_s
      @username
    end
  end
end
